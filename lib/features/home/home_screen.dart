import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/catalog_taxonomy.dart';
import '../../data/mock/marketing_sections.dart';
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
    final catalog = context.watch<CatalogProvider>();
    final featured = catalog.featured;

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
                        'Lumi-Dec Burkina',
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
          child: SectionHeader(title: 'Vos points fidélité'),
        ),
        // ignore: prefer_const_constructors
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: _PointsCard(
                    title: 'Éclairage',
                    value: loyalty.lumineux,
                    subtitle: '${context.watch<LoyaltyProvider>().tier.label} · -${context.watch<LoyaltyProvider>().tier.discountPercent}%',
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
                    subtitle: 'Menuiserie, déco, verre',
                    progress: loyalty.progress(LoyaltyTrack.deco),
                    soft: AppColors.greenSoft,
                    border: AppColors.greenLight,
                    iconBg: AppColors.greenLight,
                    icon: Icons.chair_rounded,
                    titleColor: const Color(0xFF04342C),
                    valueColor: const Color(0xFF04342C),
                    fill: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 22)),
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Notre catalogue',
            actionLabel: 'Tout voir',
            onAction: widget.onOpenCatalog,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final section = MarketingSections.sections[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MarketingSectionCard(
                    section: section,
                    onTap: () {
                      context.read<CatalogProvider>().setSection(section.id);
                      widget.onOpenCatalog?.call();
                    },
                  ),
                );
              },
              childCount: MarketingSections.sections.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Sélection du moment',
            actionLabel: 'Catalogue',
            onAction: widget.onOpenCatalog,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          sliver: catalog.loading
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              : featured.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Aucun produit pour le moment'),
                      ),
                    )
                  : SliverGrid(
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
        const SliverToBoxAdapter(child: _ClosingBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
    );
  }
}

class _MarketingSectionCard extends StatelessWidget {
  const _MarketingSectionCard({required this.section, required this.onTap});

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
          height: 148,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: DecorationImage(
              image: AssetImage(section.coverAsset),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.45),
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
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  section.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  section.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
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

class _ClosingBanner extends StatelessWidget {
  const _ClosingBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3EC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD9D2C8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MarketingSections.closingTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              MarketingSections.closingBody,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              MarketingSections.closingSlogan.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFC9953A),
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
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
