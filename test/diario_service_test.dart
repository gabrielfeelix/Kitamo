import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/services/diario_service.dart';

/// As mesmas regras já validadas no backend, agora no app.
///
/// O risco que estes testes guardam: um diário errado para mais faz a
/// pessoa gastar dinheiro que não tem — e é quem está endividado que paga
/// caro por isso.
void main() {
  const service = DiarioService();

  Divida divida({
    double parcela = 0,
    int restantes = 0,
    int total = 0,
    int vencimento = 1,
    DateTime? quitada,
  }) =>
      Divida(
        id: 'x',
        nome: 'Nubank',
        saldoAtual: 0,
        valorParcela: parcela,
        diaVencimento: vencimento,
        parcelasRestantes: restantes,
        parcelasTotal: total,
        quitadaEm: quitada,
      );

  group('diário', () {
    test('é a sobra dividida pelos dias do mês', () {
      final r = service.calcular(
        perfil: const PerfilFinanceiro(rendaMensal: 3000, contasFixasEstimadas: 900),
        dividas: [divida(parcela: 1500, restantes: 4)],
        referencia: DateTime(2026, 9, 6),
      );

      expect(r.sobraMensal, 600);
      expect(r.diasNoMes, 30);
      expect(r.diario, 20);
      expect(r.fecha, isTrue);
    });

    test('mesma sobra muda o diário conforme o mês', () {
      const perfil =
          PerfilFinanceiro(rendaMensal: 2000, contasFixasEstimadas: 1070);

      final fev = service.calcular(
          perfil: perfil, dividas: [], referencia: DateTime(2026, 2, 10));
      final abr = service.calcular(
          perfil: perfil, dividas: [], referencia: DateTime(2026, 4, 10));
      final jan = service.calcular(
          perfil: perfil, dividas: [], referencia: DateTime(2026, 1, 10));

      expect(fev.diasNoMes, 28);
      expect(fev.diario, 33.21);
      expect(abr.diasNoMes, 30);
      expect(abr.diario, 31);
      expect(jan.diasNoMes, 31);
      expect(jan.diario, 30);
    });

    test('fevereiro bissexto tem 29 dias', () {
      final r = service.calcular(
        perfil: const PerfilFinanceiro(rendaMensal: 1000, contasFixasEstimadas: 710),
        dividas: [],
        referencia: DateTime(2028, 2, 10),
      );

      expect(r.diasNoMes, 29);
      expect(r.diario, 10);
    });

    test('sobra negativa não vira diário zero disfarçado', () {
      final r = service.calcular(
        perfil: const PerfilFinanceiro(rendaMensal: 2000, contasFixasEstimadas: 900),
        dividas: [divida(parcela: 1534, restantes: 4)],
        referencia: DateTime(2026, 9, 6),
      );

      expect(r.fecha, isFalse);
      expect(r.sobraMensal, -434);
      expect(r.faltaPorMes, 434);
      expect(r.diario, 0);
    });

    test('sobra exatamente zero não fecha', () {
      final r = service.calcular(
        perfil: const PerfilFinanceiro(rendaMensal: 2434, contasFixasEstimadas: 900),
        dividas: [divida(parcela: 1534, restantes: 4)],
        referencia: DateTime(2026, 9, 6),
      );

      expect(r.sobraMensal, 0);
      expect(r.fecha, isFalse);
    });

    test('dívida quitada não pesa', () {
      final r = service.calcular(
        perfil: const PerfilFinanceiro(rendaMensal: 3000, contasFixasEstimadas: 1000),
        dividas: [
          divida(parcela: 500, restantes: 3),
          divida(parcela: 900, quitada: DateTime(2026, 1, 1)),
        ],
        referencia: DateTime(2026, 9, 6),
      );

      expect(r.parcelasDoMes, 500);
      expect(r.sobraMensal, 1500);
    });

    test('sem perfil não quebra', () {
      final r = service.calcular(
          perfil: null, dividas: [], referencia: DateTime(2026, 9, 6));

      expect(r.sobraMensal, 0);
      expect(r.fecha, isFalse);
      expect(r.temDividas, isFalse);
    });
  });

  group('quitação', () {
    test('é a dívida mais longa', () {
      final r = service.calcular(
        perfil: const PerfilFinanceiro(rendaMensal: 5000, contasFixasEstimadas: 500),
        dividas: [
          divida(parcela: 100, restantes: 2, vencimento: 10),
          divida(parcela: 100, restantes: 5, vencimento: 10),
          divida(parcela: 100, restantes: 3, vencimento: 10),
        ],
        referencia: DateTime(2026, 9, 6),
      );

      expect(r.quitacaoEm, DateTime(2027, 1, 10));
      expect(r.quitacaoLabel, 'janeiro');
    });

    test('pula o mês quando o vencimento já passou', () {
      // Vencimento dia 4, hoje dia 6: a 1ª restante é outubro. É o caso
      // do Gabriel.
      final d = divida(parcela: 100, restantes: 4, vencimento: 4);

      expect(d.previsaoQuitacao(DateTime(2026, 9, 6)), DateTime(2027, 1, 4));
    });

    test('vencimento dia 31 encolhe em mês curto', () {
      final d = divida(vencimento: 31, restantes: 1);

      expect(d.vencimentoNoMes(2026, 2), DateTime(2026, 2, 28));
      expect(d.vencimentoNoMes(2028, 2), DateTime(2028, 2, 29));
      expect(d.vencimentoNoMes(2026, 4), DateTime(2026, 4, 30));
      expect(d.vencimentoNoMes(2026, 1), DateTime(2026, 1, 31));
    });

    test('atravessa fevereiro sem estourar a data', () {
      final d = divida(vencimento: 31, restantes: 3);

      expect(d.previsaoQuitacao(DateTime(2026, 12, 1)), DateTime(2027, 2, 28));
    });

    test('sem parcelas restantes não tem previsão', () {
      expect(divida(restantes: 0).previsaoQuitacao(DateTime(2026, 9, 6)), isNull);
    });
  });

  group('contagem', () {
    test('mostra o 7 de 10', () {
      expect(divida(total: 10, restantes: 3).parcelasPagas, 7);
    });

    test('nunca é negativa com dado inconsistente', () {
      expect(divida(total: 3, restantes: 5).parcelasPagas, 0);
    });
  });
}
