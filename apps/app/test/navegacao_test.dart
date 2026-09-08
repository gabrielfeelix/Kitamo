import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/data/banco.dart' show Banco;
import 'package:kitamo/features/backup/backup_service.dart';
import 'package:kitamo/features/casca/casca.dart';
import 'package:kitamo/features/seguranca/bloqueio_service.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/repositories/divida_repository.dart';
import 'package:kitamo/repositories/lancamento_repository.dart';
import 'package:kitamo/repositories/perfil_repository.dart';

/// A barra de navegação depois de 07/09.
///
/// A segunda aba era a lista de lançamentos, e o histórico dia a dia só
/// aparecia clicando em "ver o mês" no cartão do Início. Palavras do
/// Gabriel: *"essa tela é a tela principal da maioria dos sistemas de
/// gestão de dívida, e a gente está tratando ela como secundária"*.
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

  Widget casca() {
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
    );
  }

  for (final t in tamanhos) {
    testWidgets('a casca cabe em ${t.width.toInt()}x${t.height.toInt()}',
        (tester) async {
      await em(tester, t, casca());
      expect(tester.takeException(), equals(null));
    });
  }

  testWidgets('a segunda aba é o histórico, não a lista de lançamentos',
      (tester) async {
    await em(tester, tamanhos.first, casca());

    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Lançamentos'), findsNothing,
        reason: 'os lançamentos saíram da barra e viraram caminho de dentro');
  });

  testWidgets('tocar em Histórico abre o segmentado de dias, meses e ano',
      (tester) async {
    await em(tester, tamanhos.first, casca());

    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(find.text('dias'), findsOneWidget);
    expect(find.text('meses'), findsOneWidget);
    expect(find.text('ano'), findsOneWidget);
  });

  testWidgets('o histórico como aba não tem voltar, mas leva aos lançamentos',
      (tester) async {
    await em(tester, tamanhos.first, casca());

    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    // Aba não tem para onde voltar: a seta seria um beco.
    expect(find.bySemanticsLabel('voltar'), findsNothing);

    // E a lista de lançamentos continua alcançável.
    expect(find.text('lançamentos'), findsOneWidget);
  });
}
