import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_catalog.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import '../../shared/widgets/common_widgets.dart';
import '../product_detail/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenCatalog});

  final VoidCallback? onOpenCatalog;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController();
  int _promoIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_promoIndex + 1) % MockCatalog.promos.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loyalty = context.watch<LoyaltyProvider>().balance;
    final featured = MockCatalog.featured();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour 👋',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                      ),
                      Text(
                        'Voltify Burkina',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'OFFRES & PROMOTIONS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 130,
            child: PageView.builder(
              controller: _pageController,
              itemCount: MockCatalog.promos.length,
              onPageChanged: (i) => setState(() => _promoIndex = i),
              itemBuilder: (context, index) {
                final promo = MockCatalog.promos[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _PromoCard(promo: promo),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(MockCatalog.promos.length, (i) {
                final active = i == _promoIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 22)),
        SliverToBoxAdapter(
          child: SectionHeader(title: 'Mes points fidélité'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: _PointsCard(
                    title: 'Lumineux',
                    value: loyalty.lumineux,
                    subtitle: 'Objectif ${loyalty.lumineuxGoal}',
                    progress: loyalty.progress(LoyaltyTrack.lumineux),
                    soft: AppColors.amberSoft,
                    border: AppColors.amberBorder,
                    iconBg: AppColors.amberBorder,
                    icon: Icons.lightbulb_rounded,
                    titleColor: const Color(0xFF633806),
                    valueColor: const Color(0xFF412402),
                    fill: AppColors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PointsCard(
                    title: 'Décoration',
                    value: loyalty.deco,
                    subtitle: 'Objectif ${loyalty.decoGoal}',
                    progress: loyalty.progress(LoyaltyTrack.deco),
                    soft: AppColors.primarySoft,
                    border: const Color(0xFFAFA9EC),
                    iconBg: const Color(0xFFAFA9EC),
                    icon: Icons.auto_awesome_rounded,
                    titleColor: AppColors.primaryDark,
                    valueColor: const Color(0xFF26215C),
                    fill: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 22)),
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Catégories',
            actionLabel: 'Tout voir',
            onAction: widget.onOpenCatalog,
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 96,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: ProductCategory.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final cat = ProductCategory.values[index];
                return _CategoryChip(
                  category: cat,
                  onTap: () {
                    context.read<CatalogProvider>().setCategory(cat);
                    widget.onOpenCatalog?.call();
                  },
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Sélection du moment',
            actionLabel: 'Catalogue',
            onAction: widget.onOpenCatalog,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = featured[index];
                return ProductCard(
                  product: product,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                  ),
                );
              },
              childCount: featured.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo});

  final PromoSlide promo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: promo.gradientColors.map(Color.new).toList(),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -22,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(promo.tagColor ?? 0xFFFAC775),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    promo.tag,
                    style: TextStyle(
                      color: Color(promo.tagTextColor ?? 0xFF412402),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  promo.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  promo.subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
    required this.soft,
    required this.border,
    required this.iconBg,
    required this.icon,
    required this.titleColor,
    required this.valueColor,
    required this.fill,
  });

  final String title;
  final int value;
  final String subtitle;
  final double progress;
  final Color soft;
  final Color border;
  final Color iconBg;
  final IconData icon;
  final Color titleColor;
  final Color valueColor;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: valueColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 13)),
          Text('$value', style: TextStyle(color: valueColor, fontWeight: FontWeight.w800, fontSize: 24)),
          Text(subtitle, style: TextStyle(color: titleColor.withValues(alpha: 0.75), fontSize: 11)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.black.withValues(alpha: 0.08),
              color: fill,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onTap});

  final ProductCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ProductImagePlaceholder.gradientFor(category);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 88,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(ProductImagePlaceholder.iconFor(category), color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              category.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, height: 1.15),
            ),
          ],
        ),
      ),
    );
  }
}
