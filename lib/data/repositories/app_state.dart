import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../mock/mock_catalog.dart';
import '../models/models.dart';

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

  final LoyaltyBalance balance = LoyaltyBalance(lumineux: 180, deco: 95);
  static const _key = 'voltify_loyalty';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    balance.lumineux = map['lumineux'] as int? ?? balance.lumineux;
    balance.deco = map['deco'] as int? ?? balance.deco;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({'lumineux': balance.lumineux, 'deco': balance.deco}),
    );
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
}

class OrderProvider extends ChangeNotifier {
  OrderProvider() {
    _load();
  }

  final List<OrderRecord> _orders = [];
  static const _key = 'voltify_orders';
  final _uuid = const Uuid();

  List<OrderRecord> get orders => List.unmodifiable(_orders);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    // Keep lightweight: only count restored via ids not full products for v1 persistence of totals
    // Full history kept in memory during session; prefs stores summary JSON
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
  }) async {
    final subtotal = items.fold(0, (s, i) => s + i.lineTotal);
    final fee = MockCatalog.computeDeliveryFee(subtotal, deliveryMode);
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
      total: subtotal + fee,
      createdAt: DateTime.now(),
      pointsEarned: pointsEarned,
    );
    _orders.insert(0, order);
    await _persist();
    notifyListeners();
    return order;
  }
}

class CatalogProvider extends ChangeNotifier {
  ProductCategory? _selectedCategory;
  String _query = '';

  ProductCategory? get selectedCategory => _selectedCategory;
  String get query => _query;

  List<Product> get products {
    var list = MockCatalog.byCategory(_selectedCategory);
    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      list = list
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.brand.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  void setCategory(ProductCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
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
