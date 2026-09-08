import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/data/banco.dart' show Banco;
import 'package:kitamo/features/importar/importar_page.dart';
import 'package:kitamo/features/importar/ofx_parser.dart';
import 'package:kitamo/repositories/lancamento_repository.dart';

/// A #27 "Importar extrato".
///
/// A regra do design, que é o produto: **nada muda até você aplicar.** Num
/// app de dívida, importar às cegas é o jeito mais rápido de perder a
/// confiança de quem confere contra a fatura.
void main() {
  const tamanhos = [Size(390, 844), Size(360, 640), Size(320, 568)];

  Future<void> em(WidgetTester tester, Size t, Widget tela) async {
    tester.view.physicalSize = t;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: tela));
    await tester.pumpAndSettle();
  }

  Widget tela() {
    final banco = Banco.memoria();
    addTearDown(banco.close);
    return ImportarPage(lancamentos: LancamentoRepositoryDrift(banco));
  }

  for (final t in tamanhos) {
    testWidgets('cabe em ${t.width.toInt()}x${t.height.toInt()}',
        (tester) async {
      await em(tester, t, tela());
      expect(tester.takeException(), equals(null));
    });
  }

  testWidgets('explica de onde tirar o arquivo antes de pedir', (tester) async {
    await em(tester, tamanhos.first, tela());

    // Quem nunca exportou extrato não sabe onde procurar.
    expect(find.textContaining('exportar extrato'), findsOneWidget);
    expect(find.text('escolher arquivo'), findsOneWidget);
  });

  testWidgets('promete que nada sai do aparelho', (tester) async {
    await em(tester, tamanhos.first, tela());

    expect(find.textContaining('não pede senha'), findsOneWidget);
    expect(find.textContaining('nada sai daqui'), findsOneWidget);
  });

  group('o parser, que é o que decide o que entra', () {
    const parser = OfxParser();

    test('lê um extrato de verdade', () {
      final itens = parser.ler('''
<OFX><BANKMSGSRSV1><STMTTRNRS><STMTRS><BANKTRANLIST>
<STMTTRN><TRNTYPE>DEBIT<DTPOSTED>20260903120000<TRNAMT>-40.00
<FITID>ABC1<MEMO>mercado</STMTTRN>
<STMTTRN><TRNTYPE>CREDIT<DTPOSTED>20260905120000<TRNAMT>1800.00
<FITID>ABC2<MEMO>salario</STMTTRN>
</BANKTRANLIST></STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>
''');

      expect(itens, hasLength(2));
      expect(itens.first.descricao, 'mercado');
      expect(itens.first.valor, 40);
      expect(itens.first.ehEntrada, isFalse);
      expect(itens.last.ehEntrada, isTrue, reason: 'valor positivo é entrada');
    });

    test('o mesmo extrato duas vezes não duplica o gasto', () {
      const ofx = '''
<STMTTRN><DTPOSTED>20260903120000<TRNAMT>-40.00<FITID>ABC1<MEMO>mercado</STMTTRN>
''';

      final a = parser.ler(ofx);
      final b = parser.ler(ofx);

      // O id vem do FITID do banco: reimportar atualiza, não soma. Gasto
      // duplicado mente o número pra mais, e é ela quem paga por isso.
      expect(a.first.id, b.first.id);
    });

    test('arquivo que não é extrato não vira lançamento nenhum', () {
      expect(parser.ler('isso aqui não é um OFX'), isEmpty);
    });
  });
}
