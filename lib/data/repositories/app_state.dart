import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../mock/catalog_taxonomy.dart';
import '../mock/mock_catalog.dart';
import '../models/models.dart';
import 'supabase_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  int get subtotal => _items.fold(0, (sum, i) => sum + i.lineTotal);
  bool get isEmpty => _items.isEmpty;

  void add(Product product, {int quantity = 1}) {
    final existing = _items.where((i) => i.product.id == product.id).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }
    final item = _items.where((i) => i.product.id == productId).firstOrNull;
    if (item != null) {
      item.quantity = quantity;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class LoyaltyProvider extends ChangeNotifier {
  LoyaltyProvider() {
    _load();
  }

  final LoyaltyBalance balance = LoyaltyBalance();
  bool remoteSynced = false;
  static const _key = 'voltify_loyalty';

  Future<void> _load() async {
    try {
      final remote = await SupabaseService.fetchLoyalty();
      balance.lumineux = remote.lumineux;
      balance.deco = remote.deco;
      remoteSynced = true;
      await _saveLocal();
      notifyListeners();
      return;
    } catch (_) {
      // fallback local
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      notifyListeners();
      return;
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    balance.lumineux = map['lumineux'] as int? ?? 0;
    balance.deco = map['deco'] as int? ?? 0;
    notifyListeners();
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({'lumineux': balance.lumineux, 'deco': balance.deco}),
    );
  }

  Future<void> _save() async {
    await _saveLocal();
    try {
      await SupabaseService.saveLoyalty(balance);
      remoteSynced = true;
    } catch (_) {}
  }

  Future<Map<LoyaltyTrack, int>> awardForItems(List<CartItem> items) async {
    final earned = <LoyaltyTrack, int>{
      LoyaltyTrack.lumineux: 0,
      LoyaltyTrack.deco: 0,
    };
    for (final item in items) {
      final pts = item.product.pointsReward * item.quantity;
      final track = item.product.loyaltyTrack;
      earned[track] = (earned[track] ?? 0) + pts;
      balance.add(track, pts);
    }
    await _save();
    notifyListeners();
    return earned;
  }

  LoyaltyTier get tier => LoyaltyTierX.fromPoints(balance.lumineux);

  int discountForSubtotal(int subtotal) {
    final pct = tier.discountPercent;
    if (pct <= 0) return 0;
    return ((subtotal * pct) / 100).round();
  }
}

class OrderProvider extends ChangeNotifier {
  OrderProvider() {
    _load();
  }

  final List<OrderRecord> _orders = [];
  static const _key = 'voltify_orders';
  final _uuid = const Uuid();

  List<OrderRecord> get orders => List.unmodifiable(_orders);

  Future<void> refreshFromRemote(Map<String, Product> productById) async {
    try {
      final remote = await SupabaseService.fetchOrders(productById);
      if (remote.isNotEmpty) {
        _orders
          ..clear()
          ..addAll(remote);
        await _persist();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final entry in list) {
        final m = entry as Map<String, dynamic>;
        final productIds = (m['productIds'] as List<dynamic>?)?.cast<String>() ?? [];
        final quantities = (m['quantities'] as List<dynamic>?)?.cast<int>() ?? [];
        final items = <CartItem>[];
        for (var i = 0; i < productIds.length; i++) {
          final p = MockCatalog.byId(productIds[i]);
          if (p != null) {
            items.add(CartItem(product: p, quantity: i < quantities.length ? quantities[i] : 1));
          }
        }
        _orders.add(
          OrderRecord(
            id: m['id'] as String,
            items: items,
            customerName: m['customerName'] as String? ?? 'Client',
            phone: m['phone'] as String? ?? '',
            email: m['email'] as String?,
            deliveryMode: (m['deliveryMode'] as String?) == 'pickup'
                ? DeliveryMode.pickup
                : DeliveryMode.delivery,
            address: m['address'] as String?,
            city: m['city'] as String?,
            pickupPointId: m['pickupPointId'] as String?,
            paymentMethod: PaymentMethod.values.firstWhere(
              (e) => e.name == m['paymentMethod'],
              orElse: () => PaymentMethod.orangeMoney,
            ),
            subtotal: m['subtotal'] as int? ?? 0,
            deliveryFee: m['deliveryFee'] as int? ?? 0,
            total: m['total'] as int? ?? 0,
            createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
            pointsEarned: {
              LoyaltyTrack.lumineux: m['ptsLumineux'] as int? ?? 0,
              LoyaltyTrack.deco: m['ptsDeco'] as int? ?? 0,
            },
          ),
        );
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _orders
        .map(
          (o) => {
            'id': o.id,
            'productIds': o.items.map((i) => i.product.id).toList(),
            'quantities': o.items.map((i) => i.quantity).toList(),
            'customerName': o.customerName,
            'phone': o.phone,
            'email': o.email,
            'deliveryMode': o.deliveryMode.name,
            'address': o.address,
            'city': o.city,
            'pickupPointId': o.pickupPointId,
            'paymentMethod': o.paymentMethod.name,
            'subtotal': o.subtotal,
            'deliveryFee': o.deliveryFee,
            'total': o.total,
            'createdAt': o.createdAt.toIso8601String(),
            'ptsLumineux': o.pointsEarned[LoyaltyTrack.lumineux] ?? 0,
            'ptsDeco': o.pointsEarned[LoyaltyTrack.deco] ?? 0,
          },
        )
        .toList();
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<OrderRecord> placeOrder({
    required List<CartItem> items,
    required String customerName,
    required String phone,
    String? email,
    required DeliveryMode deliveryMode,
    String? address,
    String? city,
    String? pickupPointId,
    required PaymentMethod paymentMethod,
    required Map<LoyaltyTrack, int> pointsEarned,
    int loyaltyDiscount = 0,
  }) async {
    final subtotal = items.fold(0, (s, i) => s + i.lineTotal);
    final fee = MockCatalog.computeDeliveryFee(subtotal, deliveryMode);
    final total = (subtotal - loyaltyDiscount + fee).clamp(0, 1 << 31);
    final order = OrderRecord(
      id: 'VF-${_uuid.v4().substring(0, 8).toUpperCase()}',
      items: items.map((i) => CartItem(product: i.product, quantity: i.quantity)).toList(),
      customerName: customerName,
      phone: phone,
      email: email,
      deliveryMode: deliveryMode,
      address: address,
      city: city,
      pickupPointId: pickupPointId,
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      deliveryFee: fee,
      loyaltyDiscount: loyaltyDiscount,
      total: total,
      createdAt: DateTime.now(),
      pointsEarned: pointsEarned,
    );
    _orders.insert(0, order);
    await _persist();
    try {
      await SupabaseService.placeOrder(order);
    } catch (_) {}
    notifyListeners();
    return order;
  }
}

class CatalogProvider extends ChangeNotifier {
  CatalogProvider() {
    load();
  }

  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  String _query = '';
  List<Product> _all = List.of(MockCatalog.products);
  List<PickupPoint> pickupPoints = List.of(MockCatalog.pickupPoints);
  bool loading = true;
  bool usingRemote = false;
  String? error;

  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedSubcategoryId => _selectedSubcategoryId;
  String get query => _query;

  Map<String, Product> get productById => {for (final p in _all) p.id: p};

  List<Product> get products {
    var list = _all;
    if (_selectedCategoryId != null) {
      list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
    }
    if (_selectedSubcategoryId != null) {
      list = list.where((p) => p.subcategoryId == _selectedSubcategoryId).toList();
    }
    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      list = list.where((p) => _matches(p, q)).toList();
    }
    return list;
  }

  /// Un produit répond aussi au vocabulaire de son rayon : chercher
  /// « charnière » remonte la quincaillerie même sans produit ainsi nommé.
  bool _matches(Product p, String q) {
    if (p.name.toLowerCase().contains(q)) return true;
    if (p.brand.toLowerCase().contains(q)) return true;
    final label = CatalogTaxonomy.labelFor(
      categoryId: p.categoryId,
      subcategoryId: p.subcategoryId,
    );
    if (label.toLowerCase().contains(q)) return true;
    final sub = p.subcategoryId == null
        ? null
        : CatalogTaxonomy.subById(p.categoryId, p.subcategoryId!);
    return sub?.families.any((f) => f.toLowerCase().contains(q)) ?? false;
  }

  /// Familles du catalogue correspondant à la recherche, même si aucun
  /// produit ne les porte encore — sert à orienter vers le bon rayon.
  List<FamilyHit> get familySuggestions =>
      CatalogTaxonomy.searchFamilies(_query, limit: 6);

  List<Product> get featured => _all.where((p) => p.badge != null).take(8).toList();

  List<Product> similarTo(Product product, {int limit = 6}) {
    final sameSub = _all.where((p) => p.id != product.id && p.subcategoryId == product.subcategoryId);
    final sameCat = _all.where(
      (p) => p.id != product.id && p.categoryId == product.categoryId && p.subcategoryId != product.subcategoryId,
    );
    return [...sameSub, ...sameCat].take(limit).toList();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final remote = await SupabaseService.fetchProducts();
      // On ne garde le catalogue distant que s'il parle bien la taxonomie
      // matériel : un reliquat d'un ancien catalogue viderait la boutique.
      final knownIds = CatalogTaxonomy.categoryIds;
      final materialRemote =
          remote.where((p) => knownIds.contains(p.categoryId)).toList();
      if (materialRemote.isNotEmpty) {
        _all = materialRemote;
        usingRemote = true;
      } else {
        _all = List.of(MockCatalog.products);
        usingRemote = false;
      }
      try {
        final points = await SupabaseService.fetchPickupPoints();
        if (points.isNotEmpty) pickupPoints = points;
      } catch (_) {}
    } catch (e) {
      usingRemote = false;
      error = e.toString();
      _all = List.of(MockCatalog.products);
    }
    loading = false;
    notifyListeners();
  }

  void setCategory(String? categoryId, {String? subcategoryId}) {
    _selectedCategoryId = categoryId;
    _selectedSubcategoryId = subcategoryId;
    notifyListeners();
  }

  void setSubcategory(String? subcategoryId) {
    _selectedSubcategoryId = subcategoryId;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategoryId = null;
    _selectedSubcategoryId = null;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }
}

class AuthProvider extends ChangeNotifier {
  CustomerProfile? profile;

  AuthProvider() {
    refresh();
    SupabaseService.client.auth.onAuthStateChange.listen((_) => refresh());
  }

  void refresh() {
    profile = SupabaseService.currentProfile();
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    await SupabaseService.signInWithGoogle();
    refresh();
  }

  Future<void> signOut() async {
    await SupabaseService.signOutToGuest();
    refresh();
  }
}

class CheckoutDraft extends ChangeNotifier {
  String name = '';
  String phone = '';
  String email = '';
  DeliveryMode deliveryMode = DeliveryMode.delivery;
  String address = '';
  String city = 'Ouagadougou';
  String? pickupPointId = MockCatalog.pickupPoints.first.id;
  PaymentMethod? paymentMethod;

  void update({
    String? name,
    String? phone,
    String? email,
    DeliveryMode? deliveryMode,
    String? address,
    String? city,
    String? pickupPointId,
    PaymentMethod? paymentMethod,
  }) {
    if (name != null) this.name = name;
    if (phone != null) this.phone = phone;
    if (email != null) this.email = email;
    if (deliveryMode != null) this.deliveryMode = deliveryMode;
    if (address != null) this.address = address;
    if (city != null) this.city = city;
    if (pickupPointId != null) this.pickupPointId = pickupPointId;
    if (paymentMethod != null) this.paymentMethod = paymentMethod;
    notifyListeners();
  }

  void resetPayment() {
    paymentMethod = null;
    notifyListeners();
  }
}

/// Demandes de devis déposées depuis l'app.
///
/// Persistées en local : elles doivent survivre à une coupure réseau, un
/// client au Burkina ne redemandera pas son devis une deuxième fois.
class QuoteProvider extends ChangeNotifier {
  QuoteProvider() {
    _load();
  }

  final List<QuoteRequest> _requests = [];
  static const _key = 'voltify_quotes';
  final _uuid = const Uuid();

  List<QuoteRequest> get requests => List.unmodifiable(_requests);
  bool get isEmpty => _requests.isEmpty;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _requests
        ..clear()
        ..addAll(
          list.map((e) => QuoteRequest.fromJson(e as Map<String, dynamic>)),
        );
      notifyListeners();
      unawaited(_pushPending());
    } catch (_) {}
  }

  /// Rejoue les demandes restées bloquées faute de réseau.
  Future<void> _pushPending() async {
    final pending = _requests.where((q) => !q.synced).toList();
    if (pending.isEmpty) return;
    var changed = false;
    for (final q in pending) {
      if (await _push(q)) changed = true;
    }
    if (changed) {
      notifyListeners();
      await _persist();
    }
  }

  Future<bool> _push(QuoteRequest request) async {
    try {
      await SupabaseService.submitQuote(request);
      request.synced = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_requests.map((q) => q.toJson()).toList()),
    );
  }

  Future<QuoteRequest> submit({
    required Product product,
    required String customerName,
    required String phone,
    String? email,
    String? city,
    String details = '',
  }) async {
    final request = QuoteRequest(
      id: _uuid.v4(),
      productId: product.id,
      productName: product.name,
      categoryId: product.categoryId,
      subcategoryId: product.subcategoryId,
      customerName: customerName,
      phone: phone,
      email: email,
      city: city,
      details: details,
      createdAt: DateTime.now(),
    );
    // On persiste d'abord : une demande perdue sur un réseau capricieux, c'est
    // un client perdu. L'envoi au commerce vient ensuite, et se rejoue au
    // prochain lancement s'il échoue.
    _requests.insert(0, request);
    notifyListeners();
    await _persist();

    if (await _push(request)) {
      notifyListeners();
      await _persist();
    }
    return request;
  }
}
