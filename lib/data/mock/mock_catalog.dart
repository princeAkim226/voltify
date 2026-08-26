import '../models/models.dart';

class MockCatalog {
  MockCatalog._();

  static const deliveryFee = 1500;
  static const freeDeliveryThreshold = 100000;

  static const promos = [
    PromoSlide(
      id: 'p1',
      tag: 'Offre spéciale',
      title: '2× points Éclairage',
      subtitle: 'Sur tout achat luminaires ce mois',
      gradientColors: [0xFF534AB7, 0xFF7F77DD],
      tagColor: 0xFFFAC775,
      tagTextColor: 0xFF412402,
    ),
    PromoSlide(
      id: 'p2',
      tag: 'Nouveauté',
      title: '-20% Down lights',
      subtitle: 'Gamme indoor résidentiel',
      gradientColors: [0xFF0F6E56, 0xFF1D9E75],
      tagColor: 0xFF9FE1CB,
      tagTextColor: 0xFF04342C,
    ),
    PromoSlide(
      id: 'p3',
      tag: 'Projets',
      title: 'Devis façades & outdoor',
      subtitle: 'Accompagnement chantiers Ouaga & Bobo',
      gradientColors: [0xFFBA7517, 0xFFEF9F27],
      tagColor: 0xFFFFFFFF,
      tagTextColor: 0xFF412402,
    ),
    PromoSlide(
      id: 'p4',
      tag: 'Fidélité',
      title: 'Jusqu’à -15% Platine',
      subtitle: 'Cumulez des points à chaque commande',
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
    const Product(
      id: 'l1',
      name: 'Down Light COB 12W',
      brand: 'Voltify',
      categoryId: 'indoor',
      subcategoryId: 'downlight',
      price: 8500,
      oldPrice: 10000,
      badge: '-15%',
      pointsReward: 40,
      description: 'Spot encastré LED pour salon et bureau. Blanc chaud / neutre.',
      specs: ['12W', '3000K / 4000K', 'Découpe 90mm', 'IP20'],
    ),
    const Product(
      id: 'l2',
      name: 'Panneau LED 60×60 40W',
      brand: 'Philips',
      categoryId: 'indoor',
      subcategoryId: 'panel',
      price: 28000,
      badge: 'Best-seller',
      pointsReward: 70,
      description: 'Panneau plat pour bureaux et commerces, lumière uniforme.',
      specs: ['40W', '4000K', '600×600', 'Driver inclus'],
    ),
    const Product(
      id: 'l3',
      name: 'Track Light 30W',
      brand: 'Osram',
      categoryId: 'indoor',
      subcategoryId: 'track',
      price: 32000,
      pointsReward: 80,
      description: 'Projecteur sur rail pour showrooms et boutiques.',
      specs: ['30W', 'Orientable', 'Rail 1 phase', 'Noir'],
    ),
    const Product(
      id: 'l4',
      name: 'Ampoule LED E27 9W x4',
      brand: 'Philips',
      categoryId: 'indoor',
      subcategoryId: 'bulbs',
      price: 6000,
      pointsReward: 25,
      description: 'Lot économique blanc chaud pour remplacement classique.',
      specs: ['E27', '9W', '3000K', 'Lot de 4'],
    ),
    const Product(
      id: 'l5',
      name: 'Lustre Stellar 48W',
      brand: 'Voltify Déco Light',
      categoryId: 'indoor',
      subcategoryId: 'chandelier',
      price: 125000,
      oldPrice: 145000,
      badge: '-14%',
      pointsReward: 180,
      description: 'Lustre contemporain pour salon / hall.',
      specs: ['48W', 'Dimmable', 'Chrome', 'H 80cm'],
    ),
    const Product(
      id: 'l6',
      name: 'Projecteur Flood 50W IP65',
      brand: 'Osram',
      categoryId: 'outdoor',
      subcategoryId: 'flood',
      price: 18500,
      badge: 'Extérieur',
      pointsReward: 55,
      description: 'Éclairage cour, façade et parking. Résistant à la poussière.',
      specs: ['50W', 'IP65', '6500K', '220V'],
    ),
    const Product(
      id: 'l7',
      name: 'Applique murale outdoor 12W',
      brand: 'Voltify',
      categoryId: 'outdoor',
      subcategoryId: 'wall_outdoor',
      price: 14000,
      pointsReward: 40,
      description: 'Applique étanche pour allées et entrées.',
      specs: ['12W', 'IP54', '3000K', 'Alu'],
    ),
    const Product(
      id: 'l8',
      name: 'Réverbère LED Street 100W',
      brand: 'Voltify Pro',
      categoryId: 'outdoor',
      subcategoryId: 'street',
      price: 98000,
      pointsReward: 200,
      description: 'Éclairage voirie et grands espaces.',
      specs: ['100W', 'IP66', '5000K', 'Photocellule option'],
    ),
    const Product(
      id: 'l9',
      name: 'Bollard jardin 10W',
      brand: 'Govee',
      categoryId: 'landscape',
      subcategoryId: 'bollard',
      price: 22000,
      pointsReward: 50,
      description: 'Borne lumineuse pour chemins et terrasses.',
      specs: ['10W', 'IP65', '3000K', 'H 60cm'],
    ),
    const Product(
      id: 'l10',
      name: 'Spike Light 7W',
      brand: 'Voltify',
      categoryId: 'landscape',
      subcategoryId: 'spike',
      price: 9500,
      pointsReward: 30,
      description: 'Pique orientable pour arbustes et massifs.',
      specs: ['7W', 'IP65', '3000K', 'Pique acier'],
    ),
    const Product(
      id: 'l11',
      name: 'Step Light encastré 3W',
      brand: 'Osram',
      categoryId: 'landscape',
      subcategoryId: 'step',
      price: 7500,
      pointsReward: 25,
      description: 'Éclairage de marches sécurisé et discret.',
      specs: ['3W', 'IP67', '3000K', 'Alu'],
    ),
    const Product(
      id: 'l12',
      name: 'Guirlande LED 10m',
      brand: 'Voltify',
      categoryId: 'landscape',
      subcategoryId: 'string',
      price: 12000,
      badge: 'Fêtes',
      pointsReward: 35,
      description: 'Guirlande pour terrasses et événements.',
      specs: ['10 m', 'IP44', 'Blanc chaud', 'Extensible'],
    ),
    const Product(
      id: 'l13',
      name: 'Wall Washer façade 36W',
      brand: 'Voltify Pro',
      categoryId: 'architectural',
      subcategoryId: 'wall_washer',
      price: 65000,
      pointsReward: 120,
      description: 'Lavage de façade pour bâtiments et hôtels.',
      specs: ['36W', 'RGBW', 'IP65', 'DMX option'],
    ),
    const Product(
      id: 'l14',
      name: 'Profilé aluminium 2m + diffuseur',
      brand: 'Voltify',
      categoryId: 'architectural',
      subcategoryId: 'aluminum_profile',
      price: 8500,
      pointsReward: 30,
      description: 'Profilé pour bandes LED encastrées ou en saillie.',
      specs: ['2 m', 'Alu anodisé', 'Diffuseur opale', 'Clips'],
    ),
    const Product(
      id: 'l15',
      name: 'Neon Flex IP65 5m',
      brand: 'Govee',
      categoryId: 'architectural',
      subcategoryId: 'neon_flex',
      price: 28000,
      oldPrice: 35000,
      badge: '-20%',
      pointsReward: 60,
      description: 'Néon flexible pour contours et enseignes.',
      specs: ['5 m', 'IP65', 'RGB', 'Alimentation 12V'],
    ),
    const Product(
      id: 'l16',
      name: 'High Bay UFO 150W',
      brand: 'Voltify Pro',
      categoryId: 'industrial',
      subcategoryId: 'high_bay',
      price: 78000,
      pointsReward: 150,
      description: 'Éclairage entrepôts et ateliers haute hauteur.',
      specs: ['150W', 'IP65', '5000K', '120°'],
    ),
    const Product(
      id: 'l17',
      name: 'Tube LED T8 18W',
      brand: 'Philips',
      categoryId: 'industrial',
      subcategoryId: 'tubes',
      price: 4500,
      pointsReward: 20,
      description: 'Remplacement fluorescent ateliers et bureaux.',
      specs: ['18W', '120 cm', '4000K', 'G13'],
    ),
    const Product(
      id: 'l18',
      name: 'Bloc secours Exit LED',
      brand: 'Voltify Pro',
      categoryId: 'industrial',
      subcategoryId: 'exit',
      price: 16000,
      pointsReward: 45,
      description: 'Signalétique de sortie de secours double face.',
      specs: ['LED', 'Batterie 3h', 'IP20', 'Double face'],
    ),
    const Product(
      id: 'l19',
      name: 'Bande LED RGB 5m',
      brand: 'Govee',
      categoryId: 'signage',
      subcategoryId: 'strips_rgb',
      price: 18000,
      badge: 'RGB',
      pointsReward: 45,
      description: 'Bande connectée pour ambiance et vitrines.',
      specs: ['5 m', 'RGBIC', 'App', '12V'],
    ),
    const Product(
      id: 'l20',
      name: 'Enseigne néon “Open”',
      brand: 'Voltify Sign',
      categoryId: 'signage',
      subcategoryId: 'neon_sign',
      price: 45000,
      pointsReward: 90,
      description: 'Néon publicitaire prêt à poser pour commerces.',
      specs: ['USB / 12V', 'Acrylique', 'Interrupteur', 'Chaîne'],
    ),
    const Product(
      id: 'l21',
      name: 'Rope Light 10m blanc chaud',
      brand: 'Voltify',
      categoryId: 'signage',
      subcategoryId: 'rope',
      price: 15000,
      pointsReward: 40,
      description: 'Corde lumineuse pour décorations et festons.',
      specs: ['10 m', 'IP44', '3000K', 'Coupe possible'],
    ),
    const Product(
      id: 'l22',
      name: 'Spot piscine 12W IP68',
      brand: 'Voltify Aqua',
      categoryId: 'underwater',
      subcategoryId: 'pool',
      price: 38000,
      pointsReward: 85,
      description: 'Éclairage submersible pour bassins et piscines.',
      specs: ['12W', 'IP68', 'RGB', '12V DC'],
    ),
    const Product(
      id: 'l23',
      name: 'Projecteur sous-marin 10W',
      brand: 'Voltify Aqua',
      categoryId: 'underwater',
      subcategoryId: 'underwater_spot',
      price: 42000,
      pointsReward: 90,
      description: 'Spot étanche pour fontaines et plans d’eau.',
      specs: ['10W', 'IP68', '3000K', 'Acier inox'],
    ),
    const Product(
      id: 'l24',
      name: 'Driver LED 12V 100W',
      brand: 'Mean Well',
      categoryId: 'accessories',
      subcategoryId: 'drivers',
      price: 22000,
      pointsReward: 50,
      description: 'Alimentation constante tension pour bandes et modules.',
      specs: ['12V', '100W', 'IP20', 'Protections'],
    ),
    const Product(
      id: 'l25',
      name: 'Dimmer mural LED 220V',
      brand: 'Voltify',
      categoryId: 'accessories',
      subcategoryId: 'dimmers',
      price: 9500,
      pointsReward: 30,
      description: 'Variateur compatible LED pour intensité réglable.',
      specs: ['220V', 'Trailing edge', '200W max', 'Blanc'],
    ),
    const Product(
      id: 'l26',
      name: 'Kit connecteurs bande LED',
      brand: 'Voltify',
      categoryId: 'accessories',
      subcategoryId: 'cables',
      price: 3500,
      pointsReward: 15,
      description: 'Connecteurs, clips et câbles pour installation rapide.',
      specs: ['10 mm', 'Sans soudure', 'Lot 10 pcs'],
    ),
    const Product(
      id: 'l27',
      name: 'Spot COB 15W salon',
      brand: 'Voltify',
      categoryId: 'indoor',
      subcategoryId: 'spot',
      price: 11000,
      pointsReward: 35,
      description: 'Spot directionnel pour mise en valeur.',
      specs: ['15W', '36°', '3000K', 'Orientable'],
    ),
    const Product(
      id: 'l28',
      name: 'Éclairage placard 1W',
      brand: 'Voltify',
      categoryId: 'indoor',
      subcategoryId: 'cabinet',
      price: 4500,
      pointsReward: 20,
      description: 'Mini spot pour meubles et vitrines.',
      specs: ['1W', 'DC 12V', '3000K', 'Alu'],
    ),
  ];

  static List<Product> byCategory(String? categoryId, {String? subcategoryId}) {
    var list = products;
    if (categoryId != null) {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }
    if (subcategoryId != null) {
      list = list.where((p) => p.subcategoryId == subcategoryId).toList();
    }
    return list;
  }

  static Product? byId(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Product> similarTo(Product product, {int limit = 6}) {
    final sameSub = products
        .where((p) => p.id != product.id && p.subcategoryId == product.subcategoryId)
        .toList();
    final sameCat = products
        .where(
          (p) =>
              p.id != product.id &&
              p.categoryId == product.categoryId &&
              p.subcategoryId != product.subcategoryId,
        )
        .toList();
    return [...sameSub, ...sameCat].take(limit).toList();
  }

  static List<Product> featured() => products.where((p) => p.badge != null).take(8).toList();

  static int computeDeliveryFee(int subtotal, DeliveryMode mode) {
    if (mode == DeliveryMode.pickup) return 0;
    if (subtotal >= freeDeliveryThreshold) return 0;
    return deliveryFee;
  }
}
