import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import '../../shared/widgets/common_widgets.dart';
import '../product_detail/product_detail_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final products = catalog.products;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: TextField(
            onChanged: catalog.setQuery,
            decoration: InputDecoration(
              hintText: 'Rechercher un produit, une marque…',
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
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _FilterChip(
                label: 'Tout',
                selected: catalog.selectedCategory == null,
                onTap: () => catalog.setCategory(null),
              ),
              ...ProductCategory.values.map(
                (c) => _FilterChip(
                  label: c.label,
                  selected: catalog.selectedCategory == c,
                  onTap: () => catalog.setCategory(c),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${products.length} produit${products.length > 1 ? 's' : ''}',
              style: const TextStyle(color: AppColors.textTertiary, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: products.isEmpty
              ? const Center(child: Text('Aucun produit trouvé'))
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
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

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
