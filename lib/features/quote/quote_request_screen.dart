import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock/catalog_taxonomy.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_state.dart';

/// Demande de devis pour un article sur mesure.
///
/// Le sur-mesure ne passe pas par le panier : on ne connaît ni les cotes ni
/// le matériau avant d'avoir parlé au client. Cet écran capte la demande
/// plutôt que de la perdre faute de prix affichable.
class QuoteRequestScreen extends StatefulWidget {
  const QuoteRequestScreen({super.key, required this.product});

  final Product product;

  @override
  State<QuoteRequestScreen> createState() => _QuoteRequestScreenState();
}

class _QuoteRequestScreenState extends State<QuoteRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  final _details = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Le brouillon de commande connaît déjà le client s'il a commandé avant.
    final draft = context.read<CheckoutDraft>();
    _name.text = draft.name;
    _phone.text = draft.phone;
    _email.text = draft.email;
    _city.text = draft.city;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _city.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    final request = await context.read<QuoteProvider>().submit(
          product: widget.product,
          customerName: _name.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          city: _city.text.trim().isEmpty ? null : _city.text.trim(),
          details: _details.text.trim(),
        );

    if (!mounted) return;
    // On garde les coordonnées pour la prochaine demande ou commande.
    context.read<CheckoutDraft>().update(
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        );
    setState(() => _sending = false);
    await _showConfirmation(request);
  }

  Future<void> _showConfirmation(QuoteRequest request) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.successSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                color: AppColors.successText,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Demande envoyée',
              style: Theme.of(sheetContext)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Un conseiller Voltify vous rappelle au ${request.phone} sous '
              '48 h ouvrées pour ${request.productName}.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('Terminer'),
              ),
            ),
          ],
        ),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final sub = product.subcategoryId == null
        ? null
        : CatalogTaxonomy.subById(product.categoryId, product.subcategoryId!);

    return Scaffold(
      appBar: AppBar(title: const Text('Demande de devis')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    CatalogTaxonomy.byId(product.categoryId)?.icon ??
                        Icons.category_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CatalogTaxonomy.labelFor(
                            categoryId: product.categoryId,
                            subcategoryId: product.subcategoryId,
                          ),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Vos coordonnées',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nom complet'),
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? 'Nom requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                hintText: '70 XX XX XX',
              ),
              validator: (v) => (v == null || v.trim().length < 8)
                  ? 'Numéro requis pour le rappel'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail (facultatif)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _city,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Ville / quartier',
                hintText: 'Ouagadougou, Zone du Bois',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Votre projet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              sub != null && sub.saleMode.isDevis
                  ? 'Dimensions, matériau souhaité, délai — plus vous en dites, '
                      'plus le chiffrage sera juste.'
                  : 'Précisez la quantité et vos contraintes.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _details,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText:
                    'Ex. : cuisine en L de 3,20 m × 2,10 m, MDF laqué blanc, '
                    'plan de travail granit, livraison avant fin mars.',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _sending ? null : _submit,
              child: _sending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Envoyer la demande'),
            ),
          ),
        ),
      ),
    );
  }
}
