import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _fcfa = NumberFormat('#,###', 'fr_FR');

  static String fcfa(num amount) {
    final formatted = _fcfa.format(amount).replaceAll('\u202F', ' ').replaceAll(',', ' ');
    return '$formatted FCFA';
  }

  static String compactFcfa(num amount) {
    if (amount >= 1000000) {
      final m = amount / 1000000;
      return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M FCFA';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k FCFA';
    }
    return fcfa(amount);
  }
}
