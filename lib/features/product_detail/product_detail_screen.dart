import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/mock_catalog.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import '../../shared/widgets/common_widgets.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final similar = MockCatalog.similarTo(product);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(16, 72, 16, 16),
                child: ProductImagePlaceholder(product: product, borderRadius: 24),
              ),
            ),
            actions: [
              if (cart.itemCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${cart.itemCount} panier',
                        style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        product.brand.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rounded, color: AppColors.amberLight, size: 18),
                      Text(
                        ' ${product.rating} (${product.reviewCount})',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.fcfa(product.price),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 10),
                        Text(
                          Formatters.fcfa(product.oldPrice!),
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(
                        icon: Icons.loyalty_rounded,
                        label: '+${product.pointsReward} pts ${product.loyaltyTrack == LoyaltyTrack.lumineux ? 'Lumineux' : 'Déco'}',
                      ),
                      _InfoPill(
                        icon: product.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        label: product.inStock ? 'En stock' : 'Rupture',
                        color: product.inStock ? AppColors.greenLight : AppColors.danger,
                      ),
                      _InfoPill(icon: Icons.category_outlined, label: product.category.label),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Description', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
                  ),
                  const SizedBox(height: 18),
                  Text('Caractéristiques', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  ...product.specs.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ),
                  ),
                  if (similar.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Produits similaires', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          if (similar.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 230,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: similar.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final p = similar[index];
                    return SizedBox(
                      width: 150,
                      child: ProductCard(
                        product: p,
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<CartProvider>().add(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} ajouté au panier')),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('Panier'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CartProvider>().add(product);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    // User can open cart from shell — show snackbar guidance
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ajouté — ouvrez l’onglet Panier pour payer')),
                    );
                  },
                  child: const Text('Acheter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label, this.color = AppColors.primary});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}
