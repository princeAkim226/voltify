import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/mock_catalog.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import 'order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _processing = false;
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final draft = context.read<CheckoutDraft>();
    if (draft.paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez un moyen de paiement')),
      );
      return;
    }
    if (_phoneController.text.trim().length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez le numéro Mobile Money')),
      );
      return;
    }

    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));

    if (!mounted) return;
    final cart = context.read<CartProvider>();
    final loyalty = context.read<LoyaltyProvider>();
    final orders = context.read<OrderProvider>();

    final items = cart.items.toList();
    final loyaltyDiscount = loyalty.discountForSubtotal(cart.subtotal);
    final earned = await loyalty.awardForItems(items);
    final order = await orders.placeOrder(
      items: items,
      customerName: draft.name,
      phone: draft.phone,
      email: draft.email.isEmpty ? null : draft.email,
      deliveryMode: draft.deliveryMode,
      address: draft.address,
      city: draft.city,
      pickupPointId: draft.pickupPointId,
      paymentMethod: draft.paymentMethod!,
      pointsEarned: earned,
      loyaltyDiscount: loyaltyDiscount,
    );
    cart.clear();
    draft.resetPayment();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<CheckoutDraft>();
    final cart = context.watch<CartProvider>();
    final loyalty = context.watch<LoyaltyProvider>();
    final fee = MockCatalog.computeDeliveryFee(cart.subtotal, draft.deliveryMode);
    final discount = loyalty.discountForSubtotal(cart.subtotal);
    final total = (cart.subtotal - discount + fee).clamp(0, 1 << 31);

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement mobile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primaryLight]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Montant à payer', style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
                const SizedBox(height: 4),
                Text(
                  Formatters.fcfa(total),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  'Simulation — les API réelles seront branchées plus tard',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Choisissez l’opérateur', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...PaymentMethod.values.map((method) {
            final selected = draft.paymentMethod == method;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => draft.update(paymentMethod: method),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? _colorFor(method) : AppColors.border,
                      width: selected ? 1.8 : 1,
                    ),
                    color: selected ? _colorFor(method).withValues(alpha: 0.08) : AppColors.surface,
                  ),
                  child: Row(
                    children: [
                      _PaymentLogo(method: method),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(method.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                            const Text(
                              'Paiement Mobile Money',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: selected ? _colorFor(method) : AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Numéro ${draft.paymentMethod?.label ?? 'Mobile Money'}',
              hintText: '70 XX XX XX',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _processing ? null : _pay,
              child: _processing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : Text('Payer ${Formatters.fcfa(total)}'),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.orangeMoney:
        return AppColors.orangeMoney;
      case PaymentMethod.moovMoney:
        return AppColors.moovMoney;
      case PaymentMethod.telecelMoney:
        return AppColors.telecelMoney;
      case PaymentMethod.wave:
        return AppColors.wave;
    }
  }
}

class _PaymentLogo extends StatelessWidget {
  const _PaymentLogo({required this.method});

  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final color = switch (method) {
      PaymentMethod.orangeMoney => AppColors.orangeMoney,
      PaymentMethod.moovMoney => AppColors.moovMoney,
      PaymentMethod.telecelMoney => AppColors.telecelMoney,
      PaymentMethod.wave => AppColors.wave,
    };

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        method.shortCode,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
      ),
    );
  }
}
