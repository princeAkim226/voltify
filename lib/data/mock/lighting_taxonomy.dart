import 'package:flutter/material.dart';

/// Taxonomie Éclairage inspirée de LED Corner (catégories + sous-catégories).
class LightingTaxonomy {
  LightingTaxonomy._();

  static const categories = <LightingCategory>[
    LightingCategory(
      id: 'architectural',
      label: 'Architectural / Façade',
      icon: Icons.apartment_rounded,
      children: [
        LightingSub('facade', 'Éclairage façade'),
        LightingSub('wall_washer', 'Wall washer'),
        LightingSub('aluminum_profile', 'Profilés aluminium'),
        LightingSub('neon_flex', 'Neon Flex'),
      ],
    ),
    LightingCategory(
      id: 'indoor',
      label: 'Indoor / Résidentiel',
      icon: Icons.home_rounded,
      children: [
        LightingSub('ceiling', 'Plafonniers'),
        LightingSub('downlight', 'Down lights'),
        LightingSub('panel', 'Panneaux LED'),
        LightingSub('spot', 'Spots'),
        LightingSub('track', 'Rails / Track lights'),
        LightingSub('chandelier', 'Lustres'),
        LightingSub('pendant', 'Suspensions'),
        LightingSub('cabinet', 'Éclairage meubles'),
        LightingSub('bulbs', 'Ampoules LED'),
        LightingSub('bathroom_mirror', 'Miroirs salle de bain'),
      ],
    ),
    LightingCategory(
      id: 'industrial',
      label: 'Industriel / Entrepôt',
      icon: Icons.warehouse_rounded,
      children: [
        LightingSub('high_bay', 'High bay'),
        LightingSub('flood_industrial', 'Projecteurs'),
        LightingSub('tubes', 'Tubes LED'),
        LightingSub('exit', 'Éclairage de secours'),
        LightingSub('fixtures', 'Luminaires industriels'),
      ],
    ),
    LightingCategory(
      id: 'outdoor',
      label: 'Extérieur',
      icon: Icons.wb_sunny_rounded,
      children: [
        LightingSub('flood', 'Flood lights'),
        LightingSub('street', 'Éclairage rue'),
        LightingSub('wall_outdoor', 'Appliques extérieures'),
        LightingSub('bulkhead', 'Bulkhead'),
      ],
    ),
    LightingCategory(
      id: 'landscape',
      label: 'Paysage / Jardin',
      icon: Icons.yard_rounded,
      children: [
        LightingSub('bollard', 'Bollards'),
        LightingSub('spike', 'Piques de jardin'),
        LightingSub('inground', 'Encastrés sol'),
        LightingSub('step', 'Marches / Step lights'),
        LightingSub('string', 'Guirlandes'),
        LightingSub('palm', 'Éclairage palmier'),
      ],
    ),
    LightingCategory(
      id: 'signage',
      label: 'Signalétique / Publicité',
      icon: Icons.campaign_rounded,
      children: [
        LightingSub('neon_sign', 'Néons publicitaires'),
        LightingSub('programmable', 'LED programmables'),
        LightingSub('strips_rgb', 'Bandes RGB'),
        LightingSub('rope', 'Rope lights'),
        LightingSub('motif', 'Motifs LED'),
      ],
    ),
    LightingCategory(
      id: 'underwater',
      label: 'Sous-marin / Piscine',
      icon: Icons.pool_rounded,
      children: [
        LightingSub('pool', 'Éclairage piscine'),
        LightingSub('underwater_spot', 'Spots submersibles'),
      ],
    ),
    LightingCategory(
      id: 'accessories',
      label: 'Accessoires LED',
      icon: Icons.settings_input_component_rounded,
      children: [
        LightingSub('drivers', 'Alimentations / Drivers'),
        LightingSub('dimmers', 'Dimmers'),
        LightingSub('sensors', 'Capteurs'),
        LightingSub('cables', 'Câbles & connecteurs'),
        LightingSub('holders', 'Douilles & supports'),
        LightingSub('profiles_acc', 'Accessoires profilés'),
      ],
    ),
  ];

  static LightingCategory? byId(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static LightingSub? subById(String categoryId, String subId) {
    final cat = byId(categoryId);
    if (cat == null) return null;
    try {
      return cat.children.firstWhere((s) => s.id == subId);
    } catch (_) {
      return null;
    }
  }

  static String labelFor({required String categoryId, String? subcategoryId}) {
    final cat = byId(categoryId);
    if (cat == null) return categoryId;
    if (subcategoryId == null) return cat.label;
    final sub = subById(categoryId, subcategoryId);
    return sub == null ? cat.label : '${cat.label} · ${sub.label}';
  }
}

class LightingCategory {
  const LightingCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.children,
  });

  final String id;
  final String label;
  final IconData icon;
  final List<LightingSub> children;
}

class LightingSub {
  const LightingSub(this.id, this.label);
  final String id;
  final String label;
}

/// Paliers de fidélité Éclairage (proposition Voltify).
enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum,
}

extension LoyaltyTierX on LoyaltyTier {
  String get label {
    switch (this) {
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Argent';
      case LoyaltyTier.gold:
        return 'Or';
      case LoyaltyTier.platinum:
        return 'Platine';
    }
  }

  int get minPoints {
    switch (this) {
      case LoyaltyTier.bronze:
        return 0;
      case LoyaltyTier.silver:
        return 500;
      case LoyaltyTier.gold:
        return 1000;
      case LoyaltyTier.platinum:
        return 2500;
    }
  }

  /// Réduction checkout en %.
  int get discountPercent {
    switch (this) {
      case LoyaltyTier.bronze:
        return 0;
      case LoyaltyTier.silver:
        return 5;
      case LoyaltyTier.gold:
        return 10;
      case LoyaltyTier.platinum:
        return 15;
    }
  }

  static LoyaltyTier fromPoints(int points) {
    if (points >= LoyaltyTier.platinum.minPoints) return LoyaltyTier.platinum;
    if (points >= LoyaltyTier.gold.minPoints) return LoyaltyTier.gold;
    if (points >= LoyaltyTier.silver.minPoints) return LoyaltyTier.silver;
    return LoyaltyTier.bronze;
  }
}
