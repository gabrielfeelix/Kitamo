import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/data/banco.dart' show Banco;
import 'package:kitamo/features/backup/backup_service.dart';
import 'package:kitamo/features/casca/casca.dart';
import 'package:kitamo/features/inicio/cabecalho_do_inicio.dart';
import 'package:kitamo/features/primeira_vez/primeira_vez.dart';
import 'package:kitamo/features/seguranca/bloqueio_service.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/repositories/divida_repository.dart';
import 'package:kitamo/repositories/lancamento_repository.dart';
import 'package:kitamo/repositories/perfil_repository.dart';

/// A #32 "Primeira vez": o **onboarding de verdade**.
///
/// Não é o resultado (#17) nem as perguntas iniciais. É o que ensina a
/// usar, depois de tudo respondido. Palavras do Gabriel: *"onboarding é
/// dps q eu respondi tudo oq vai me ensinar a usar o app"*.
void main() {
  const tamanhos = [Size(390, 844), Size(360, 640), Size(320, 568)];

  final nubank = Divida(
    id: '1',
    nome: 'Nubank',
    saldoAtual: 6136.24,
    valorParcela: 500,
    diaVencimento: 4,
    parcelasRestantes: 4,
    parcelasTotal: 10,
  );

  const perfil = PerfilFinanceiro(
    nome: 'Gabriel',
    rendaMensal: 3000,
    diaRenda: 5,
    gastoDiarioEstimado: 23.33,
    contasFixasEstimadas: 900,
  );

  Future<void> em(WidgetTester tester, Size t, Widget tela) async {
    tester.view.physicalSize = t;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: tela));
    await tester.pumpAndSettle();
  }

  Widget casca({bool ensinar = true, VoidCallback? aoTerminar}) {
    final banco = Banco.memoria();
    addTearDown(banco.close);

    return Casca(
      perfil: perfil,
      dividas: [nubank],
      lancamentos: LancamentoRepositoryDrift(banco),
      backup: BackupService(
        PerfilRepositoryDrift(banco),
        DividaRepositoryDrift(banco),
      ),
      bloqueio: BloqueioService(),
      ensinarAUsar: ensinar,
      aoTerminarDeEnsinar: aoTerminar,
    );
  }

  for (final t in tamanhos) {
    testWidgets('cabe em ${t.width.toInt()}x${t.height.toInt()}',
        (tester) async {
      await em(tester, t, casca());
      expect(tester.takeException(), equals(null));
    });
  }

  testWidgets('são três passos, e o primeiro explica o número',
      (tester) async {
    await em(tester, tamanhos.first, casca());

    expect(find.text('1 DE 3 · ESSE NÚMERO'), findsOneWidget);
    expect(find.textContaining('sem atrasar a quitação'), findsOneWidget);
  });

  testWidgets('entendi anda os três e termina', (tester) async {
    var terminou = false;
    await em(tester, tamanhos.first,
        casca(aoTerminar: () => terminou = true));

    await tester.tap(find.text('entendi'));
    await tester.pumpAndSettle();
    expect(find.text('2 DE 3 · O BOTÃO DO MEIO'), findsOneWidget);

    await tester.tap(find.text('entendi'));
    await tester.pumpAndSettle();
    expect(find.text('3 DE 3 · O HISTÓRICO'), findsOneWidget);

    await tester.tap(find.text('entendi'));
    await tester.pumpAndSettle();

    expect(terminou, isTrue);
    expect(find.textContaining('DE 3'), findsNothing);
  });

  testWidgets('pular sai na hora, de qualquer passo', (tester) async {
    var terminou = false;
    await em(tester, tamanhos.first,
        casca(aoTerminar: () => terminou = true));

    // Nada pode prender a pessoa: é regra do design system.
    await tester.tap(find.text('pular'));
    await tester.pumpAndSettle();

    expect(terminou, isTrue);
    expect(find.textContaining('DE 3'), findsNothing);
  });

  testWidgets('ensina por cima do app de verdade, não de um desenho',
      (tester) async {
    await em(tester, tamanhos.first, casca());

    // O Início continua montado atrás do véu: a pessoa aprende olhando o
    // próprio número, não um exemplo inventado. A saudação muda com a
    // hora, então vem do mesmo lugar que a tela usa.
    expect(find.textContaining(saudacaoDaHora()), findsWidgets);
    expect(find.text('Histórico'), findsOneWidget);
  });

  testWidgets('quem já viu não vê de novo', (tester) async {
    await em(tester, tamanhos.first, casca(ensinar: false));

    expect(find.textContaining('DE 3'), findsNothing);
  });

  testWidgets('o último passo não promete o que vem depois', (tester) async {
    await em(tester, tamanhos.first, casca());

    await tester.tap(find.text('entendi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('entendi'));
    await tester.pumpAndSettle();

    // Os dois primeiros têm a fala do joão dizendo o que vem; o último
    // não, porque não vem mais nada.
    expect(
      PrimeiraVez.passosPadrao.last.rodape,
      equals(null),
      reason: 'prometer um quarto passo que não existe seria mentira',
    );
  });
}
