import '../models/models.dart';

class MockCatalog {
  MockCatalog._();

  static const deliveryFee = 1500;
  static const freeDeliveryThreshold = 100000;

  static const promos = [
    PromoSlide(
      id: 'p1',
      tag: 'Offre spéciale',
      title: 'Gagnez 2× plus de points',
      subtitle: 'Sur tout achat électronique ce mois',
      gradientColors: [0xFF534AB7, 0xFF7F77DD],
      tagColor: 0xFFFAC775,
      tagTextColor: 0xFF412402,
    ),
    PromoSlide(
      id: 'p2',
      tag: 'Nouveauté',
      title: '-20% éclairage LED',
      subtitle: 'Gamme complète en promo',
      gradientColors: [0xFF0F6E56, 0xFF1D9E75],
      tagColor: 0xFF9FE1CB,
      tagTextColor: 0xFF04342C,
    ),
    PromoSlide(
      id: 'p3',
      tag: 'Exclusif',
      title: 'Bonus déco +100 pts',
      subtitle: 'Audio & accessoires sélectionnés',
      gradientColors: [0xFFBA7517, 0xFFEF9F27],
      tagColor: 0xFFFFFFFF,
      tagTextColor: 0xFF412402,
    ),
    PromoSlide(
      id: 'p4',
      tag: 'Flash',
      title: 'Smartphones dès 89 000',
      subtitle: 'Livraison Ouaga & Bobo',
      gradientColors: [0xFF1A1730, 0xFF534AB7],
      tagColor: 0xFFEAF3DE,
      tagTextColor: 0xFF3B6D11,
    ),
  ];

  static const pickupPoints = [
    PickupPoint(
      id: 'pk1',
      name: 'Voltify Ouaga Centre',
      address: 'Avenue Kwame Nkrumah, près du Rond-point des Nations',
      city: 'Ouagadougou',
      hours: 'Lun–Sam 9h–19h',
    ),
    PickupPoint(
      id: 'pk2',
      name: 'Voltify Bobo Dioulasso',
      address: 'Secteur 4, Avenue de la Révolution',
      city: 'Bobo-Dioulasso',
      hours: 'Lun–Sam 9h–18h30',
    ),
  ];

