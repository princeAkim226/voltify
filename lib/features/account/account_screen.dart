import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loyalty = context.watch<LoyaltyProvider>().balance;
    final orders = context.watch<OrderProvider>().orders;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invité Voltify', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                    SizedBox(height: 4),
                    Text(
                      'Compte optionnel — commandez sans inscription',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Fidélité', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Lumineux',
                value: '${loyalty.lumineux}',
                color: AppColors.amber,
                soft: AppColors.amberSoft,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Décoration',
                value: '${loyalty.deco}',
                color: AppColors.primary,
                soft: AppColors.primarySoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Historique des commandes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        if (orders.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Aucune commande pour le moment. Explorez le catalogue et passez votre première commande.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          ...orders.map((o) => _OrderTile(order: o)),
        const SizedBox(height: 24),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.info_outline_rounded, color: AppColors.primary),
          title: Text('À propos', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('Voltify · Électronique au Burkina Faso · FCFA'),
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.payments_outlined, color: AppColors.primary),
          title: Text('Paiements', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('Orange Money, Moov Money, Telecel Money, Wave (simulation v1)'),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.color, required this.soft});

  final String label;
  final String value;
  final Color color;
  final Color soft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 26)),
          const Text('points', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.id, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  '${order.items.length} article(s) · ${order.paymentMethod.label}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            Formatters.compactFcfa(order.total),
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
