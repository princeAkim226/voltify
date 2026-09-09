import '../mock/catalog_taxonomy.dart';

enum LoyaltyTrack { lumineux, deco }

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    required this.price,
    required this.description,
    this.subcategoryId,
    this.oldPrice,
    this.badge,
    this.rating = 4.5,
    this.reviewCount = 24,
    this.inStock = true,
    this.specs = const [],
    this.pointsReward = 50,
    this.imageUrl,
    this.loyaltyTrack = LoyaltyTrack.lumineux,
    this.saleModeOverride,
  });

  final String id;
  final String name;
  final String brand;
  final String categoryId;
  final String? subcategoryId;
  final int price;
  final int? oldPrice;
  final String description;
  final String? badge;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final List<String> specs;
  final int pointsReward;
  final String? imageUrl;
  final LoyaltyTrack loyaltyTrack;

  /// Force le mode de vente d'un article, sinon la sous-catégorie décide.
  final SaleMode? saleModeOverride;

  /// Panier ou devis. Par défaut, hérité de la sous-catégorie du catalogue.
  SaleMode get saleMode =>
      saleModeOverride ??
      CatalogTaxonomy.saleModeFor(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
      );

  /// Un article sur devis n'a pas de prix ferme : il ne va pas au panier.
  bool get isQuoteOnly => saleMode.isDevis;

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((oldPrice! - price) / oldPrice!) * 100).round();
  }
}

class PromoSlide {
  const PromoSlide({
    required this.id,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    this.tagColor,
    this.tagTextColor,
  });

  final String id;
  final String tag;
  final String title;
  final String subtitle;
  final List<int> gradientColors;
  final int? tagColor;
  final int? tagTextColor;
}

class PickupPoint {
  const PickupPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.hours,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String hours;
}

class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final Product product;
  int quantity;

  int get lineTotal => product.price * quantity;
}

enum DeliveryMode { delivery, pickup }

enum PaymentMethod { orangeMoney, moovMoney, telecelMoney, wave }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.orangeMoney:
        return 'Orange Money';
      case PaymentMethod.moovMoney:
        return 'Moov Money';
      case PaymentMethod.telecelMoney:
        return 'Telecel Money';
      case PaymentMethod.wave:
        return 'Wave';
    }
  }

  String get shortCode {
    switch (this) {
      case PaymentMethod.orangeMoney:
        return 'OM';
      case PaymentMethod.moovMoney:
        return 'MM';
      case PaymentMethod.telecelMoney:
        return 'TM';
      case PaymentMethod.wave:
        return 'WV';
    }
  }
}

class OrderRecord {
  OrderRecord({
    required this.id,
    required this.items,
    required this.customerName,
    required this.phone,
    required this.deliveryMode,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
    this.email,
    this.address,
    this.city,
    this.pickupPointId,
    this.pointsEarned = const {},
    this.loyaltyDiscount = 0,
  });

  final String id;
  final List<CartItem> items;
  final String customerName;
  final String phone;
  final String? email;
  final DeliveryMode deliveryMode;
  final String? address;
  final String? city;
  final String? pickupPointId;
  final PaymentMethod paymentMethod;
  final int subtotal;
  final int deliveryFee;
  final int loyaltyDiscount;
  final int total;
  final DateTime createdAt;
  final Map<LoyaltyTrack, int> pointsEarned;
}

class LoyaltyBalance {
  LoyaltyBalance({this.lumineux = 0, this.deco = 0, this.lumineuxGoal = 500, this.decoGoal = 500});

  int lumineux;
  int deco;
  int lumineuxGoal;
  int decoGoal;

  int of(LoyaltyTrack track) => track == LoyaltyTrack.lumineux ? lumineux : deco;

  double progress(LoyaltyTrack track) {
    final value = of(track);
    final goal = track == LoyaltyTrack.lumineux ? lumineuxGoal : decoGoal;
    if (goal <= 0) return 0;
    return (value / goal).clamp(0.0, 1.0);
  }

  void add(LoyaltyTrack track, int points) {
    if (track == LoyaltyTrack.lumineux) {
      lumineux += points;
    } else {
      deco += points;
    }
  }
}

/// Demande de devis pour un article sur mesure (menuiserie, enseigne, pergola…).
class QuoteRequest {
  QuoteRequest({
    required this.id,
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.customerName,
    required this.phone,
    required this.createdAt,
    this.subcategoryId,
    this.email,
    this.city,
    this.details = '',
    this.synced = false,
  });

  final String id;
  final String productId;
  final String productName;
  final String categoryId;
  final String? subcategoryId;
  final String customerName;
  final String phone;
  final String? email;
  final String? city;

  /// Dimensions, matériau souhaité, délai — le texte libre du client.
  final String details;
  final DateTime createdAt;

  /// La demande est-elle arrivée jusqu'au commerce ?
  /// Faux tant que l'envoi Supabase n'a pas abouti — le réseau au Burkina
  /// coupe souvent, la demande est rejouée au prochain lancement.
  bool synced;

  String get categoryLabel => CatalogTaxonomy.labelFor(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'categoryId': categoryId,
        'subcategoryId': subcategoryId,
        'customerName': customerName,
        'phone': phone,
        'email': email,
        'city': city,
        'details': details,
        'createdAt': createdAt.toIso8601String(),
        'synced': synced,
      };

  factory QuoteRequest.fromJson(Map<String, dynamic> m) => QuoteRequest(
        id: m['id'] as String,
        productId: m['productId'] as String? ?? '',
        productName: m['productName'] as String? ?? '',
        categoryId: m['categoryId'] as String? ?? '',
        subcategoryId: m['subcategoryId'] as String?,
        customerName: m['customerName'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        email: m['email'] as String?,
        city: m['city'] as String?,
        details: m['details'] as String? ?? '',
        createdAt:
            DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        synced: m['synced'] as bool? ?? false,
      );
}

class CustomerProfile {
  const CustomerProfile({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.provider,
  });

  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? provider;

  bool get isLoggedIn => id != null;
}
