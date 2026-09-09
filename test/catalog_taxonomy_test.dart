import 'package:flutter_test/flutter_test.dart';
import 'package:voltify/data/mock/catalog_taxonomy.dart';
import 'package:voltify/data/mock/mock_catalog.dart';

void main() {
  group('Taxonomie matériel', () {
    test('les identifiants d\'univers sont uniques', () {
      final ids = CatalogTaxonomy.categories.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('les identifiants de rayon sont uniques dans leur univers', () {
      for (final cat in CatalogTaxonomy.categories) {
        final ids = cat.children.map((s) => s.id).toList();
        expect(
          ids.toSet().length,
          ids.length,
          reason: 'doublon de rayon dans ${cat.id}',
        );
      }
    });

    test('chaque rayon porte au moins une famille', () {
      for (final cat in CatalogTaxonomy.categories) {
        for (final sub in cat.children) {
          expect(
            sub.families,
            isNotEmpty,
            reason: '${cat.id}/${sub.id} n\'a aucune famille',
          );
        }
      }
    });

    test('labelFor compose univers et rayon', () {
      expect(
        CatalogTaxonomy.labelFor(categoryId: 'menuiserie'),
        'Menuiserie moderne',
      );
      expect(
        CatalogTaxonomy.labelFor(
          categoryId: 'menuiserie',
          subcategoryId: 'quincaillerie',
        ),
        'Menuiserie moderne · Quincaillerie moderne',
      );
    });

    test('le sur-mesure est bien marqué sur devis', () {
      expect(
        CatalogTaxonomy.saleModeFor(
          categoryId: 'menuiserie',
          subcategoryId: 'meubles_mesure',
        ),
        SaleMode.devis,
      );
      expect(
        CatalogTaxonomy.saleModeFor(
          categoryId: 'menuiserie',
          subcategoryId: 'quincaillerie',
        ),
        SaleMode.panier,
      );
    });

    test('searchFamilies retrouve une famille sans produit en stock', () {
      final hits = CatalogTaxonomy.searchFamilies('pergola bioclimatique');
      expect(hits, isNotEmpty);
      expect(hits.first.category.id, 'deco_exterieure');
      expect(hits.first.sub.id, 'pergolas');
    });

    test('searchFamilies ignore les requêtes trop courtes', () {
      expect(CatalogTaxonomy.searchFamilies('a'), isEmpty);
    });
  });

  group('Catalogue et taxonomie restent alignés', () {
    // Le catalogue a déjà dérivé une fois (seed électronique laissé derrière
    // un pivot). Ce test refuse tout produit rangé dans un rayon inexistant.
    test('chaque produit pointe vers un univers et un rayon connus', () {
      for (final p in MockCatalog.products) {
        final cat = CatalogTaxonomy.byId(p.categoryId);
        expect(
          cat,
          isNotNull,
          reason: '${p.id} « ${p.name} » : univers inconnu ${p.categoryId}',
        );
        if (p.subcategoryId != null) {
          expect(
            CatalogTaxonomy.subById(p.categoryId, p.subcategoryId!),
            isNotNull,
            reason: '${p.id} « ${p.name} » : rayon inconnu '
                '${p.categoryId}/${p.subcategoryId}',
          );
        }
      }
    });

    test('un produit sans prix est forcément sur devis', () {
      for (final p in MockCatalog.products) {
        if (p.price == 0) {
          expect(
            p.isQuoteOnly,
            isTrue,
            reason: '${p.id} « ${p.name} » afficherait 0 FCFA au panier',
          );
        }
      }
    });

    test('un produit vendu au panier a un prix ferme', () {
      for (final p in MockCatalog.products) {
        if (!p.isQuoteOnly) {
          expect(
            p.price,
            greaterThan(0),
            reason: '${p.id} « ${p.name} » est vendable sans prix',
          );
        }
      }
    });

    test('tous les univers du catalogue sont approvisionnés', () {
      for (final cat in CatalogTaxonomy.categories) {
        expect(
          MockCatalog.products.any((p) => p.categoryId == cat.id),
          isTrue,
          reason: 'aucun produit dans « ${cat.label} » : rayon vide en boutique',
        );
      }
    });
  });
}
