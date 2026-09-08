import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/features/horizonte/horizonte_page.dart';
import 'package:kitamo/models/conta_fixa.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/entrada.dart';
import 'package:kitamo/models/lancamento_registro.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/widgets/celula_de_saldo.dart';
import 'package:kitamo/widgets/moeda.dart';

/// O horizonte numa tela só (#09, #10 e #11 do design).
///
/// As três não são telas diferentes: são três corpos da mesma, trocados
/// pelo segmentado do topo. Antes eram duas telas soltas, alcançadas por
/// toques que ninguém adivinhava.
///
/// Medido nos três tamanhos porque overflow não quebra o build, quebra na
/// mão do Gabriel.
void main() {
  const perfil = PerfilFinanceiro(
    nome: 'Gabriel',
    gastoDiarioEstimado: 23.33,
    rendaMensal: 3000,
    diaRenda: 5,
    contasFixasEstimadas: 900,
  );

  final nubank = Divida(
    id: '1',
    nome: 'Nubank',
    saldoAtual: 6136.24,
    valorParcela: 1534.06,
    diaVencimento: 4,
    parcelasRestantes: 4,
    parcelasTotal: 10,
  );

  const tamanhos = [
    Size(390, 844),
    Size(360, 640),
    Size(320, 568),
  ];

  Future<void> em(WidgetTester tester, Size tamanho, Widget tela) async {
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: tela));
    await tester.pumpAndSettle();
  }

  Widget tela({AbaDoHorizonte aba = AbaDoHorizonte.dias}) => HorizontePage(
        perfil: perfil,
        dividas: [nubank],
        abaInicial: aba,
        referencia: DateTime(2026, 9, 6),
        entradas: const [
          Entrada(id: 'e1', nome: 'salário', valor: 1800, dia: 5),
          Entrada(id: 'e2', nome: 'bico', valor: 600, dia: 20),
        ],
        contasFixas: const [
          ContaFixa(id: 'c1', nome: 'aluguel', valor: 900, dia: 10),
        ],
        lancamentos: [
          LancamentoRegistro(
            id: 'l1',
            descricao: 'mercado',
            valor: 40,
            tipo: TipoLancamento.gasto,
            data: DateTime(2026, 9, 3),
          ),
        ],
      );

  for (final aba in AbaDoHorizonte.values) {
    group('aba ${aba.name}', () {
      for (final t in tamanhos) {
        testWidgets('cabe em ${t.width.toInt()}x${t.height.toInt()}',
            (tester) async {
          await em(tester, t, tela(aba: aba));
          expect(tester.takeException(), equals(null));
        });
      }
    });
  }

  group('o segmentado', () {
    testWidgets('as três abas estão sempre no topo', (tester) async {
      for (final aba in AbaDoHorizonte.values) {
        await em(tester, tamanhos.first, tela(aba: aba));

        expect(find.text('dias'), findsOneWidget);
        expect(find.text('meses'), findsOneWidget);
        expect(find.text('ano'), findsOneWidget);
      }
    });

    testWidgets('tocar em meses troca o corpo sem sair da tela',
        (tester) async {
      await em(tester, tamanhos.first, tela());

      // A aba "dias" tem as colunas do #09.
      expect(find.text('PODE GASTAR'), findsOneWidget);

      await tester.tap(find.text('meses'));
      await tester.pumpAndSettle();

      expect(find.text('horizonte de saldos'), findsOneWidget);
      expect(find.text('PODE GASTAR'), findsNothing);
      // Continua sendo a mesma tela: o segmentado não sumiu.
      expect(find.text('dias'), findsOneWidget);
    });

    testWidgets('tocar em ano mostra quando a última parcela cai',
        (tester) async {
      await em(tester, tamanhos.first, tela());

      await tester.tap(find.text('ano'));
      await tester.pumpAndSettle();

      expect(find.text('SUA ÚLTIMA PARCELA CAI EM'), findsOneWidget);
      expect(find.text('quitado'), findsOneWidget);
    });
  });

  group('aba meses', () {
    testWidgets('os três meses são encadeados, não três cópias',
        (tester) async {
      await em(tester, tamanhos.first, tela(aba: AbaDoHorizonte.meses));

      // Cada coluna começa onde a anterior fechou. Recomeçar do zero
      // faria as três saírem idênticas, e a tela existe para mostrar o
      // contrário: o vermelho anda pra frente e some.
      //
      // Os três meses são futuros, então o diário entra como previsão e
      // as colunas divergem. Se saíssem iguais, o encadeamento sumiu.
      final celulas = find.byType(CelulaDeSaldo);
      expect(celulas, findsWidgets);

      final valores = tester
          .widgetList<CelulaDeSaldo>(celulas)
          .map((c) => c.valor)
          .toSet();
      expect(valores.length, greaterThan(1),
          reason: 'três colunas idênticas = encadeamento perdido');
    });

    testWidgets('mostra as abas de período com os três meses',
        (tester) async {
      await em(tester, tamanhos.first, tela(aba: AbaDoHorizonte.meses));

      expect(find.text('set/26'), findsOneWidget);
      expect(find.text('out/26'), findsOneWidget);
      expect(find.text('nov/26'), findsOneWidget);
    });
  });

  group('aba ano', () {
    testWidgets('a sobra prometida é a do mês, não o acumulado',
        (tester) async {
      await em(tester, tamanhos.first, tela(aba: AbaDoHorizonte.ano));

      expect(find.text('SUA ÚLTIMA PARCELA CAI EM'), findsOneWidget);

      // O saldo acumulado segue negativo por meses depois da quitação em
      // quem passou o ano no vermelho. Prometer isso como "sobra" seria
      // dizer que ela sobra menos zero.
      final texto = find.textContaining('depois dela sobram');
      if (texto.evaluate().isNotEmpty) {
        final w = tester.widget<Text>(texto.first);
        expect(w.data, isNot(contains('-')),
            reason: 'sobra prometida nunca é negativa');
      }
    });
  });

  group('aba dias', () {
    testWidgets('mostra as quatro colunas do design', (tester) async {
      await em(tester, tamanhos.first, tela());

      expect(find.text('DIA'), findsOneWidget);
      expect(find.text('PODE GASTAR'), findsOneWidget);
      expect(find.text('GASTOU'), findsOneWidget);
      expect(find.text('SALDO'), findsOneWidget);
    });

    testWidgets('o rodapé barro traz a média gasta', (tester) async {
      await em(tester, tamanhos.first, tela());

      expect(find.text('GASTOU EM MÉDIA'), findsOneWidget);
      // Um dia com gasto: a média é o próprio gasto, com centavo.
      expect(find.text(dinheiro(40)), findsWidgets);
    });

    testWidgets('as setas andam de mês', (tester) async {
      await em(tester, tamanhos.first, tela());
      expect(find.text('set/26'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('próximo mês'));
      await tester.pumpAndSettle();

      expect(find.text('out/26'), findsOneWidget);
    });
  });

  group('a voz', () {
    testWidgets('todo valor sai com centavo', (tester) async {
      await em(tester, tamanhos.first, tela());

      // "R$ 23" sozinho parece número cortado.
      expect(find.text(dinheiro(23.33)), findsWidgets);
    });
  });
}
