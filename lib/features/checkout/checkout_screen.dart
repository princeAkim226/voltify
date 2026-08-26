import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_catalog.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';
import '../../shared/widgets/common_widgets.dart';
import '../payment/payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final draft = context.read<CheckoutDraft>();
    _name = TextEditingController(text: draft.name);
    _phone = TextEditingController(text: draft.phone);
    _email = TextEditingController(text: draft.email);
    _address = TextEditingController(text: draft.address);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<CheckoutDraft>();
    final cart = context.watch<CartProvider>();
    final fee = MockCatalog.computeDeliveryFee(cart.subtotal, draft.deliveryMode);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text('Coordonnées (invité OK)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'Pas besoin de compte pour commander.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nom complet *'),
              validator: (v) => (v == null || v.trim().length < 2) ? 'Indiquez votre nom' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Téléphone *', hintText: 'ex. 70 00 00 00'),
              validator: (v) => (v == null || v.trim().length < 8) ? 'Numéro invalide' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email (optionnel)'),
            ),
            const SizedBox(height: 22),
            Text('Mode de réception', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ModeCard(
                    selected: draft.deliveryMode == DeliveryMode.delivery,
                    title: 'Livraison',
                    subtitle: 'Ouaga & Bobo',
                    icon: Icons.local_shipping_rounded,
                    onTap: () => draft.update(deliveryMode: DeliveryMode.delivery),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ModeCard(
                    selected: draft.deliveryMode == DeliveryMode.pickup,
                    title: 'Retrait',
                    subtitle: 'Magasin Voltify',
                    icon: Icons.storefront_rounded,
                    onTap: () => draft.update(deliveryMode: DeliveryMode.pickup),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (draft.deliveryMode == DeliveryMode.delivery) ...[
              DropdownButtonFormField<String>(
                value: draft.city,
                decoration: const InputDecoration(labelText: 'Ville'),
                items: const [
                  DropdownMenuItem(value: 'Ouagadougou', child: Text('Ouagadougou')),
                  DropdownMenuItem(value: 'Bobo-Dioulasso', child: Text('Bobo-Dioulasso')),
                ],
                onChanged: (v) => draft.update(city: v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Adresse de livraison *'),
                validator: (v) {
                  if (draft.deliveryMode != DeliveryMode.delivery) return null;
                  return (v == null || v.trim().length < 5) ? 'Adresse requise' : null;
                },
              ),
            ] else ...[
              ...MockCatalog.pickupPoints.map((p) {
                final selected = draft.pickupPointId == p.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => draft.update(pickupPointId: p.id),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
                        color: selected ? AppColors.primarySoft : AppColors.surface,
                      ),
                      child: Row(
                        children: [
                          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                Text(p.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                Text('${p.city} · ${p.hours}', style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 16),
            PriceSummary(subtotal: cart.subtotal, deliveryFee: fee, total: cart.subtotal + fee),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  draft.update(
                    name: _name.text.trim(),
                    phone: _phone.text.trim(),
                    email: _email.text.trim(),
                    address: _address.text.trim(),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaymentScreen()),
                  );
                },
                child: const Text('Choisir le paiement'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
          color: selected ? AppColors.primarySoft : AppColors.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
