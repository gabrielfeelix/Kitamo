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

    expect(find.textContaining('é o seu diário'), findsOneWidget);
    expect(find.text('parcela do Nubank'), findsOneWidget);
    expect(find.text('quitei essa'), findsOneWidget);
    expect(find.text('6 de 10'), findsOneWidget);
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

    expect(find.text('cai antes do salário do dia 6'), findsOneWidget);
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

    expect(find.text('hoje a conta não fecha'), findsOneWidget);
    expect(find.textContaining('falta por mês'), findsOneWidget);
    // O intl pt-BR usa espaço não-quebrável (U+00A0) entre símbolo e
    // número — não o espaço comum.
    expect(find.textContaining('R\u00A0434'.replaceFirst('R', r'R$')),
        findsOneWidget);
    expect(find.textContaining('é o seu diário'), findsNothing);
  });
}
