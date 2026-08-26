import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/lighting_taxonomy.dart';
import '../../data/models/models.dart';

class ProductImagePlaceholder extends StatelessWidget {
  const ProductImagePlaceholder({
    super.key,
    required this.product,
    this.height,
    this.borderRadius = 16,
  });

  final Product product;
  final double? height;
  final double borderRadius;

  static IconData iconFor(String categoryId) {
    return LightingTaxonomy.byId(categoryId)?.icon ?? Icons.lightbulb_rounded;
  }

  static List<Color> gradientFor(String categoryId) {
    switch (categoryId) {
      case 'indoor':
        return const [Color(0xFF534AB7), Color(0xFF9B94E8)];
      case 'outdoor':
        return const [Color(0xFFBA7517), Color(0xFFEF9F27)];
      case 'landscape':
        return const [Color(0xFF0F6E56), Color(0xFF1D9E75)];
      case 'architectural':
        return const [Color(0xFF1A1730), Color(0xFF534AB7)];
      case 'industrial':
        return const [Color(0xFF3C3489), Color(0xFF7F77DD)];
      case 'signage':
        return const [Color(0xFFE30613), Color(0xFFEF9F27)];
      case 'underwater':
        return const [Color(0xFF0F6E56), Color(0xFF1DC8FF)];
      case 'accessories':
        return const [Color(0xFF5C5875), Color(0xFFAFA9EC)];
      default:
        return const [Color(0xFF534AB7), Color(0xFF7F77DD)];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          product.imageUrl!,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final colors = gradientFor(product.categoryId);
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconFor(product.categoryId), size: 42, color: Colors.white.withValues(alpha: 0.95)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    product.brand,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final Product product;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ProductImagePlaceholder(product: product, borderRadius: 14),
                      ),
                    ),
                    if (product.badge != null)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.badge!,
                            style: const TextStyle(
                              color: AppColors.successText,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand,
                      style: const TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.25),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Formatters.fcfa(product.price),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    if (product.hasDiscount)
                      Text(
                        Formatters.fcfa(product.oldPrice!),
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

class PriceSummary extends StatelessWidget {
  const PriceSummary({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.loyaltyDiscount = 0,
    this.loyaltyLabel,
  });

  final int subtotal;
  final int deliveryFee;
  final int total;
  final int loyaltyDiscount;
  final String? loyaltyLabel;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value, {bool bold = false, Color? color}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color ?? (bold ? AppColors.primary : AppColors.textPrimary),
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          row('Sous-total', Formatters.fcfa(subtotal)),
          row('Livraison', deliveryFee == 0 ? 'Gratuit' : Formatters.fcfa(deliveryFee)),
          if (loyaltyDiscount > 0)
            row(
              loyaltyLabel ?? 'Réduction fidélité',
              '- ${Formatters.fcfa(loyaltyDiscount)}',
              color: AppColors.greenLight,
            ),
          const Divider(height: 20),
          row('Total', Formatters.fcfa(total), bold: true),
        ],
      ),
    );
  }
}
