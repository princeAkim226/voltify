import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/lighting_taxonomy.dart';
import '../../data/repositories/app_state.dart';
import '../../shared/widgets/common_widgets.dart';
import '../product_detail/product_detail_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final products = catalog.products;
    final selectedCat = catalog.selectedCategoryId == null
        ? null
        : LightingTaxonomy.byId(catalog.selectedCategoryId!);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: TextField(
            onChanged: catalog.setQuery,
            decoration: InputDecoration(
              hintText: 'Rechercher un luminaire, une marque…',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary),
              suffixIcon: catalog.query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => catalog.setQuery(''),
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (selectedCat == null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Catégories Éclairage',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemCount: LightingTaxonomy.categories.length,
              itemBuilder: (context, index) {
                final cat = LightingTaxonomy.categories[index];
                return _CategoryTile(
                  icon: cat.icon,
                  label: cat.label,
                  subtitle: '${cat.children.length} sous-catégories',
                  onTap: () => catalog.setCategory(cat.id),
                );
              },
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (catalog.selectedSubcategoryId != null) {
                      catalog.setSubcategory(null);
                    } else {
                      catalog.clearFilters();
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Text(
                    catalog.selectedSubcategoryId == null
                        ? selectedCat.label
                        : LightingTaxonomy.labelFor(
                            categoryId: selectedCat.id,
                            subcategoryId: catalog.selectedSubcategoryId,
                          ),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          if (catalog.selectedSubcategoryId == null) ...[
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _Chip(
                    label: 'Tout',
                    selected: true,
                    onTap: () {},
                  ),
                  ...selectedCat.children.map(
                    (s) => _Chip(
                      label: s.label,
                      selected: false,
                      onTap: () => catalog.setSubcategory(s.id),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  ...selectedCat.children.map(
                    (s) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primarySoft,
                        child: Icon(selectedCat.icon, color: AppColors.primary, size: 18),
                      ),
                      title: Text(s.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        '${catalog.productById.values.where((p) => p.categoryId == selectedCat.id && p.subcategoryId == s.id).length} produits',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => catalog.setSubcategory(s.id),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Tous les produits', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return ProductCard(
                        product: p,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ] else
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text('Aucun produit dans cette sous-catégorie'))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const Spacer(),
              Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primarySoft,
        labelStyle: TextStyle(
          color: selected ? AppColors.primaryDark : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        side: BorderSide(color: selected ? AppColors.primaryLight : AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
        backgroundColor: AppColors.surface,
      ),
    );
  }
}
