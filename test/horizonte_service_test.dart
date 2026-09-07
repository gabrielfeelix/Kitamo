import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/design/cores.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/services/horizonte_service.dart';

/// Fase 3: o horizonte.
///
/// O risco que estes testes guardam é uma parcela sumir da projeção. Um
/// vencimento dia 31 não existe em fevereiro; se o cálculo exigir dia
/// exato, a parcela desaparece justo no mês mais curto — e o app mostra um
/// mês folgado que não existe.
void main() {
  const service = HorizonteService();

  Divida divida({
    String nome = 'Nubank',
    double parcela = 1534.06,
    int vencimento = 4,
    int restantes = 4,
    int total = 10,
  }) =>
      Divida(
        id: nome,
        nome: nome,
        saldoAtual: 0,
        valorParcela: parcela,
        diaVencimento: vencimento,
        parcelasRestantes: restantes,
        parcelasTotal: total,
      );

  group('mês', () {
    test('cada linha tem nome e valor', () {
      final m = service.mes(
        perfil: const PerfilFinanceiro(rendaMensal: 3000, diaRenda: 5),
        dividas: [divida()],
        saldoInicial: 5000,
        referencia: DateTime(2026, 9, 1),
      );

      final dia4 = m.dias.firstWhere((d) => d.dia == 4);
      expect(dia4.lancamentos.first.nome, 'parcela do Nubank');
      expect(dia4.lancamentos.first.valor, 1534.06);
      expect(dia4.lancamentos.first.entrada, isFalse);

      final dia5 = m.dias.firstWhere((d) => d.dia == 5);
      expect(dia5.lancamentos.first.nome, 'salário');
      expect(dia5.lancamentos.first.entrada, isTrue);
    });

    test('explica quando a parcela cai antes do salário', () {
      final m = service.mes(
        perfil: const PerfilFinanceiro(rendaMensal: 3000, diaRenda: 6),
        dividas: [divida()],
        saldoInicial: 100,
        referencia: DateTime(2026, 9, 1),
      );

      final dia4 = m.dias.firstWhere((d) => d.dia == 4);
      expect(dia4.estado, EstadoFinanceiro.aperto);
      expect(dia4.motivo, 'a parcela do Nubank cai antes do salário do dia 6');
    });

    test('dia tranquilo não tem motivo', () {
      final m = service.mes(
        perfil: const PerfilFinanceiro(rendaMensal: 3000, diaRenda: 5),
        dividas: [],
        saldoInicial: 10000,
        referencia: DateTime(2026, 9, 1),
      );

      expect(m.dias.first.estado, EstadoFinanceiro.tranquilo);
      expect(m.dias.first.motivo, isNull);
    });

    test('saldo baixo vira atenção antes de estourar', () {
      final m = service.mes(
        perfil: const PerfilFinanceiro(),
        dividas: [],
        saldoInicial: 50,
        referencia: DateTime(2026, 9, 1),
      );

      expect(m.dias.first.estado, EstadoFinanceiro.atencao);
      expect(m.dias.first.motivo, 'o saldo fica baixo neste dia');
    });

    test('parcela dia 31 não some em fevereiro', () {
      final m = service.mes(
        perfil: const PerfilFinanceiro(),
        dividas: [divida(nome: 'Crediário', parcela: 200, vencimento: 31, restantes: 12)],
        saldoInicial: 10000,
        referencia: DateTime(2026, 2, 1),
      );

      final comLancamento = m.dias.where((d) => d.lancamentos.isNotEmpty);
      expect(comLancamento, hasLength(1));
      expect(comLancamento.first.dia, 28);
    });

    test('gasto diário consome o saldo', () {
      final m = service.mes(
        perfil: const PerfilFinanceiro(gastoDiarioEstimado: 10),
        dividas: [],
        saldoInicial: 1000,
        referencia: DateTime(2026, 9, 1),
      );

      expect(m.dias[0].saldo, 990);
      expect(m.dias[1].saldo, 980);
      expect(m.saldoFinal, 700); // 30 dias × 10
    });

    test('marca o primeiro dia apertado', () {
      final m = service.mes(
        perfil: const PerfilFinanceiro(rendaMensal: 3000, diaRenda: 20),
        dividas: [divida(parcela: 500, vencimento: 10)],
        saldoInicial: 100,
        referencia: DateTime(2026, 9, 1),
      );

      expect(m.primeiroDiaApertado, DateTime(2026, 9, 10));
    });

    test('dívida quitada não entra', () {
      final quitada = Divida(
        id: 'q',
        nome: 'Paga',
        saldoAtual: 0,
        valorParcela: 900,
        diaVencimento: 10,
        parcelasRestantes: 0,
        parcelasTotal: 3,
        quitadaEm: DateTime(2026, 1, 1),
      );

      final m = service.mes(
        perfil: const PerfilFinanceiro(),
        dividas: [quitada],
        saldoInicial: 1000,
        referencia: DateTime(2026, 9, 1),
      );

      expect(m.saldoFinal, 1000);
      expect(m.dias.where((d) => d.lancamentos.isNotEmpty), isEmpty);
    });

    test('sem perfil não quebra', () {
      final m = service.mes(
        perfil: null,
        dividas: [],
        saldoInicial: 0,
        referencia: DateTime(2026, 9, 1),
      );

      expect(m.dias, hasLength(30));
    });

    test('toda combinação de vencimento e renda aparece uma vez por mês', () {
      // 24 meses × 7 vencimentos × 4 dias de renda. A garantia: cada
      // lançamento aparece exatamente uma vez — nunca zero (some), nunca
      // duas (duplica).
      for (final venc in [1, 4, 15, 28, 29, 30, 31]) {
        for (final diaRenda in [1, 5, 28, 31]) {
          for (var i = 0; i < 24; i++) {
            final ref = DateTime(2026, 1 + i, 1);

            final m = service.mes(
              perfil: PerfilFinanceiro(rendaMensal: 3000, diaRenda: diaRenda),
              dividas: [divida(nome: 'X', parcela: 100, vencimento: venc, restantes: 36)],
              saldoInicial: 50000,
              referencia: ref,
            );

            final parcelas = m.dias
                .expand((d) => d.lancamentos)
                .where((l) => l.nome == 'parcela do X');
            final salarios = m.dias
                .expand((d) => d.lancamentos)
                .where((l) => l.nome == 'salário');

            expect(parcelas, hasLength(1),
                reason: 'vencimento $venc em ${ref.year}-${ref.month}');
            expect(salarios, hasLength(1),
                reason: 'renda dia $diaRenda em ${ref.year}-${ref.month}');
          }
        }
      }
    });
  });

  group('12 meses', () {
    test('mostra a dívida acabando', () {
      final doze = service.doze(
        perfil: const PerfilFinanceiro(
          rendaMensal: 3000,
          diaRenda: 5,
          contasFixasEstimadas: 1000,
        ),
        dividas: [divida(parcela: 1500, restantes: 4)],
        saldoInicial: 0,
        referencia: DateTime(2026, 9, 1),
      );

      expect(doze, hasLength(12));
      expect(doze[0].rotulo, 'set/26');
      expect(doze[0].temDivida, isTrue);
      expect(doze[0].saldoFinal, 500);

      // A 4ª parcela é a última: de janeiro em diante não pesa mais.
      expect(doze[3].temDivida, isTrue);
      expect(doze[4].temDivida, isFalse);

      // E o saldo volta a subir 2000 por mês.
      expect(doze[5].saldoFinal, doze[4].saldoFinal + 2000);
    });

    test('marca o mês da quitação', () {
      final doze = service.doze(
        perfil: const PerfilFinanceiro(rendaMensal: 3000, contasFixasEstimadas: 500),
        dividas: [
          divida(nome: 'A', parcela: 100, restantes: 2),
          divida(nome: 'B', parcela: 100, restantes: 5),
        ],
        saldoInicial: 0,
        referencia: DateTime(2026, 9, 1),
      );

      // A mais longa tem 5 parcelas: a última cai no índice 4.
      expect(doze[4].ehQuitacao, isTrue);
      expect(doze.where((m) => m.ehQuitacao), hasLength(1));
    });

    test('sem dívida nenhum mês é de quitação', () {
      final doze = service.doze(
        perfil: const PerfilFinanceiro(rendaMensal: 3000),
        dividas: [],
        saldoInicial: 0,
        referencia: DateTime(2026, 9, 1),
      );

      expect(doze.where((m) => m.ehQuitacao), isEmpty);
    });

    test('mês negativo fica em aperto', () {
      final doze = service.doze(
        perfil: const PerfilFinanceiro(rendaMensal: 2000, contasFixasEstimadas: 900),
        dividas: [divida(parcela: 1534, restantes: 6)],
        saldoInicial: 0,
        referencia: DateTime(2026, 9, 1),
      );

      expect(doze[0].estado, EstadoFinanceiro.aperto);
      expect(doze[0].saldoFinal, -434);
    });
  });
}
