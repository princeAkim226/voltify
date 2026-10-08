import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/catalog_taxonomy.dart';
import '../../data/mock/marketing_sections.dart';
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
    final section = catalog.selectedSectionId == null
        ? null
        : MarketingSections.byId(catalog.selectedSectionId!);
    final selectedCat = catalog.selectedCategoryId == null
        ? null
        : CatalogTaxonomy.byId(catalog.selectedCategoryId!);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: TextField(
            onChanged: catalog.setQuery,
            decoration: InputDecoration(
              hintText: 'Rechercher un matériau, un produit, une marque…',
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
        if (catalog.familySuggestions.isNotEmpty) ...[
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: catalog.familySuggestions
                  .map(
                    (hit) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        avatar: Icon(hit.category.icon,
                            size: 15, color: AppColors.primary),
                        label: Text(hit.family),
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                        backgroundColor: AppColors.primarySoft,
                        side: const BorderSide(color: AppColors.primaryLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () {
                          catalog.setQuery('');
                          catalog.setCategory(hit.category.id);
                          catalog.setSubcategory(hit.sub.id);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (section == null && selectedCat == null)
          Expanded(child: _SectionsRoot(catalog: catalog))
        else if (selectedCat == null && section != null)
          Expanded(child: _SectionBrowse(catalog: catalog, section: section))
        else if (selectedCat != null)
          ..._categoryBrowse(
            context,
            catalog: catalog,
            selectedCat: selectedCat,
            products: products,
            section: section,
          )
        else
          const Expanded(child: SizedBox.shrink()),
      ],
    );
  }

  List<Widget> _categoryBrowse(
    BuildContext context, {
    required CatalogProvider catalog,
    required MaterialCategory selectedCat,
    required List<Product> products,
    MarketingSection? section,
  }) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                if (catalog.selectedSubcategoryId != null) {
                  catalog.setSubcategory(null);
                } else if (section != null) {
                  catalog.setCategory(null);
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
                    : CatalogTaxonomy.labelFor(
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
              Text('Tous les produits',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
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
    ];
  }
}

class _SectionsRoot extends StatelessWidget {
  const _SectionsRoot({required this.catalog});

  final CatalogProvider catalog;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Text(
          'Catalogue Lumi-Dec',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Trois univers : éclairage, aménagements et enseignes.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        ...MarketingSections.sections.map(
          (section) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SectionHero(
              section: section,
              onTap: () => catalog.setSection(section.id),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionBrowse extends StatelessWidget {
  const _SectionBrowse({required this.catalog, required this.section});

  final CatalogProvider catalog;
  final MarketingSection section;

  @override
  Widget build(BuildContext context) {
    final categories = CatalogTaxonomy.categories
        .where((c) => section.categoryIds.contains(c.id))
        .toList();
    final products = catalog.products;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 20, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => catalog.setSection(null),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Point ${section.number} — ${section.title}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 10),
          child: Text(
            section.body,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ),
        if (section.id == 'eclairage')
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _InfoPill(label: '1.A Architectural & intérieur'),
                _InfoPill(label: '1.B LED & décors de plafond'),
              ],
            ),
          ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 8),
            itemCount: section.galleryAssets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  section.galleryAssets[index],
                  width: 160,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            'Rayons',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 6),
        ...categories.map(
          (cat) => ListTile(
            contentPadding: const EdgeInsets.only(left: 8),
            leading: CircleAvatar(
              backgroundColor: AppColors.primarySoft,
              child: Icon(cat.icon, color: AppColors.primary, size: 18),
            ),
            title: Text(cat.label, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${cat.children.length} rayons · ${cat.familyCount} familles'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => catalog.setCategory(cat.id),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            'Produits de la section',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: products.isEmpty
              ? const Text('Aucun produit pour le moment dans cette section.')
              : GridView.builder(
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
        ),
      ],
    );
  }
}

class _SectionHero extends StatelessWidget {
  const _SectionHero({required this.section, required this.onTap});

  final MarketingSection section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 168,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: DecorationImage(
              image: AssetImage(section.coverAsset),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.42),
                BlendMode.darken,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: section.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'POINT ${section.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  section.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  section.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.amberSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amberBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF633806),
          fontWeight: FontWeight.w700,
          fontSize: 12,
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
