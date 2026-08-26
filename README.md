# Voltify

Application mobile Flutter e-commerce pour la vente de matériel électronique au **Burkina Faso** (FCFA).

## Liens

- **Repo** : https://github.com/princeAkim226/voltify
- **Télécharger l’APK** : https://voltify-download-bf.netlify.app
- **Release GitHub** : https://github.com/princeAkim226/voltify/releases/tag/v1.0.0

## Fonctionnalités

- Catalogue multi-catégories (smartphones, PC, TV, audio, accessoires, LED, électroménager)
- Fiche produit + produits similaires
- Panier et checkout invité (sans compte obligatoire)
- Livraison (Ouaga / Bobo) ou retrait magasin
- Paiement mobile simulé : Orange Money, Moov Money, Telecel Money, Wave
- Points fidélité Lumineux / Décoration
- Données mock locales (schéma Supabase préparé dans `docs/supabase_schema.sql`)

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
