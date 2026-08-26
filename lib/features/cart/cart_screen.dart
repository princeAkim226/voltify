import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/mock_catalog.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import '../../shared/widgets/common_widgets.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final fee = MockCatalog.computeDeliveryFee(cart.subtotal, DeliveryMode.delivery);

    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.shopping_bag_outlined, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'Votre panier est vide',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Parcourez le catalogue et ajoutez vos appareils préférés.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: ProductImagePlaceholder(product: item.product, borderRadius: 12),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(Formatters.fcfa(item.product.price), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _QtyBtn(
                                icon: Icons.remove_rounded,
                                onTap: () => context.read<CartProvider>().setQuantity(item.product.id, item.quantity - 1),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w800)),
                              ),
                              _QtyBtn(
                                icon: Icons.add_rounded,
                                onTap: () => context.read<CartProvider>().setQuantity(item.product.id, item.quantity + 1),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => context.read<CartProvider>().remove(item.product.id),
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: PriceSummary(
            subtotal: cart.subtotal,
            deliveryFee: fee,
            total: cart.subtotal + fee,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
              child: const Text('Passer au paiement'),
            ),
          ),
        ),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.primaryDark),
      ),
    );
  }
}
