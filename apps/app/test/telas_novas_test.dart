import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/features/aperto/caminhos.dart';
import 'package:kitamo/features/avisos/avisos.dart';
import 'package:kitamo/features/lancamentos/pra_onde_vai.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/lancamento_registro.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/services/dia_de_hoje.dart';

void main() {
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
        saldoAtual: parcela * restantes,
        valorParcela: parcela,
        diaVencimento: vencimento,
        parcelasRestantes: restantes,
        parcelasTotal: total,
      );

  LancamentoRegistro gasto(double v, {DateTime? data, String desc = 'mercado'}) =>
      LancamentoRegistro(
        id: '$v$desc${data?.day}',
        descricao: desc,
        valor: v,
        tipo: TipoLancamento.gasto,
        data: data ?? DateTime(2026, 9, 6),
      );

  group('dia de hoje', () {
    test('conta só o que foi gasto hoje', () {
      final h = DiaDeHoje.calcular(
        diario: 50,
        hoje: DateTime(2026, 9, 6),
        lancamentos: [
          gasto(20, data: DateTime(2026, 9, 6)),
          gasto(999, data: DateTime(2026, 9, 5)), // ontem não entra
        ],
      );

      expect(h.jaGastou, 20);
      expect(h.sobra, 30);
      expect(h.passou, isFalse);
    });

    test('entrada não conta como gasto do dia', () {
      final h = DiaDeHoje.calcular(
        diario: 50,
        hoje: DateTime(2026, 9, 6),
        lancamentos: [
          LancamentoRegistro(
            id: 'e',
            descricao: 'salário',
            valor: 3650,
            tipo: TipoLancamento.entrada,
            data: DateTime(2026, 9, 6),
          ),
        ],
      );

      expect(h.jaGastou, 0);
    });

    test('diz quanto passou quando estoura', () {
      final h = DiaDeHoje.calcular(
        diario: 23,
        hoje: DateTime(2026, 9, 6),
        lancamentos: [gasto(37.56, data: DateTime(2026, 9, 6))],
      );

      expect(h.passou, isTrue);
      expect(h.quantoPassou, closeTo(14.56, 0.001));
      // A proporção passa de 1 para a barra saber que estourou.
      expect(h.proporcao, greaterThan(1));
    });

    test('diário zero com gasto não divide por zero', () {
      final h = DiaDeHoje.calcular(
        diario: 0,
        hoje: DateTime(2026, 9, 6),
        lancamentos: [gasto(10, data: DateTime(2026, 9, 6))],
      );

      expect(h.proporcao, 1);
      expect(h.passou, isTrue);
    });
  });

  group('pra onde vai', () {
    test('agrupa por nome e ordena do maior', () {
      final fatias = agruparGastos([
        gasto(30, desc: 'mercado'),
        gasto(20, desc: 'mercado'),
        gasto(100, desc: 'ifood'),
      ]);

      expect(fatias.first.nome, 'ifood');
      expect(fatias.first.total, 100);
      expect(fatias[1].nome, 'mercado');
      expect(fatias[1].total, 50);
    });

    test('proporção soma 1', () {
      final fatias = agruparGastos([
        gasto(25, desc: 'a'),
        gasto(75, desc: 'b'),
      ]);

      expect(fatias.fold<double>(0, (s, f) => s + f.proporcao), closeTo(1, 0.001));
    });

    test('ignora entradas e lista vazia', () {
      expect(agruparGastos([]), isEmpty);
      expect(
        agruparGastos([
          LancamentoRegistro(
            id: 'e',
            descricao: 'salário',
            valor: 3650,
            tipo: TipoLancamento.entrada,
            data: DateTime(2026, 9, 6),
          ),
        ]),
        isEmpty,
      );
    });
  });

  group('caminhos do aperto', () {
    const apertado = PerfilFinanceiro(
      rendaMensal: 2000,
      diaRenda: 6,
      contasFixasEstimadas: 900,
    );

    test('mostra onde o dinheiro está comprometido', () {
      final c = const Caminhos().montar(
        perfil: apertado,
        dividas: [divida()],
      );

      expect(c.first.titulo, 'Onde seu dinheiro já está',
          reason: 'o primeiro caminho responde "por que não sobra"');
    });

    test('aponta a parcela que vence antes do salário', () {
      // O caso que custou R$ 1.674 em 12 meses.
      final c = const Caminhos().montar(
        perfil: apertado,
        dividas: [divida(vencimento: 4)],
      );

      final descasamento =
          c.where((x) => x.titulo.contains('antes do seu salário'));

      expect(descasamento, hasLength(1));
      expect(descasamento.first.acao, contains('mudar o vencimento'));
    });

    test('não inventa descasamento quando não existe', () {
      final c = const Caminhos().montar(
        perfil: apertado,
        dividas: [divida(vencimento: 20)],
      );

      expect(c.where((x) => x.titulo.contains('antes do seu salário')), isEmpty);
    });

    test('sempre oferece pelo menos renegociar', () {
      final c = const Caminhos().montar(perfil: null, dividas: []);

      expect(c, isNotEmpty);
      expect(c.last.titulo, contains('renegociar'));
    });
  });

  group('avisos', () {
    const perfil = PerfilFinanceiro(
      rendaMensal: 5000,
      diaRenda: 6,
      contasFixasEstimadas: 900,
    );

    test('avisa quando vence amanhã', () {
      final a = const Avisos().montar(
        perfil: perfil,
        dividas: [divida(vencimento: 10)],
        hoje: DateTime(2026, 9, 9),
      );

      expect(a.where((x) => x.titulo.contains('amanhã')), hasLength(1));
    });

    test('avisa quando vence hoje', () {
      final a = const Avisos().montar(
        perfil: perfil,
        dividas: [divida(vencimento: 10)],
        hoje: DateTime(2026, 9, 10),
      );

      expect(a.where((x) => x.titulo.contains('vence hoje')), hasLength(1));
    });

    test('vencimento dia 31 vira dia 28 em fevereiro', () {
      // Sem o ajuste, o aviso nunca dispararia em fevereiro.
      final a = const Avisos().montar(
        perfil: perfil,
        dividas: [divida(vencimento: 31)],
        hoje: DateTime(2026, 2, 27),
      );

      expect(a.where((x) => x.titulo.contains('amanhã')), hasLength(1));
    });

    test('conquista só aparece perto do fim', () {
      final longe = const Avisos().montar(
        perfil: perfil,
        dividas: [divida(restantes: 9)],
        hoje: DateTime(2026, 9, 15),
      );
      expect(longe.where((x) => x.tipo == TipoAviso.conquista), isEmpty);

      final perto = const Avisos().montar(
        perfil: perfil,
        dividas: [divida(restantes: 2)],
        hoje: DateTime(2026, 9, 15),
      );
      expect(perto.where((x) => x.tipo == TipoAviso.conquista), hasLength(1));
    });

    test('avisa que a conta não fecha', () {
      final a = const Avisos().montar(
        perfil: const PerfilFinanceiro(
          rendaMensal: 2000,
          diaRenda: 6,
          contasFixasEstimadas: 900,
        ),
        dividas: [divida()],
        hoje: DateTime(2026, 9, 15),
      );

      expect(a.where((x) => x.tipo == TipoAviso.aperto), hasLength(1));
    });

    test('sem dívida e sem perfil não inventa aviso', () {
      final a = const Avisos().montar(
        perfil: null,
        dividas: [],
        hoje: DateTime(2026, 9, 15),
      );

      expect(a, isEmpty);
    });
  });
}
