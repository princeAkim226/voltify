enum LoyaltyTrack { lumineux, deco }

enum ProductCategory {
  smartphones,
  ordinateurs,
  tv,
  audio,
  accessoires,
  eclairage,
  electromenager,
}

extension ProductCategoryX on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.smartphones:
        return 'Smartphones';
      case ProductCategory.ordinateurs:
        return 'Ordinateurs';
      case ProductCategory.tv:
        return 'TV & Vidéo';
      case ProductCategory.audio:
        return 'Audio';
      case ProductCategory.accessoires:
        return 'Accessoires';
      case ProductCategory.eclairage:
        return 'Éclairage LED';
      case ProductCategory.electromenager:
        return 'Électroménager';
    }
  }

  String get id => name;

  LoyaltyTrack get loyaltyTrack {
    switch (this) {
      case ProductCategory.eclairage:
        return LoyaltyTrack.lumineux;
      case ProductCategory.accessoires:
      case ProductCategory.audio:
        return LoyaltyTrack.deco;
      default:
        return LoyaltyTrack.lumineux;
    }
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.description,
    this.oldPrice,
    this.badge,
    this.rating = 4.5,
    this.reviewCount = 24,
    this.inStock = true,
    this.specs = const [],
    this.pointsReward = 50,
  });

  final String id;
  final String name;
  final String brand;
  final ProductCategory category;
  final int price;
  final int? oldPrice;
  final String description;
  final String? badge;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final List<String> specs;
  final int pointsReward;

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((oldPrice! - price) / oldPrice!) * 100).round();
  }

  LoyaltyTrack get loyaltyTrack => category.loyaltyTrack;
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
