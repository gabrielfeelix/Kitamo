import 'package:intl/intl.dart';

final _real = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
final _realSemCentavos = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: r'R$',
  decimalDigits: 0,
);

/// "R$ 1.534,06"
String dinheiro(double v) => _real.format(v);

/// "R$ 23" — para o número gigante, onde centavo é ruído.
String dinheiroRedondo(double v) => _realSemCentavos.format(v);
