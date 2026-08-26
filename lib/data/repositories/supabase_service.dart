import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../mock/mock_catalog.dart';
import '../models/models.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
    await ensureSession();
  }

  static Future<void> ensureSession() async {
    final auth = client.auth;
    if (auth.currentSession == null) {
      await auth.signInAnonymously();
    }
  }

  static String? get userId => client.auth.currentUser?.id;

  static ProductCategory? _categoryFromId(String? id) {
    if (id == null) return null;
    for (final c in ProductCategory.values) {
      if (c.id == id) return c;
    }
    return null;
  }

  static Product _mapProduct(Map<String, dynamic> row) {
    final specsRaw = row['specs'];
    final specs = specsRaw is List
        ? specsRaw.map((e) => e.toString()).toList()
        : <String>[];
    return Product(
      id: row['id'] as String,
      name: row['name'] as String,
      brand: row['brand'] as String,
      category: _categoryFromId(row['category_id'] as String?) ?? ProductCategory.accessoires,
      price: (row['price'] as num).toInt(),
      oldPrice: row['old_price'] == null ? null : (row['old_price'] as num).toInt(),
      description: (row['description'] as String?) ?? '',
      badge: row['badge'] as String?,
      rating: (row['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (row['review_count'] as num?)?.toInt() ?? 0,
      inStock: row['in_stock'] as bool? ?? true,
      specs: specs,
      pointsReward: (row['points_reward'] as num?)?.toInt() ?? 50,
    );
  }

  static Future<List<Product>> fetchProducts() async {
    final rows = await client.from('products').select().order('name');
    return (rows as List).map((e) => _mapProduct(Map<String, dynamic>.from(e as Map))).toList();
  }

  static Future<List<PickupPoint>> fetchPickupPoints() async {
    final rows = await client.from('pickup_points').select().order('city');
    return (rows as List)
        .map(
          (e) => PickupPoint(
            id: e['id'] as String,
            name: e['name'] as String,
            address: e['address'] as String,
            city: e['city'] as String,
            hours: e['hours'] as String,
          ),
        )
        .toList();
  }

  static Future<LoyaltyBalance> fetchLoyalty() async {
    final uid = userId;
    if (uid == null) return LoyaltyBalance();
    final row = await client.from('loyalty_balances').select().eq('user_id', uid).maybeSingle();
    if (row == null) {
      await client.from('loyalty_balances').upsert({
        'user_id': uid,
        'lumineux': 0,
        'deco': 0,
      });
      return LoyaltyBalance();
    }
    return LoyaltyBalance(
      lumineux: (row['lumineux'] as num?)?.toInt() ?? 0,
      deco: (row['deco'] as num?)?.toInt() ?? 0,
    );
  }

  static Future<void> saveLoyalty(LoyaltyBalance balance) async {
    final uid = userId;
    if (uid == null) return;
    await client.from('loyalty_balances').upsert({
      'user_id': uid,
      'lumineux': balance.lumineux,
      'deco': balance.deco,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> placeOrder(OrderRecord order) async {
    await ensureSession();
    final uid = userId;
    await client.from('orders').insert({
      'id': order.id,
      'user_id': uid,
      'customer_name': order.customerName,
      'phone': order.phone,
      'email': order.email,
      'delivery_mode': order.deliveryMode.name,
      'address': order.address,
      'city': order.city,
      'pickup_point_id': order.pickupPointId,
      'payment_method': order.paymentMethod.name,
      'subtotal': order.subtotal,
      'delivery_fee': order.deliveryFee,
      'total': order.total,
      'pts_lumineux': order.pointsEarned[LoyaltyTrack.lumineux] ?? 0,
      'pts_deco': order.pointsEarned[LoyaltyTrack.deco] ?? 0,
      'created_at': order.createdAt.toIso8601String(),
    });

    if (order.items.isNotEmpty) {
      await client.from('order_items').insert(
        order.items
            .map(
              (i) => {
                'order_id': order.id,
                'product_id': i.product.id,
                'quantity': i.quantity,
                'unit_price': i.product.price,
              },
            )
            .toList(),
      );
    }
  }

  static Future<List<OrderRecord>> fetchOrders(Map<String, Product> productById) async {
    final uid = userId;
    if (uid == null) return [];
    final rows = await client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    return (rows as List).map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      final itemsRaw = (m['order_items'] as List?) ?? [];
      final items = <CartItem>[];
      for (final it in itemsRaw) {
        final row = Map<String, dynamic>.from(it as Map);
        final pid = row['product_id'] as String;
        final product = productById[pid] ?? MockCatalog.byId(pid);
        if (product != null) {
          items.add(CartItem(product: product, quantity: (row['quantity'] as num).toInt()));
        }
      }
      return OrderRecord(
        id: m['id'] as String,
        items: items,
        customerName: m['customer_name'] as String? ?? 'Client',
        phone: m['phone'] as String? ?? '',
        email: m['email'] as String?,
        deliveryMode: (m['delivery_mode'] as String?) == 'pickup'
            ? DeliveryMode.pickup
            : DeliveryMode.delivery,
        address: m['address'] as String?,
        city: m['city'] as String?,
        pickupPointId: m['pickup_point_id'] as String?,
        paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.name == m['payment_method'],
          orElse: () => PaymentMethod.orangeMoney,
        ),
        subtotal: (m['subtotal'] as num?)?.toInt() ?? 0,
        deliveryFee: (m['delivery_fee'] as num?)?.toInt() ?? 0,
        total: (m['total'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now(),
        pointsEarned: {
          LoyaltyTrack.lumineux: (m['pts_lumineux'] as num?)?.toInt() ?? 0,
          LoyaltyTrack.deco: (m['pts_deco'] as num?)?.toInt() ?? 0,
        },
      );
    }).toList();
  }
}
