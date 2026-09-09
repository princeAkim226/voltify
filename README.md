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

En local :

```bash
flutter build apk --release
```

APK : `build/app/outputs/flutter-apk/app-release.apk`

### Build sur GitHub Actions

`.github/workflows/build-apk.yml`, déclenchement **manuel** (onglet Actions →
*Build APK* → *Run workflow*). Un push ne construit rien.

Le workflow analyse, teste, construit l'APK signé avec la clé de release et le
dépose en artefact. Il échoue volontairement si le keystore manque : un APK
signé en debug ne peut pas se mettre à jour par-dessus la version publiée.

Deux secrets sont requis dans **Settings → Secrets and variables → Actions** :

| Secret | Contenu |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `android/keystore/voltify-release.jks` encodé en base64 |
| `ANDROID_KEY_PROPERTIES` | le contenu de `android/key.properties`, tel quel |

Pour produire le base64 du keystore (PowerShell) :

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\keystore\voltify-release.jks")) | Set-Clipboard
```

Les deux fichiers sont gitignorés et ne doivent jamais être commités.

## Publication

Les deux sites Netlify sont en **déploiement manuel** (aucun lien GitHub) :

```bash
netlify deploy --prod --dir admin --functions netlify/functions \
  --site 1d346527-de6e-40d3-be4d-b8c20db87523      # voltify-admin-bf

netlify deploy --prod --dir web_download \
  --site 6bd79847-4cf9-461a-a72d-73923d57a319      # voltify-download-bf
```

Avant de publier le site de téléchargement : copier l'APK dans
`web_download/voltify.apk` **et** mettre à jour la version et la taille
affichées dans `web_download/index.html`. La page ne doit jamais annoncer une
version qui n'est pas celle du fichier servi.

## Stack

Flutter · Provider · Google Fonts · SharedPreferences
