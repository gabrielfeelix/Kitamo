import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/features/inicio/inicio_page.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';

/// A tela precisa dizer a verdade nos dois estados. O caso difícil é o
/// segundo: quando a conta não fecha, o app não pode mostrar "R$ 0" como
/// se fosse um diário.
void main() {
  Widget montar({required PerfilFinanceiro perfil, required List<Divida> dividas}) =>
      MaterialApp(home: InicioPage(perfil: perfil, dividas: dividas));

  final nubank = Divida(
    id: '1',
    nome: 'Nubank',
    saldoAtual: 6136.24,
    valorParcela: 1534.06,
    diaVencimento: 4,
    parcelasRestantes: 4,
    parcelasTotal: 10,
  );

  testWidgets('mostra o diário e a próxima parcela quando a conta fecha',
      (tester) async {
    await tester.pumpWidget(montar(
      perfil: const PerfilFinanceiro(
        rendaMensal: 5000,
        diaRenda: 6,
        contasFixasEstimadas: 900,
      ),
      dividas: [nubank],
    ));

    // O rótulo do cabeçalho é o do design, e vai em caixa alta na tela.
    expect(find.textContaining(RegExp('você pode gastar hoje',
        caseSensitive: false)), findsOneWidget);
    expect(find.text('dia 4 · Nubank'), findsOneWidget);
    expect(find.text('quitei essa'), findsOneWidget);
    // O cartão de acento conta as parcelas pagas.
    expect(find.textContaining('6 de 10'), findsOneWidget);
  });

  testWidgets('avisa quando a parcela cai antes do salário', (tester) async {
    await tester.pumpWidget(montar(
      perfil: const PerfilFinanceiro(
        rendaMensal: 5000,
        diaRenda: 6,
        contasFixasEstimadas: 900,
      ),
      dividas: [nubank],
    ));

    // A faixa âmbar do design: "ela cai antes do salário do dia 6", com o
    // "antes" em negrito — por isso a busca é pelo RichText inteiro.
    expect(
      find.byWidgetPredicate((w) =>
          w is RichText &&
          w.text.toPlainText().contains('antes do salário do dia 6')),
      findsOneWidget,
    );
  });

  testWidgets('quando a conta não fecha, diz quanto falta em vez de zero',
      (tester) async {
    await tester.pumpWidget(montar(
      perfil: const PerfilFinanceiro(
        rendaMensal: 2000,
        diaRenda: 6,
        contasFixasEstimadas: 900,
      ),
      dividas: [nubank],
    ));

    expect(
      find.textContaining(
          RegExp('falta por mês pra conta fechar', caseSensitive: false)),
      findsOneWidget,
    );
    expect(find.textContaining('a conta não fecha'), findsOneWidget);
    // O intl pt-BR usa espaço não-quebrável (U+00A0) entre símbolo e
    // número — não o espaço comum.
    expect(find.textContaining('R\u00A0434'.replaceFirst('R', r'R$')),
        findsOneWidget);
    // A regra que não se quebra: nada de "R$ 0 por dia".
    expect(find.textContaining(RegExp('você pode gastar hoje',
        caseSensitive: false)), findsNothing);
  });
}
