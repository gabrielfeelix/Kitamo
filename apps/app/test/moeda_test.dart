import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kitamo/widgets/moeda.dart';

/// O dinheiro na tela.
///
/// A regra veio do Gabriel usando o app: "R$ 2" sozinho parece número
/// cortado — a pessoa não lê "dois reais", lê "dois e falta alguma coisa".
/// Todo valor mostrado tem centavo, e todo valor digitado ganha pontuação
/// enquanto a pessoa digita.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  group('mostrar', () {
    test('sempre com centavos, mesmo em número redondo', () {
      expect(dinheiro(2), contains('2,00'));
      expect(dinheiro(30), contains('30,00'));
      expect(dinheiro(450), contains('450,00'));
    });

    test('milhar com ponto', () {
      expect(dinheiro(3500), contains('3.500,00'));
      expect(dinheiro(1534.06), contains('1.534,06'));
    });

    test('negativo não perde o sinal', () {
      expect(dinheiro(-964), contains('964,00'));
      expect(dinheiro(-964), startsWith('-'));
    });
  });

  group('digitar', () {
    const f = FormatadorDeDinheiro();

    TextEditingValue digitar(String texto) => f.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: texto),
        );

    test('cada dígito empurra pela direita, como caixa de banco', () {
      expect(digitar('3').text, '0,03');
      expect(digitar('35').text, '0,35');
      expect(digitar('350').text, '3,50');
      expect(digitar('3500').text, '35,00');
      expect(digitar('350000').text, '3.500,00');
    });

    test('ignora o que não é dígito', () {
      expect(digitar('R\$ 3.500,00').text, '3.500,00');
      expect(digitar('abc').text, '');
    });

    test('campo vazio não vira zero', () {
      expect(digitar('').text, '');
      expect(lerDinheiro(''), isNull);
    });

    test('o cursor fica no fim, senão o dígito seguinte entra no meio', () {
      final v = digitar('350000');
      expect(v.selection.baseOffset, v.text.length);
    });

    test('dedo preso na tecla não estoura', () {
      expect(() => digitar('9' * 30), returnsNormally);
    });

    test('lê de volta o que escreveu', () {
      expect(lerDinheiro('3.500,00'), 3500);
      expect(lerDinheiro('0,03'), 0.03);
      expect(lerDinheiro('1.534,06'), 1534.06);
    });
  });
}
