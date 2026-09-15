import 'package:flutter/material.dart';

/// Mode de vente d'une famille de produits.
///
/// Le matériel courant (LED, quincaillerie, consommables, outillage) part au
/// panier avec un prix ferme. Le sur-mesure (menuiserie, enseignes, pergolas,
/// vitrerie posée) ne se chiffre qu'après visite : il part en demande de devis.
enum SaleMode { panier, devis }

extension SaleModeX on SaleMode {
  bool get isDevis => this == SaleMode.devis;

  String get label => this == SaleMode.devis ? 'Sur devis' : 'Vente directe';

  String get actionLabel =>
      this == SaleMode.devis ? 'Demander un devis' : 'Ajouter au panier';
}

/// Taxonomie matériel Voltify.
///
/// Source : catalogue de matériel « Décoration · Menuiserie · Enseignes »
/// (8 univers, 35 sous-catégories, ~400 familles de produits).
///
/// Les familles ne sont pas un troisième niveau de navigation : elles servent
/// de vocabulaire de recherche et d'aide à la saisie côté admin.
class CatalogTaxonomy {
  CatalogTaxonomy._();

  static const categories = <MaterialCategory>[
    // L'éclairage était dispersé dans la décoration — un rayon ici, un autre
    // là — alors que c'est l'une des deux pistes de fidélité de la boutique.
    // Un client qui cherche un projecteur de piscine ne pense pas à regarder
    // sous « Décoration extérieure ».
    MaterialCategory(
      id: 'eclairage',
      label: 'Éclairage',
      icon: Icons.lightbulb_rounded,
      gradient: [Color(0xFFE08A1E), Color(0xFFF5C26B)],
      children: [
        MaterialSub(
          id: 'eclairage_interieur',
          label: 'Éclairage intérieur',
          families: [
            'Spots LED',
            'Downlights',
            'Panneaux LED',
            'Plafonniers LED',
            'Éclairage linéaire',
            'Lampes murales',
            'Lampes de sol',
            'Lustres',
            'Suspensions',
            'Appliques',
            'Lampadaires',
            'Lampes de table',
            'Miroirs LED',
            'Éclairage indirect',
            'Spots sur rail',
            'Éclairage de meuble',
          ],
        ),
        MaterialSub(
          id: 'eclairage_exterieur',
          label: 'Éclairage extérieur',
          families: [
            'Projecteurs',
            'Projecteurs LED',
            'Appliques extérieures',
            'Hublots',
            'Réverbères',
            'Éclairage solaire',
            'Éclairage LED extérieur',
            'Projecteurs de stade',
            'Mâts d\'éclairage',
            'Éclairage de parking',
          ],
        ),
        MaterialSub(
          id: 'eclairage_jardin',
          label: 'Éclairage de jardin',
          families: [
            'Bornes et bollards',
            'Balises de jardin',
            'Encastrés de sol',
            'Éclairage de marches',
            'Guirlandes',
            'Piquets de jardin',
            'Spots de sol',
            'Éclairage d\'allée',
          ],
        ),
        MaterialSub(
          id: 'eclairage_facade',
          label: 'Éclairage architectural et façade',
          families: [
            'Éclairage de façade',
            'Lèche-murs',
            'Projecteurs architecturaux',
            'Éclairage linéaire extérieur',
            'Wall washers',
            'Éclairage de mise en valeur',
          ],
        ),
        MaterialSub(
          id: 'eclairage_industriel',
          label: 'Éclairage industriel et hangar',
          families: [
            'High bay',
            'Cloches industrielles',
            'Tubes LED',
            'Réglettes étanches',
            'Blocs de secours',
            'Luminaires industriels',
            'Éclairage d\'atelier',
          ],
        ),
        MaterialSub(
          id: 'eclairage_immerge',
          label: 'Éclairage sous-marin et piscine',
          families: [
            'Éclairage de piscine',
            'Projecteurs submersibles',
            'Spots immergés',
            'Rubans étanches',
            'Éclairage de fontaine',
          ],
        ),
        MaterialSub(
          id: 'eclairage_enseignes',
          label: 'Éclairage d\'enseignes',
          families: [
            'Modules LED',
            'Néon LED',
            'Néon flexible',
            'Rétroéclairage',
            'Lettres lumineuses',
            'Éclairage de caisson',
          ],
        ),
        MaterialSub(
          id: 'rubans_led',
          label: 'Rubans et profilés LED',
          families: [
            'Ruban LED 12 V',
            'Ruban LED 24 V',
            'LED RGB',
            'LED RGBW',
            'LED COB',
            'Profilé aluminium LED',
            'Diffuseurs',
            'Embouts et clips',
          ],
        ),
        MaterialSub(
          id: 'eclairage_accessoires',
          label: 'Accessoires et alimentation',
          families: [
            'Transformateur',
            'Driver LED',
            'Alimentation 12 V',
            'Alimentation 24 V',
            'Alimentation étanche',
            'Contrôleur RGB',
            'Variateur',
            'Télécommandes',
            'Détecteurs de mouvement',
            'Connecteurs LED',
          ],
        ),
      ],
    ),
    MaterialCategory(
      id: 'deco_interieure',
      label: 'Décoration intérieure',
      icon: Icons.weekend_rounded,
      gradient: [Color(0xFF534AB7), Color(0xFF9B94E8)],
      children: [
        MaterialSub(
          id: 'revetements_muraux',
          label: 'Revêtements muraux',
          families: [
            'Papier peint',
            'Papier peint 3D',
            'Panneaux muraux PVC',
            'Panneaux WPC',
            'Panneaux MDF décoratifs',
            'Panneaux acoustiques',
            'Tasseaux bois décoratifs',
            'Claustra décoratif',
            'Parement mural',
            'Pierre décorative',
            'Marbre',
            'Granit',
            'Quartz',
            'Carrelage mural',
            'Mosaïque',
            'Enduit décoratif',
            'Béton ciré',
            'Peinture décorative',
            'Peinture effet marbre',
            'Peinture effet béton',
            'Peinture métallisée',
            'Peinture texturée',
          ],
        ),
        MaterialSub(
          id: 'plafonds',
          label: 'Plafonds',
          saleMode: SaleMode.devis,
          families: [
            'Faux plafond en placoplâtre',
            'Faux plafond PVC',
            'Plafond bois',
            'Plafond MDF',
            'Plafond WPC',
            'Plafond tendu',
            'Dalles acoustiques',
            'Corniches décoratives',
            'Rosaces',
            'Profilés LED',
            'Spots encastrables',
            'Bandes LED',
            'Suspensions décoratives',
          ],
        ),
        MaterialSub(
          id: 'sols',
          label: 'Sols',
          families: [
            'Carrelage',
            'Grès cérame',
            'Marbre',
            'Granit',
            'Parquet',
            'Sol stratifié',
            'Vinyle',
            'PVC',
            'Moquette',
            'Béton ciré',
            'Résine époxy',
            'Tapis décoratifs',
          ],
        ),
        MaterialSub(
          id: 'mur_tv',
          label: 'Décoration TV / mur TV',
          saleMode: SaleMode.devis,
          families: [
            'Panneaux MDF',
            'Tasseaux bois',
            'Marbre',
            'Quartz',
            'Pierre naturelle',
            'Panneaux PVC',
            'WPC',
            'Éclairage LED',
            'Profilés aluminium',
            'Meubles TV suspendus',
            'Niches murales',
            'Étagères',
            'Claustras',
          ],
        ),
        MaterialSub(
          id: 'miroiterie',
          label: 'Miroiterie et verre',
          families: [
            'Miroir classique',
            'Miroir fumé',
            'Miroir bronze',
            'Miroir gris',
            'Miroir LED',
            'Verre clair',
            'Verre fumé',
            'Verre teinté',
            'Verre feuilleté',
            'Verre trempé',
            'Verre décoratif',
            'Verre cannelé',
            'Verre armé',
          ],
        ),
        MaterialSub(
          id: 'ameublement',
          label: 'Décoration et ameublement',
          families: [
            'Canapés',
            'Fauteuils',
            'Tables basses',
            'Tables à manger',
            'Chaises',
            'Consoles',
            'Buffets',
            'Meubles TV',
            'Étagères',
            'Bibliothèques',
            'Lits',
            'Chevets',
            'Dressing',
            'Rideaux',
            'Stores',
            'Tapis',
            'Coussins',
            'Décoration murale',
          ],
        ),
      ],
    ),
    MaterialCategory(
      id: 'deco_exterieure',
      label: 'Décoration extérieure',
      icon: Icons.deck_rounded,
      gradient: [Color(0xFFBA7517), Color(0xFFEF9F27)],
      children: [
        MaterialSub(
          id: 'facades',
          label: 'Façades',
          saleMode: SaleMode.devis,
          families: [
            'Peinture extérieure',
            'Enduit décoratif',
            'Pierre naturelle',
            'Pierre artificielle',
            'Marbre',
            'Granit',
            'Carrelage extérieur',
            'Panneaux WPC',
            'Panneaux aluminium',
            'Bardage',
            'Parement',
            'Claustra extérieur',
          ],
        ),
        MaterialSub(
          id: 'terrasses',
          label: 'Terrasses',
          saleMode: SaleMode.devis,
          families: [
            'Carrelage extérieur',
            'Dalles',
            'Pierre naturelle',
            'Béton décoratif',
            'Béton imprimé',
            'Bois extérieur',
            'WPC',
            'Gazon synthétique',
            'Gravier décoratif',
          ],
        ),
        MaterialSub(
          id: 'jardins',
          label: 'Jardins',
          families: [
            'Gazon naturel',
            'Gazon synthétique',
            'Pots',
            'Jardinières',
            'Bordures',
            'Pierres décoratives',
            'Graviers',
            'Éclairage solaire',
            'Éclairage LED extérieur',
            'Fontaines',
            'Pergolas',
            'Bancs',
            'Mobilier extérieur',
          ],
        ),
        // Hors PDF : le catalogue source range l'éclairage extérieur soit dans
        // « Jardins », soit dans « Façades » (chantier). Les luminaires vendus
        // sur étagère avaient besoin d'un rayon à eux.
        MaterialSub(
          id: 'clotures',
          label: 'Clôtures et séparation',
          saleMode: SaleMode.devis,
          families: [
            'Claustra',
            'Bois',
            'WPC',
            'Aluminium',
            'Acier',
            'Fer forgé',
            'Grillage décoratif',
            'Mur décoratif',
            'Gabions',
          ],
        ),
        MaterialSub(
          id: 'pergolas',
          label: 'Pergolas et espaces extérieurs',
          saleMode: SaleMode.devis,
          families: [
            'Pergola aluminium',
            'Pergola bois',
            'Pergola métallique',
            'Pergola bioclimatique',
            'Stores extérieurs',
            'Toiles',
            'Polycarbonate',
            'Verre',
            'Éclairage LED',
          ],
        ),
      ],
    ),
    MaterialCategory(
      id: 'menuiserie',
      label: 'Menuiserie moderne',
      icon: Icons.carpenter_rounded,
      gradient: [Color(0xFF7A4B12), Color(0xFFC98B3A)],
      children: [
        MaterialSub(
          id: 'bois_panneaux',
          label: 'Menuiserie bois — Panneaux',
          families: [
            'MDF',
            'MDF hydrofuge',
            'MDF mélaminé',
            'MDF plaqué bois',
            'Contreplaqué',
            'OSB',
            'Aggloméré',
            'Bois massif',
          ],
        ),
        MaterialSub(
          id: 'bois_finitions',
          label: 'Menuiserie bois — Finitions',
          families: [
            'Placage bois',
            'Stratifié HPL',
            'Mélaminé',
            'Vernis',
            'Peinture',
            'Laque',
            'Finition mate',
            'Finition brillante',
          ],
        ),
        MaterialSub(
          id: 'aluminium',
          label: 'Menuiserie aluminium',
          saleMode: SaleMode.devis,
          families: [
            'Profilés aluminium',
            'Fenêtres aluminium',
            'Portes aluminium',
            'Baies vitrées',
            'Coulissants',
            'Vérandas',
            'Cloisons aluminium',
            'Garde-corps',
            'Pergolas',
          ],
        ),
        MaterialSub(
          id: 'alu_accessoires',
          label: 'Aluminium — Accessoires',
          families: [
            'Serrures',
            'Poignées',
            'Charnières',
            'Roulettes',
            'Joints',
            'Visserie',
            'Équerres',
            'Profilés de finition',
          ],
        ),
        MaterialSub(
          id: 'metallique',
          label: 'Menuiserie métallique',
          families: [
            'Acier',
            'Acier inoxydable',
            'Fer',
            'Tubes carrés',
            'Tubes rectangulaires',
            'Cornières',
            'Plats métalliques',
            'Tôles',
            'Tôles perforées',
            'Tôles décoratives',
          ],
        ),
        MaterialSub(
          id: 'meubles_mesure',
          label: 'Meubles sur mesure',
          saleMode: SaleMode.devis,
          families: [
            'Cuisine moderne',
            'Dressing',
            'Placards',
            'Bibliothèque',
            'Meuble TV',
            'Meuble lavabo',
            'Meuble bureau',
            'Meuble bar',
            'Meuble chaussures',
            'Meuble de rangement',
            'Îlot central',
            'Vestiaire',
          ],
        ),
        MaterialSub(
          id: 'portes',
          label: 'Portes modernes',
          saleMode: SaleMode.devis,
          families: [
            'Porte MDF',
            'Porte bois massif',
            'Porte vitrée',
            'Porte aluminium',
            'Porte coulissante',
            'Porte à galandage',
            'Porte pivotante',
            'Porte pliante',
            'Porte avec miroir',
            'Porte avec tasseaux décoratifs',
          ],
        ),
        MaterialSub(
          id: 'quincaillerie',
          label: 'Quincaillerie moderne',
          families: [
            'Charnières invisibles',
            'Coulisses de tiroirs',
            'Coulisses télescopiques',
            'Coulisses push-to-open',
            'Systèmes soft-close',
            'Vérins',
            'Compas',
            'Systèmes de portes coulissantes',
            'Poignées',
            'Boutons',
            'Serrures',
            'Systèmes push',
            'Pieds de meubles',
            'Roulettes',
            'Connecteurs',
            'Visserie',
          ],
        ),
      ],
    ),
    MaterialCategory(
      id: 'enseignes',
      label: 'Enseignes & signalétique',
      icon: Icons.storefront_rounded,
      gradient: [Color(0xFFE30613), Color(0xFFEF9F27)],
      children: [
        MaterialSub(
          id: 'enseignes_lumineuses',
          label: 'Enseignes lumineuses',
          saleMode: SaleMode.devis,
          families: [
            'Lettres LED',
            'Lettres boîtiers lumineuses',
            'Lettres rétroéclairées',
            'Lettres 3D',
            'Caissons lumineux',
            'Enseignes LED',
            'Néon LED',
            'Néon flexible',
            'Enseignes à éclairage frontal',
            'Enseignes à double éclairage',
          ],
        ),
        MaterialSub(
          id: 'enseignes_non_lumineuses',
          label: 'Enseignes non lumineuses',
          saleMode: SaleMode.devis,
          families: [
            'Lettres découpées',
            'Lettres PVC',
            'Lettres aluminium',
            'Lettres inox',
            'Lettres acryliques',
            'Lettres MDF',
            'Lettres bois',
            'Lettres 3D',
            'Logos découpés',
          ],
        ),
        MaterialSub(
          id: 'materiaux_enseignes',
          label: 'Matériaux pour enseignes',
          families: [
            'PVC expansé',
            'Plexiglas',
            'PMMA',
            'Aluminium composite',
            'Dibond',
            'Aluminium',
            'Inox',
            'Acier',
            'MDF',
            'Acrylique',
            'Polycarbonate',
            'Vinyle adhésif',
          ],
        ),
        MaterialSub(
          id: 'caissons',
          label: 'Caissons',
          saleMode: SaleMode.devis,
          families: [
            'Caisson aluminium',
            'Caisson PVC',
            'Caisson acrylique',
            'Caisson simple face',
            'Caisson double face',
            'Caisson lumineux',
            'Caisson suspendu',
          ],
        ),
        MaterialSub(
          id: 'signaletique',
          label: 'Signalétique',
          saleMode: SaleMode.devis,
          families: [
            'Panneaux directionnels',
            'Plaques professionnelles',
            'Numéros de maison',
            'Plaques de porte',
            'Totems',
            'Panneaux publicitaires',
            'Panneaux immobiliers',
            'Panneaux de sécurité',
            'Signalétique intérieure',
            'Signalétique extérieure',
          ],
        ),
      ],
    ),
    MaterialCategory(
      id: 'fabrication',
      label: 'Fabrication & pose',
      icon: Icons.construction_rounded,
      gradient: [Color(0xFF3C3489), Color(0xFF7F77DD)],
      children: [
        MaterialSub(
          id: 'outillage_bois',
          label: 'Travail du bois',
          families: [
            'Scie circulaire',
            'Scie plongeante',
            'Scie sauteuse',
            'Scie à onglet',
            'Défonceuse',
            'Raboteuse',
            'Dégauchisseuse',
            'Ponceuse',
            'Perceuse',
            'Visseuse',
            'Cloueuse',
            'Agrafeuse',
          ],
        ),
        MaterialSub(
          id: 'outillage_metal',
          label: 'Travail du métal',
          families: [
            'Poste à souder',
            'Meuleuse',
            'Découpeuse',
            'Perceuse à colonne',
            'Plieuse',
            'Cisaille',
            'Scie à métal',
            'Ponceuse',
            'Compresseur',
          ],
        ),
        MaterialSub(
          id: 'machines_enseignes',
          label: 'Fabrication d\'enseignes',
          saleMode: SaleMode.devis,
          families: [
            'Machine CNC',
            'Laser CO2',
            'Plotter de découpe',
            'Imprimante UV',
            'Imprimante grand format',
            'Machine de thermoformage',
            'Plieuse acrylique',
            'Machine à lettres 3D',
            'Fer à souder',
            'Multimètre',
          ],
        ),
        MaterialSub(
          id: 'outillage_pose',
          label: 'Pose',
          families: [
            'Perceuse',
            'Visseuse',
            'Niveau laser',
            'Niveau à bulle',
            'Mètre',
            'Escabeau',
            'Échelle',
            'Échafaudage',
            'Chevilles',
            'Vis',
            'Silicone',
            'Colle',
            'Ruban adhésif',
            'Pistolet à silicone',
          ],
        ),
      ],
    ),
    MaterialCategory(
      id: 'electrique',
      label: 'Matériel électrique',
      icon: Icons.bolt_rounded,
      gradient: [Color(0xFF0F6E56), Color(0xFF1D9E75)],
      children: [
        // Hors PDF : le catalogue source ne couvre pas les luminaires
        // techniques (entrepôts, ateliers, sécurité), déjà vendus en boutique.
        MaterialSub(
          id: 'installation',
          label: 'Installation',
          families: [
            'Câbles',
            'Connecteurs',
            'Dominos',
            'Bornes',
            'Interrupteurs',
            'Disjoncteurs',
            'Fusibles',
            'Gaines',
            'Goulottes',
            'Profilés aluminium',
          ],
        ),
      ],
    ),
    MaterialCategory(
      id: 'vitrerie',
      label: 'Vitrerie & verre',
      icon: Icons.window_rounded,
      gradient: [Color(0xFF0F6E56), Color(0xFF1DC8FF)],
      children: [
        MaterialSub(
          id: 'types_verre',
          label: 'Types de verre',
          families: [
            'Verre clair',
            'Verre fumé',
            'Verre bronze',
            'Verre gris',
            'Verre miroir',
            'Verre trempé',
            'Verre feuilleté',
            'Verre cannelé',
            'Verre dépoli',
            'Verre teinté',
          ],
        ),
        MaterialSub(
          id: 'applications_verre',
          label: 'Applications',
          saleMode: SaleMode.devis,
          families: [
            'Portes vitrées',
            'Cloisons vitrées',
            'Douches',
            'Garde-corps',
            'Vitrines commerciales',
            'Tables',
            'Miroirs',
            'Baies vitrées',
            'Verrières',
            'Séparations de pièces',
          ],
        ),
      ],
    ),
    MaterialCategory(
      id: 'consommables',
      label: 'Finitions & consommables',
      icon: Icons.format_paint_rounded,
      gradient: [Color(0xFF5C5875), Color(0xFFAFA9EC)],
      children: [
        MaterialSub(
          id: 'peintures_colles',
          label: 'Peintures, vernis & colles',
          families: [
            'Peinture',
            'Vernis',
            'Laque',
            'Apprêt',
            'Mastic',
            'Silicone',
            'Colle à bois',
            'Colle contact',
            'Colle PVC',
            'Colle métal',
            'Résine époxy',
          ],
        ),
        MaterialSub(
          id: 'abrasifs_coupe',
          label: 'Abrasifs & outils de coupe',
          families: [
            'Papier abrasif',
            'Disques de coupe',
            'Disques de ponçage',
            'Lames de scie',
            'Fraises CNC',
            'Forets',
          ],
        ),
        MaterialSub(
          id: 'visserie',
          label: 'Visserie & fixations',
          families: ['Vis', 'Boulons', 'Écrous', 'Rivets', 'Chevilles'],
        ),
        MaterialSub(
          id: 'adhesifs',
          label: 'Adhésifs & films',
          families: ['Ruban adhésif', 'Films adhésifs'],
        ),
      ],
    ),
  ];

