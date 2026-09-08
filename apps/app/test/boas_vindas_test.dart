import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/data/banco.dart' show Banco;
import 'package:kitamo/features/onboarding/abertura_page.dart';
import 'package:kitamo/features/onboarding/boas_vindas_page.dart';
import 'package:kitamo/features/onboarding/onboarding_controller.dart';
import 'package:kitamo/features/onboarding/onboarding_page.dart';
import 'package:kitamo/repositories/divida_repository.dart';
import 'package:kitamo/repositories/perfil_repository.dart';

/// As telas de entrada, em tamanho de celular de verdade.
///
/// Estes testes existem por um bug que só apareceu no aparelho: a coluna
/// das boas-vindas estourava 12px, o botão "começar" ficava fora da área
/// tocável, e o app abria sem deixar a pessoa sair da primeira tela.
/// Overflow não quebra o build nem o teste comum — quebra na mão de quem
/// usa. Por isso cada tela de entrada é medida aqui.
void main() {
  Future<void> em(
    WidgetTester tester,
    Size tamanho,
    Widget tela,
  ) async {
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: tela));
  }

  // 390x844 é a moldura do design; 360x640 é o celular baixo e barato,
  // que é justamente o de quem está endividado.
  const telas = [Size(390, 844), Size(360, 640), Size(320, 568)];

  group('boas-vindas', () {
    testWidgets('o botão começar chama o callback', (tester) async {
      var chamou = false;
      await em(tester, const Size(390, 844),
          BoasVindasPage(aoComecar: () => chamou = true));

      await tester.tap(find.text('começar'));
      await tester.pump();

      expect(chamou, isTrue);
    });

    for (final t in telas) {
      testWidgets('cabe e o botão funciona em ${t.width}x${t.height}',
          (tester) async {
        var chamou = false;
        await em(tester, t, BoasVindasPage(aoComecar: () => chamou = true));

        expect(tester.takeException(), isNull);

        // O botão fica sempre visível, sem precisar rolar: a ilustração é
        // que cede espaço. `warnIfMissed: false` não entra aqui de
        // propósito — se o toque errar o alvo, o teste tem que falhar.
        await tester.tap(find.text('começar'));
        await tester.pump();
        expect(chamou, isTrue,
            reason: 'o botão ficou fora da área tocável em $t');
      });
    }

    testWidgets('a promessa do design está na tela', (tester) async {
      await em(tester, const Size(390, 844), BoasVindasPage(aoComecar: () {}));

      expect(find.textContaining('primeiro a gente quita'), findsOneWidget);
      expect(find.textContaining('90 segundos'), findsOneWidget);
      expect(find.text('já tenho conta'), findsOneWidget);
    });
  });

  group('abertura', () {
    testWidgets('mostra o verbo no gerúndio e sai sozinha', (tester) async {
      var terminou = false;
      await em(tester, const Size(390, 844),
          AberturaPage(aoTerminar: () => terminou = true));

      expect(find.text('Kitamo'), findsOneWidget);
      expect(find.textContaining('somando as parcelas'), findsOneWidget);
      expect(terminou, isFalse);

      await tester.pump(AberturaPage.duracao);
      expect(terminou, isTrue);

      await tester.pumpAndSettle();
    });
  });

  group('as perguntas', () {
    late Banco banco;
    late OnboardingController c;

    setUp(() {
      banco = Banco.memoria();
      c = OnboardingController(
        perfis: PerfilRepositoryDrift(banco),
        dividas: DividaRepositoryDrift(banco),
      );
    });

    tearDown(() => banco.close());

    for (final t in telas) {
      testWidgets('a primeira pergunta cabe em ${t.width}x${t.height}',
          (tester) async {
        await em(
          tester,
          t,
          OnboardingPage(controller: c, aoConcluir: () {}),
        );

        expect(tester.takeException(), isNull);

        // A primeira agora é o nome: o app dava "bom dia, Gabriel" sem
        // nunca ter perguntado como a pessoa se chama.
        expect(find.text('como a gente te chama?'), findsOneWidget);

        await tester.tap(find.text('continuar'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('qual o total das suas dívidas?'), findsOneWidget);
      });
    }

    testWidgets('as faixas do design aparecem e marcam', (tester) async {
      await em(tester, const Size(390, 844),
          OnboardingPage(controller: c, aoConcluir: () {}));

      // Passa o nome para chegar na pergunta da dívida.
      await tester.tap(find.text('continuar'));
      await tester.pumpAndSettle();

      expect(find.text('até R\$ 5 mil'), findsOneWidget);
      expect(find.text('não sei, quero descobrir'), findsOneWidget);

      await tester.tap(find.text('entre R\$ 10 e R\$ 15 mil'));
      await tester.pump();

      expect(c.faixa, FaixaDeDivida.entre10e15);
      expect(find.text('É O MEU CASO'), findsOneWidget);
    });

    testWidgets('em quantas vezes aparece ao digitar, e cabe lado a lado',
        (tester) async {
      await em(tester, const Size(390, 844),
          OnboardingPage(controller: c, aoConcluir: () {}));

      await tester.tap(find.text('continuar'));
      await tester.pumpAndSettle();

      // Sem valor a pergunta não faz sentido: não tem o que parcelar.
      expect(find.text('EM QUANTAS VEZES?'), findsNothing);

      c.digitarTotal(6000);
      await tester.pumpAndSettle();

      expect(find.text('EM QUANTAS VEZES?'), findsOneWidget);
      expect(find.text('não sei'), findsOneWidget);

      // As pílulas ficam lado a lado. Dentro de uma coluna esticada o
      // Wrap recebia a largura toda e empilhava uma por linha, jogando
      // as últimas para debaixo do botão.
      final tresX = tester.getRect(find.text('3x'));
      final seisX = tester.getRect(find.text('6x'));
      expect(seisX.left, greaterThan(tresX.right),
          reason: '6x tem que estar à direita de 3x, não embaixo');
      expect(seisX.top, closeTo(tresX.top, 1));

      await tester.tap(find.text('6x'));
      await tester.pump();
      expect(c.parcelasDoTotal, 6);
    });

    testWidgets('a última pergunta oferece os três jeitos, com botão',
        (tester) async {
      await em(tester, const Size(390, 844),
          OnboardingPage(controller: c, aoConcluir: () {}));

      // Vai até a última.
      for (var i = 0; i < PassoOnboarding.values.length - 1; i++) {
        await tester.tap(find.text('continuar'));
        await tester.pumpAndSettle();
      }

      expect(c.passo, PassoOnboarding.extrato);

      // Antes esta tela perguntava "quer conferir com o seu extrato?" e
      // não tinha botão nenhum: perguntava e não oferecia ação.
      expect(find.text('eu lanço na hora'), findsOneWidget);
      expect(find.text('importar o extrato'), findsOneWidget);
      expect(find.text('conectar meu banco'), findsOneWidget);

      // O que ainda não funciona diz que não funciona.
      expect(find.text('EM BREVE'), findsOneWidget);

      await tester.tap(find.text('importar o extrato'));
      await tester.pump();
      expect(c.comoTrazer, ComoTrazerGastos.extrato);
    });

    testWidgets('continuar anda por todas as perguntas sem estourar',
        (tester) async {
      await em(tester, const Size(360, 640),
          OnboardingPage(controller: c, aoConcluir: () {}));

      for (var i = 0; i < PassoOnboarding.values.length - 1; i++) {
        expect(tester.takeException(), isNull,
            reason: 'estourou no passo ${c.passo.name}');
        await tester.tap(find.text('continuar'));
        await tester.pumpAndSettle();
      }

      expect(c.passo, PassoOnboarding.extrato);
      expect(find.text('ver meu plano'), findsOneWidget);
    });
  });

  testWidgets('o dedo de verdade alcança o botão começar', (tester) async {
    var chamou = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: BoasVindasPage(aoComecar: () => chamou = true),
    ));

    // Bate no centro do botão via gesto cru, sem o atalho do tester.tap:
    // é o que reproduz o toque do aparelho.
    final centro = tester.getCenter(find.text('começar'));
    final gesto = await tester.startGesture(centro);
    await gesto.up();
    await tester.pumpAndSettle();

    expect(chamou, isTrue, reason: 'o toque real não chegou no botão');
  });

  group('dá pra voltar', () {
    late Banco banco;
    late OnboardingController c;

    setUp(() {
      banco = Banco.memoria();
      c = OnboardingController(
        perfis: PerfilRepositoryDrift(banco),
        dividas: DividaRepositoryDrift(banco),
      );
    });

    tearDown(() => banco.close());

    testWidgets('a primeira pergunta não tem voltar', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: OnboardingPage(controller: c, aoConcluir: () {}),
      ));

      expect(find.byTooltip('voltar'), findsNothing);
    });

    testWidgets('da segunda em diante, voltar retrocede um passo',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: OnboardingPage(controller: c, aoConcluir: () {}),
      ));

      await tester.tap(find.text('continuar'));
      await tester.pumpAndSettle();
      expect(c.passo, PassoOnboarding.divida);

      await tester.tap(find.byTooltip('voltar'));
      await tester.pumpAndSettle();

      expect(c.passo, PassoOnboarding.nome,
          reason: 'sem voltar, quem errou fica preso até o fim');
    });

    testWidgets('dá pra voltar de qualquer passo até o começo',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: OnboardingPage(controller: c, aoConcluir: () {}),
      ));

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('continuar'));
        await tester.pumpAndSettle();
      }

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byTooltip('voltar'));
        await tester.pumpAndSettle();
      }

      expect(c.passo, PassoOnboarding.nome);
    });
  });
}
