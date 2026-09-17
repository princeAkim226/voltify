import 'package:flutter/material.dart';

import '../../core/services/update_service.dart';
import '../../core/theme/app_colors.dart';

/// Propose la mise à jour, la télécharge et lance l'installateur.
///
/// Quand [release.minBuild] dépasse la version installée, la feuille devient
/// bloquante : l'app est trop ancienne pour afficher le bon catalogue, la
/// laisser ouverte tromperait le client.
class UpdateSheet extends StatefulWidget {
  const UpdateSheet({
    super.key,
    required this.release,
    required this.blocking,
  });

  final AppRelease release;
  final bool blocking;

  static Future<void> show(
    BuildContext context, {
    required AppRelease release,
    required bool blocking,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: !blocking,
      enableDrag: !blocking,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PopScope(
        canPop: !blocking,
        child: UpdateSheet(release: release, blocking: blocking),
      ),
    );
  }

  @override
  State<UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends State<UpdateSheet> {
  bool _busy = false;
  double? _progress;
  String? _error;

  Future<void> _install() async {
    setState(() {
      _busy = true;
      _error = null;
      _progress = 0;
    });
    try {
      await UpdateService.downloadAndInstall(
        widget.release,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      // L'installateur système prend le relais : on laisse la feuille ouverte,
      // le client peut annuler et revenir à l'app.
      if (mounted) setState(() => _busy = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _progress = null;
        // Les messages du service disent ce qui a échoué — téléchargement
        // incomplet, fichier intercepté. Les masquer derrière « vérifiez votre
        // connexion » laisse le client relancer indéfiniment la même erreur.
        final detail = e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : '';
        _error = detail.isEmpty
            ? 'Téléchargement impossible. Vérifiez votre connexion.'
            : detail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.release;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.system_update_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.blocking
                ? 'Mise à jour nécessaire'
                : 'Nouvelle version disponible',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            widget.blocking
                ? 'Cette version de Voltify est trop ancienne pour afficher le '
                    'catalogue à jour. Installez la version ${r.version} pour '
                    'continuer.'
                : 'Voltify ${r.version} est disponible.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          if (r.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...r.notes.map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.greenLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        n,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (r.sizeLabel.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.amberSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.download_rounded,
                    size: 16,
                    color: Color(0xFF633806),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Téléchargement de ${r.sizeLabel} — préférez le Wi-Fi.',
                      style: const TextStyle(
                        color: Color(0xFF633806),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            // Quand le réseau du client intercepte le téléchargement, réessayer
            // depuis l'app échouera autant de fois qu'il insistera. Le
            // navigateur, lui, passe souvent.
            const Text(
              'Si cela se reproduit, téléchargez depuis un navigateur : '
              'dl.raaga-bf.com',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
          if (_busy) ...[
            const SizedBox(height: 18),
            LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: AppColors.primarySoft,
            ),
            const SizedBox(height: 8),
            Text(
              _progress == null
                  ? 'Téléchargement…'
                  : 'Téléchargement ${(_progress! * 100).round()} %',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : _install,
              icon: const Icon(Icons.download_rounded),
              label: Text(_error == null ? 'Mettre à jour' : 'Réessayer'),
            ),
          ),
          if (!widget.blocking) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                child: const Text('Plus tard'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
