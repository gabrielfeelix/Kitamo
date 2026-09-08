import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final _real = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
final _semSimbolo = NumberFormat('#,##0.00', 'pt_BR');

/// "R$ 1.534,06"
///
/// **Sempre com centavos.** "R$ 2" sozinho na tela parece número cortado —
/// a pessoa não lê "dois reais", lê "dois e falta alguma coisa". Não existe
/// versão redonda: o design mostra R$ 23 no protótipo, mas na mão do
/// Gabriel isso confundiu, e clareza ganha de economia de dígito.
String dinheiro(double v) => _real.format(v);

/// "1.534,06" — sem o símbolo, para quando o R$ já está desenhado ao lado.
String valor(double v) => _semSimbolo.format(v);

/// Formata enquanto a pessoa digita: 3500 vira "3.500,00".
///
/// Trabalha em centavos, como todo dinheiro no app. Cada tecla empurra um
/// dígito pela direita, que é como funciona caixa de banco e todo app
/// financeiro que a pessoa já usou.
class FormatadorDeDinheiro extends TextInputFormatter {
  const FormatadorDeDinheiro();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue antigo,
    TextEditingValue novo,
  ) {
    final digitos = novo.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Mais de 11 dígitos é dedo preso na tecla, não dinheiro.
    final cortado = digitos.length > 11 ? digitos.substring(0, 11) : digitos;
    final centavos = int.parse(cortado);
    final texto = _semSimbolo.format(centavos / 100);

    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

/// Lê de volta o que o formatador escreveu: "3.500,00" vira 3500.0.
double? lerDinheiro(String texto) {
  final digitos = texto.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitos.isEmpty) return null;
  return int.parse(digitos) / 100;
}