  /// Identifiants d'univers — sert à valider un catalogue distant.
  static List<String> get categoryIds =>
      categories.map((c) => c.id).toList(growable: false);

  static MaterialCategory? byId(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  static MaterialSub? subById(String categoryId, String subId) {
    final cat = byId(categoryId);
    if (cat == null) return null;
    for (final s in cat.children) {
      if (s.id == subId) return s;
    }
    return null;
  }

  static String labelFor({required String categoryId, String? subcategoryId}) {
    final cat = byId(categoryId);
    if (cat == null) return categoryId;
    if (subcategoryId == null) return cat.label;
    final sub = subById(categoryId, subcategoryId);
    return sub == null ? cat.label : '${cat.label} · ${sub.label}';
  }

  /// Mode de vente par défaut d'un emplacement du catalogue.
  static SaleMode saleModeFor({
    required String categoryId,
    String? subcategoryId,
  }) {
    if (subcategoryId == null) return SaleMode.panier;
    return subById(categoryId, subcategoryId)?.saleMode ?? SaleMode.panier;
  }

  /// Recherche dans les ~400 familles du catalogue.
  ///
  /// Permet de retrouver « charnière invisible » ou « pergola bioclimatique »
  /// même si aucun produit ne porte encore ce nom en boutique.
  static List<FamilyHit> searchFamilies(String query, {int limit = 12}) {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return const [];
    final hits = <FamilyHit>[];
    for (final cat in categories) {
      for (final sub in cat.children) {
        for (final family in sub.families) {
          if (family.toLowerCase().contains(q)) {
            hits.add(FamilyHit(category: cat, sub: sub, family: family));
            if (hits.length >= limit) return hits;
          }
        }
      }
    }
    return hits;
  }
}

class MaterialCategory {
  const MaterialCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.children,
  });

  final String id;
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final List<MaterialSub> children;

  /// Nombre de familles couvertes par l'univers.
  int get familyCount => children.fold(0, (sum, s) => sum + s.families.length);
}

class MaterialSub {
  const MaterialSub({
    required this.id,
    required this.label,
    required this.families,
    this.saleMode = SaleMode.panier,
  });

  final String id;
  final String label;
  final List<String> families;
  final SaleMode saleMode;
}

class FamilyHit {
  const FamilyHit({
    required this.category,
    required this.sub,
    required this.family,
  });

  final MaterialCategory category;
  final MaterialSub sub;
  final String family;
}

/// Paliers de fidélité Voltify.
enum LoyaltyTier { bronze, silver, gold, platinum }

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
