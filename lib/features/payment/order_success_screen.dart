import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    final lum = order.pointsEarned[LoyaltyTrack.lumineux] ?? 0;
    final deco = order.pointsEarned[LoyaltyTrack.deco] ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(Icons.check_rounded, size: 52, color: AppColors.successText),
              ),
              const SizedBox(height: 24),
              Text(
                'Commande confirmée',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'N° ${order.id}',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                order.deliveryMode == DeliveryMode.delivery
                    ? 'Livraison vers ${order.city}'
                    : 'Retrait en magasin',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                'Payé via ${order.paymentMethod.label} · ${Formatters.fcfa(order.total)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text('Points fidélité gagnés', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    if (lum > 0)
                      Text('+$lum pts Lumineux', style: const TextStyle(color: AppColors.amber, fontWeight: FontWeight.w700)),
                    if (deco > 0)
                      Text('+$deco pts Décoration', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    if (lum == 0 && deco == 0)
                      const Text('Aucun point sur cette commande', style: TextStyle(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Retour à l’accueil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