  static final products = <Product>[
    // Smartphones
    const Product(
      id: 's1',
      name: 'Galaxy A35 5G 128 Go',
      brand: 'Samsung',
      category: ProductCategory.smartphones,
      price: 189000,
      oldPrice: 219000,
      badge: '-14%',
      rating: 4.6,
      reviewCount: 128,
      pointsReward: 120,
      description:
          'Écran Super AMOLED 6,6", 50 MP, batterie 5000 mAh. Idéal quotidien au Burkina avec bonne autonomie.',
      specs: ['6,6" AMOLED', '128 Go / 8 Go', '50 MP', '5000 mAh', '5G'],
    ),
    const Product(
      id: 's2',
      name: 'Redmi Note 13 Pro',
      brand: 'Xiaomi',
      category: ProductCategory.smartphones,
      price: 165000,
      oldPrice: 185000,
      badge: 'Promo',
      rating: 4.5,
      reviewCount: 96,
      pointsReward: 110,
      description: 'Capteur 200 MP, charge rapide 67 W, design premium pour photos et réseaux.',
      specs: ['6,67" AMOLED', '256 Go / 8 Go', '200 MP', 'Charge 67W'],
    ),
    const Product(
      id: 's3',
      name: 'iPhone 13 128 Go',
      brand: 'Apple',
      category: ProductCategory.smartphones,
      price: 425000,
      rating: 4.8,
      reviewCount: 210,
      pointsReward: 250,
      description: 'Performance A15, photos excellentes, écosystème iOS. Reconditionné grade A.',
      specs: ['6,1" OLED', '128 Go', 'Double caméra', 'Face ID'],
    ),
    const Product(
      id: 's4',
      name: 'Tecno Camon 30',
      brand: 'Tecno',
      category: ProductCategory.smartphones,
      price: 99000,
      oldPrice: 115000,
      badge: 'Best-seller',
      rating: 4.3,
      reviewCount: 74,
      pointsReward: 70,
      description: 'Excellent rapport qualité-prix, grand écran et batterie longue durée.',
      specs: ['6,78"', '256 Go / 8 Go', '50 MP', '5000 mAh'],
    ),
    const Product(
      id: 's5',
      name: 'Infinix Hot 40 Pro',
      brand: 'Infinix',
      category: ProductCategory.smartphones,
      price: 89000,
      badge: 'Dès 89k',
      rating: 4.2,
      reviewCount: 55,
      pointsReward: 60,
      description: 'Entrée de gamme solide pour appels, WhatsApp et streaming.',
      specs: ['6,78"', '128 Go / 8 Go', '108 MP', '5000 mAh'],
    ),

    // Ordinateurs
    const Product(
      id: 'o1',
      name: 'Laptop IdeaPad 15 i5',
      brand: 'Lenovo',
      category: ProductCategory.ordinateurs,
      price: 385000,
      oldPrice: 420000,
      badge: '-8%',
      rating: 4.4,
      reviewCount: 42,
      pointsReward: 200,
      description: 'Ultrabook polyvalent pour études et bureau. SSD rapide, clavier confortable.',
      specs: ['15,6" FHD', 'i5 12e gén', '16 Go RAM', '512 Go SSD'],
    ),
    const Product(
      id: 'o2',
      name: 'MacBook Air M1 256 Go',
      brand: 'Apple',
      category: ProductCategory.ordinateurs,
      price: 650000,
      rating: 4.9,
      reviewCount: 88,
      pointsReward: 350,
      description: 'Silence, autonomie exceptionnelle et performance M1 pour créatifs.',
      specs: ['13,3" Retina', 'Apple M1', '8 Go', '256 Go SSD'],
    ),
    const Product(
      id: 'o3',
      name: 'HP Pavilion x360',
      brand: 'HP',
      category: ProductCategory.ordinateurs,
      price: 445000,
      rating: 4.3,
      reviewCount: 31,
      pointsReward: 220,
      description: 'Convertible tactile 2-en-1, parfait pour présentations et notes.',
      specs: ['14" tactile', 'i5', '16 Go', '512 Go SSD'],
    ),
    const Product(
      id: 'o4',
      name: 'Chromebook Acer 14',
      brand: 'Acer',
      category: ProductCategory.ordinateurs,
      price: 175000,
      badge: 'Étudiants',
      rating: 4.1,
      reviewCount: 27,
      pointsReward: 90,
      description: 'Léger, rapide pour Google Workspace et navigation web.',
      specs: ['14" FHD', '8 Go', '128 Go', 'ChromeOS'],
    ),

    // TV
    const Product(
      id: 't1',
      name: 'Smart TV 43" 4K UHD',
      brand: 'Samsung',
      category: ProductCategory.tv,
      price: 245000,
      oldPrice: 275000,
      badge: '4K',
      rating: 4.5,
      reviewCount: 63,
      pointsReward: 150,
      description: 'Image nette, apps streaming intégrées (YouTube, Netflix).',
      specs: ['43" 4K', 'Smart Hub', 'HDR', '3× HDMI'],
    ),
    const Product(
      id: 't2',
      name: 'Smart TV 55" QLED',
      brand: 'Samsung',
      category: ProductCategory.tv,
      price: 520000,
      rating: 4.7,
      reviewCount: 41,
      pointsReward: 280,
      description: 'Couleurs QLED éclatantes pour cinéma et sport à la maison.',
      specs: ['55" QLED', '4K HDR', 'Gaming Hub', 'Dolby Atmos'],
    ),
    const Product(
      id: 't3',
      name: 'Android TV 32" HD',
      brand: 'TCL',
      category: ProductCategory.tv,
      price: 95000,
      badge: 'Compact',
      rating: 4.2,
      reviewCount: 50,
      pointsReward: 65,
      description: 'Parfait chambre ou studio, Google TV inclus.',
      specs: ['32" HD', 'Android TV', 'Wi-Fi', '2× HDMI'],
    ),
    const Product(
      id: 't4',
      name: 'TV LED 50" Full HD',
      brand: 'Hisense',
      category: ProductCategory.tv,
      price: 198000,
      rating: 4.3,
      reviewCount: 36,
      pointsReward: 120,
      description: 'Grand écran abordable pour famille et matchs CAN.',
      specs: ['50" FHD', 'Smart', 'USB media', 'HDMI'],
    ),

    // Audio
    const Product(
      id: 'a1',
      name: 'AirPods Pro (2e gén)',
      brand: 'Apple',
      category: ProductCategory.audio,
      price: 185000,
      rating: 4.8,
      reviewCount: 112,
      pointsReward: 100,
      description: 'Réduction de bruit active, audio spatial, boîtier MagSafe.',
      specs: ['ANC', 'Spatial Audio', 'IPX4', 'USB-C'],
    ),
    const Product(
      id: 'a2',
      name: 'Soundcore Life Q30',
      brand: 'Anker',
      category: ProductCategory.audio,
      price: 52000,
      oldPrice: 65000,
      badge: '-20%',
      rating: 4.6,
      reviewCount: 89,
      pointsReward: 55,
      description: 'Casque Bluetooth ANC, autonomie jusqu’à 40 h.',
      specs: ['ANC', '40 h', 'Bluetooth 5', 'Pliable'],
    ),
    const Product(
      id: 'a3',
      name: 'Enceinte Flip 6',
      brand: 'JBL',
      category: ProductCategory.audio,
      price: 78000,
      rating: 4.7,
      reviewCount: 77,
      pointsReward: 70,
      description: 'Son puissant, étanche IP67, idéale terrasses et fêtes.',
      specs: ['IP67', '12 h', 'PartyBoost', 'USB-C'],
    ),
    const Product(
      id: 'a4',
      name: 'Barre de son 2.1',
      brand: 'Sony',
      category: ProductCategory.audio,
      price: 135000,
      rating: 4.4,
      reviewCount: 29,
      pointsReward: 85,
      description: 'Améliore nettement le son TV films et séries.',
      specs: ['2.1', 'Bluetooth', 'HDMI ARC', 'USB'],
    ),

    // Accessoires
    const Product(
      id: 'x1',
      name: 'Chargeur GaN 65W',
      brand: 'Baseus',
      category: ProductCategory.accessoires,
      price: 18500,
      badge: 'Essentiel',
      rating: 4.5,
      reviewCount: 140,
      pointsReward: 25,
      description: 'Charge rapide multi-ports pour laptop et téléphone.',
      specs: ['65W GaN', '2× USB-C', '1× USB-A', 'Compact'],
    ),
    const Product(
      id: 'x2',
      name: 'Powerbank 20000 mAh',
      brand: 'Xiaomi',
      category: ProductCategory.accessoires,
      price: 22000,
      rating: 4.4,
      reviewCount: 201,
      pointsReward: 30,
      description: 'Ne restez plus sans batterie en déplacement.',
      specs: ['20000 mAh', '18W', '2 sorties', 'LED'],
    ),
    const Product(
      id: 'x3',
      name: 'Coque + verre Galaxy A35',
      brand: 'Spigen',
      category: ProductCategory.accessoires,
      price: 8500,
      rating: 4.3,
      reviewCount: 64,
      pointsReward: 15,
      description: 'Protection antichoc transparente + film trempé.',
      specs: ['Antichoc', 'Transparent', 'Verre 9H'],
    ),
    const Product(
      id: 'x4',
      name: 'Clavier + souris sans fil',
      brand: 'Logitech',
      category: ProductCategory.accessoires,
      price: 32000,
      rating: 4.5,
      reviewCount: 48,
      pointsReward: 35,
      description: 'Combo bureau silencieux, récepteur USB unique.',
      specs: ['2,4 GHz', 'Silencieux', 'AA', 'AZERTY'],
    ),

    // Éclairage LED
    const Product(
      id: 'e1',
      name: 'Kit bande LED RGB 5m',
      brand: 'Govee',
      category: ProductCategory.eclairage,
      price: 28000,
      oldPrice: 35000,
      badge: '-20%',
      rating: 4.6,
      reviewCount: 93,
      pointsReward: 40,
      description: 'Ambiance connectée via app, millions de couleurs.',
      specs: ['5 m', 'RGBIC', 'App Wi-Fi', 'Alim 12V'],
    ),
    const Product(
      id: 'e2',
      name: 'Ampoules LED E27 x4',
      brand: 'Philips',
      category: ProductCategory.eclairage,
      price: 12000,
      rating: 4.5,
      reviewCount: 120,
      pointsReward: 20,
      description: 'Éclairage économique, lumière blanc chaud 3000K.',
      specs: ['E27', '9W', '3000K', 'Lot de 4'],
    ),
    const Product(
      id: 'e3',
      name: 'Lampe de bureau LED',
      brand: 'Xiaomi',
      category: ProductCategory.eclairage,
      price: 24500,
      rating: 4.4,
      reviewCount: 57,
      pointsReward: 30,
      description: 'Bras flexible, intensité réglable, anti-fatigue visuelle.',
      specs: ['USB-C', 'Dimmable', 'Bras flexible'],
    ),
    const Product(
      id: 'e4',
      name: 'Projecteur LED 50W',
      brand: 'Osram',
      category: ProductCategory.eclairage,
      price: 18500,
      badge: 'Extérieur',
      rating: 4.3,
      reviewCount: 38,
      pointsReward: 25,
      description: 'Éclairage cour / boutique, IP65 résistant.',
      specs: ['50W', 'IP65', '6500K', '220V'],
    ),

    // Électroménager
    const Product(
      id: 'm1',
      name: 'Ventilateur pedestal 16"',
      brand: 'Binatone',
      category: ProductCategory.electromenager,
      price: 35000,
      rating: 4.2,
      reviewCount: 81,
      pointsReward: 40,
      description: '3 vitesses, oscillation, indispensable en saison chaude.',
      specs: ['16"', '3 vitesses', 'Oscillation', 'Minuterie'],
    ),
    const Product(
      id: 'm2',
      name: 'Réfrigérateur 150L',
      brand: 'Hisense',
      category: ProductCategory.electromenager,
      price: 185000,
      oldPrice: 205000,
      badge: 'Promo',
      rating: 4.4,
      reviewCount: 45,
      pointsReward: 130,
      description: 'Compact et économe, parfait appartement.',
      specs: ['150 L', 'Classe A+', 'Congélateur', 'Silent'],
    ),
    const Product(
      id: 'm3',
      name: 'Micro-ondes 20L',
      brand: 'Samsung',
      category: ProductCategory.electromenager,
      price: 68000,
      rating: 4.3,
      reviewCount: 52,
      pointsReward: 55,
      description: 'Décongélation rapide, plateaux rotatif, commandes simples.',
      specs: ['20 L', '700W', '5 niveaux', 'Timer'],
    ),
    const Product(
      id: 'm4',
      name: 'Fer à vapeur céramique',
      brand: 'Philips',
      category: ProductCategory.electromenager,
      price: 28000,
      rating: 4.5,
      reviewCount: 66,
      pointsReward: 30,
      description: 'Glisse facile, anti-calcaire pour eau du robinet.',
      specs: ['2400W', 'Céramique', 'Anti-goutte'],
    ),
    const Product(
      id: 'm5',
      name: 'Mixeur blender 1,5L',
      brand: 'Moulinex',
      category: ProductCategory.electromenager,
      price: 42000,
      rating: 4.4,
      reviewCount: 39,
      pointsReward: 35,
      description: 'Smoothies et sauces, bol verre résistant.',
      specs: ['1,5 L', '500W', 'Verre', '2 vitesses'],
    ),
  ];

  static List<Product> byCategory(ProductCategory? category) {
    if (category == null) return products;
    return products.where((p) => p.category == category).toList();
  }

  static List<Product> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.brand.toLowerCase().contains(q) ||
              p.category.label.toLowerCase().contains(q),
        )
        .toList();
  }

  static Product? byId(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Product> similarTo(Product product, {int limit = 6}) {
    final sameBrand = products
        .where((p) => p.id != product.id && p.brand == product.brand)
        .toList();
    final sameCategory = products
        .where((p) => p.id != product.id && p.category == product.category && p.brand != product.brand)
        .toList();
    return [...sameBrand, ...sameCategory].take(limit).toList();
  }

  static List<Product> featured() => products.where((p) => p.badge != null).take(8).toList();

  static int computeDeliveryFee(int subtotal, DeliveryMode mode) {
    if (mode == DeliveryMode.pickup) return 0;
    if (subtotal >= freeDeliveryThreshold) return 0;
    return deliveryFee;
  }
}
