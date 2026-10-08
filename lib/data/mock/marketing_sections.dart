import 'package:flutter/material.dart';

/// Les trois piliers marketing Lumi-Dec, présentés en vitrine.
///
/// Ils regroupent les univers techniques déjà en base (`categoryId`) sans
/// renommer ces identifiants — sinon les produits déjà rangés en Supabase
/// disparaîtraient de la boutique.
class MarketingSection {
  const MarketingSection({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.coverAsset,
    required this.galleryAssets,
    required this.categoryIds,
    this.accent = const Color(0xFFC9953A),
  });

  final String id;
  final String number;
  final String title;
  final String subtitle;
  final String body;
  final String coverAsset;
  final List<String> galleryAssets;
  final List<String> categoryIds;
  final Color accent;
}

class MarketingSections {
  MarketingSections._();

  static const sections = <MarketingSection>[
    MarketingSection(
      id: 'eclairage',
      number: '1',
      title: 'Éclairage',
      subtitle: '1.A Architectural & intérieur  ·  1.B LED & décors de plafond',
      body:
          'Spots, strips LED, luminaires, plafonds lumineux et rails magnétiques '
          'pour mettre en valeur chaque volume.',
      coverAsset: 'assets/catalog/1/1_10.jpg',
      galleryAssets: [
        'assets/catalog/1/1_01.jpg',
        'assets/catalog/1/1_02.jpg',
        'assets/catalog/1/1_03.jpg',
        'assets/catalog/1/1_04.jpg',
        'assets/catalog/1/1_05.jpg',
        'assets/catalog/1/1_06.jpg',
        'assets/catalog/1/1_07.jpg',
        'assets/catalog/1/1_08.jpg',
        'assets/catalog/1/1_09.jpg',
        'assets/catalog/1/1_10.jpg',
      ],
      categoryIds: ['eclairage'],
      accent: Color(0xFFE08A1E),
    ),
    MarketingSection(
      id: 'amenagements',
      number: '2',
      title: 'Nos spécialités & aménagements',
      subtitle: 'Meubles TV · Cuisine · Décoration murale · Rangements',
      body:
          'Meuble TV, meuble de cuisine sur-mesure, décoration murale en PVC '
          'ou bambou, rangements adaptés à chaque espace.',
      coverAsset: 'assets/catalog/2/2_01.jpg',
      galleryAssets: [
        'assets/catalog/2/2_01.jpg',
        'assets/catalog/2/2_02.jpg',
        'assets/catalog/2/2_03.jpg',
        'assets/catalog/2/2_04.jpg',
        'assets/catalog/2/2_05.jpg',
        'assets/catalog/2/2_06.jpg',
        'assets/catalog/2/2_07.jpg',
        'assets/catalog/2/2_08.jpg',
        'assets/catalog/2/2_09.jpg',
        'assets/catalog/2/2_10.jpg',
        'assets/catalog/2/2_11.jpg',
        'assets/catalog/2/2_12.jpg',
        'assets/catalog/2/2_13.jpg',
        'assets/catalog/2/2_14.jpg',
        'assets/catalog/2/2_15.jpg',
        'assets/catalog/2/2_16.jpg',
      ],
      categoryIds: ['deco_interieure', 'deco_exterieure', 'menuiserie'],
      accent: Color(0xFF0F6E56),
    ),
    MarketingSection(
      id: 'enseignes',
      number: '3',
      title: 'Enseignes & signalétique',
      subtitle: 'Enseignes 3D · Caissons · Panneaux publicitaires',
      body:
          'Enseignes lumineuses 3D, caissons et panneaux pour façades de '
          'boutiques et bureaux — fabrication et finition premium.',
      coverAsset: 'assets/catalog/3/3_01.jpg',
      galleryAssets: [
        'assets/catalog/3/3_01.jpg',
        'assets/catalog/3/3_02.jpg',
        'assets/catalog/3/3_03.jpg',
        'assets/catalog/3/3_04.jpg',
        'assets/catalog/3/3_05.jpg',
        'assets/catalog/3/3_06.jpg',
        'assets/catalog/3/3_07.jpg',
        'assets/catalog/3/3_08.jpg',
        'assets/catalog/3/3_09.jpg',
        'assets/catalog/3/3_10.jpg',
        'assets/catalog/3/3_11.jpg',
        'assets/catalog/3/3_12.jpg',
      ],
      categoryIds: ['enseignes'],
      accent: Color(0xFF534AB7),
    ),
  ];

  static MarketingSection? byId(String id) {
    for (final s in sections) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Textes de conclusion (page finale du catalogue d'origine).
  static const closingTitle = 'Une finition qui fait la différence';
  static const closingBody =
      'Du plafond à l\'enseigne, nous créons des solutions cohérentes pour '
      'donner une identité forte à chaque espace. Chaque réalisation peut '
      'être adaptée aux dimensions, au style, aux matériaux et au budget '
      'du client.';
  static const closingSlogan = 'Sur mesure · Moderne · Professionnel';
  static const savoirFaire = <String>[
    'Décoration intérieure et extérieure',
    'Plafonds décoratifs et éclairage intégré',
    'Menuiserie moderne et mobilier sur mesure',
    'Meubles TV et habillages muraux',
    'Enseignes lumineuses et lettres 3D',
    'Logos et signalétique personnalisés',
    'Rubans LED, profils LED et éclairage architectural',
    'Installation et finition sur chantier',
  ];
}
