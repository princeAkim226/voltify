# Voltify

Application mobile Flutter e-commerce pour la vente de **matériel de décoration, menuiserie et enseignes** au **Burkina Faso** (FCFA).

## Liens

- **Télécharger l’APK** : https://voltify-download-bf.netlify.app
- **Admin catalogue** : https://voltify-admin-bf.netlify.app
- **Repo** : https://github.com/princeAkim226/voltify
- **Release GitHub** : https://github.com/princeAkim226/voltify/releases/tag/v1.0.0

## Fonctionnalités

- Catalogue sur 8 univers, 37 rayons et ~400 familles de produits
  (décoration intérieure et extérieure, menuiserie, enseignes, fabrication,
  matériel électrique, vitrerie, consommables)
- Recherche par famille : « charnière invisible », « pergola bioclimatique »
  orientent vers le bon rayon même sans produit en stock
- Deux modes de vente : **panier** pour le prix ferme, **devis** pour le
  sur-mesure (menuiserie, enseignes, pergolas, vitrerie posée)
- Fiche produit + produits similaires
- Panier et checkout invité (sans compte obligatoire)
- Livraison (Ouaga / Bobo) ou retrait magasin
- Paiement mobile simulé : Orange Money, Moov Money, Telecel Money, Wave
- Points fidélité Lumineux / Décoration
- Données mock locales (schéma Supabase dans `docs/supabase_schema.sql`)

## Catalogue

La nomenclature vit dans [`lib/data/mock/catalog_taxonomy.dart`](lib/data/mock/catalog_taxonomy.dart) :
un univers porte des rayons, un rayon porte des familles et un mode de vente
(`SaleMode.panier` ou `SaleMode.devis`) dont chaque produit hérite — surchargeable
article par article via `saleModeOverride`.

Côté base, la migration `docs/supabase_materiel_migration.sql` crée les univers,
la table `subcategories`, la table `quote_requests`, et reclasse les produits
issus de l'ancienne taxonomie Éclairage.

`test/catalog_taxonomy_test.dart` interdit qu'un produit pointe vers un rayon
inexistant ou qu'un article sans prix parte au panier.

## Lancer en local

```bash
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk --release
```

APK : `build/app/outputs/flutter-apk/app-release.apk`  
Page téléchargement : dossier `web_download/`

## Stack

Flutter · Provider · Google Fonts · SharedPreferences
