import 'package:flutter_test/flutter_test.dart';
// O Drift gera classes de linha com os mesmos nomes dos modelos.
import 'package:kitamo/data/banco.dart' show Banco;
import 'package:kitamo/models/cartao.dart';
import 'package:kitamo/models/conta_fixa.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/entrada.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/repositories/cartao_repository.dart';
import 'package:kitamo/repositories/divida_repository.dart';
import 'package:kitamo/services/diario_service.dart';
import 'package:kitamo/services/horizonte_service.dart';

/// A vida de quem vai usar o app: dívida em 3 cartões, dinheiro entrando
/// em dias diferentes, contas fixas que ela cadastrou.
///
/// O risco que estes testes guardam é o mesmo do diário: prometer folga em
/// dia que ainda não tem dinheiro na conta faz a pessoa gastar o que não
/// tem — e é quem está endividado que paga caro por isso.
void main() {
  group('cartão por fora, compras por dentro', () {
    late Banco banco;
    late CartaoRepositoryDrift cartoes;
    late DividaRepositoryDrift dividas;

    setUp(() {
      banco = Banco.memoria();
      cartoes = CartaoRepositoryDrift(banco);
      dividas = DividaRepositoryDrift(banco);
    });

    tearDown(() => banco.close());

    Future<void> montarNubank() async {
      await cartoes.salvar(const Cartao(
        id: 'nubank',
        nome: 'cartão Nubank',
        diaVencimento: 4,
      ));

      // A fatura de 07/09: geladeira, notebook e mercado.
      await dividas.salvar(const Divida(
        id: 'geladeira',
        nome: 'geladeira',
        saldoAtual: 2800,
        valorParcela: 400,
        diaVencimento: 4,
        parcelasRestantes: 7,
        parcelasTotal: 10,
        cartaoId: 'nubank',
      ));
      await dividas.salvar(const Divida(
        id: 'notebook',
        nome: 'notebook',
        saldoAtual: 2000,
        valorParcela: 200,
        diaVencimento: 4,
        parcelasRestantes: 10,
        parcelasTotal: 12,
        cartaoId: 'nubank',
      ));
      await dividas.salvar(const Divida(
        id: 'mercado',
        nome: 'mercado',
        saldoAtual: 100,
        valorParcela: 100,
        diaVencimento: 4,
        parcelasRestantes: 1,
        parcelasTotal: 3,
        cartaoId: 'nubank',
      ));
    }

    test('o cartão junta as compras que estão dentro dele', () async {
      await montarNubank();

      final lista = await cartoes.todos();
      expect(lista, hasLength(1));
      expect(lista.first.compras, hasLength(3));
      // O número que ela confere contra a fatura que chegou.
      expect(lista.first.faturaDoMes, 700);
      expect(lista.first.saldoTotal, 4900);
    });

    test('paguei a fatura baixa todas as parcelas do mês num toque',
        () async {
      await montarNubank();

      await cartoes.quitarFatura('nubank', em: DateTime(2026, 9, 4));

      final todas = await dividas.todas();
      final porId = {for (final d in todas) d.id: d};

      expect(porId['geladeira']!.parcelasRestantes, 6);
      expect(porId['notebook']!.parcelasRestantes, 9);
      expect(porId['mercado']!.parcelasRestantes, 0);

      // A que acabou fica quitada; as outras seguem abertas.
      expect(porId['mercado']!.estaQuitada, isTrue);
      expect(porId['geladeira']!.estaQuitada, isFalse);

      // A fatura do mês que vem já não tem o mercado dentro.
      final cartao = (await cartoes.todos()).first;
      expect(cartao.faturaDoMes, 600);
    });

    test('pagar a fatura duas vezes não baixa duas parcelas', () async {
      await montarNubank();

      await cartoes.quitarFatura('nubank', em: DateTime(2026, 9, 4));
      await cartoes.quitarFatura('nubank', em: DateTime(2026, 9, 4));

      final todas = await dividas.todas();
      final porId = {for (final d in todas) d.id: d};

      // O toque duplo no botão é o caso real: dedo trêmulo, tela lenta.
      expect(porId['geladeira']!.parcelasRestantes, 5);
      expect(porId['mercado']!.parcelasRestantes, 0);
      expect(porId['mercado']!.saldoAtual, 0,
          reason: 'saldo não pode ficar negativo na última parcela');
    });

    test('cartão que não existe devolve nulo', () async {
      expect(await cartoes.quitarFatura('nao-existe'), equals(null));
    });

    test('apagar o cartão solta as compras, não as apaga', () async {
      await montarNubank();

      await cartoes.remover('nubank');

      final todas = await dividas.todas();
      expect(todas, hasLength(3),
          reason: 'a dívida continua existindo na vida real');
      expect(todas.every((d) => d.cartaoId == null), isTrue);
      expect(await cartoes.todos(), isEmpty);
    });
  });

  group('várias entradas, cada uma com seu dia', () {
    const diario = DiarioService();
    const horizonte = HorizonteService();

    // A pessoa do handoff: R$ 600 dia 5 e R$ 400 dia 20.
    const List<Entrada> entradas = [
      Entrada(id: '1', nome: 'salário', valor: 600, dia: 5),
      Entrada(id: '2', nome: 'bico', valor: 400, dia: 20),
    ];

    test('o diário soma o que entra, não um valor só', () {
      final r = diario.calcular(
        perfil: const PerfilFinanceiro(),
        dividas: const [],
        entradas: entradas,
        contasFixas: const [
          ContaFixa(id: 'a', nome: 'aluguel', valor: 400, dia: 10),
        ],
        referencia: DateTime(2026, 9, 6),
      );

      expect(r.sobraMensal, 600);
      expect(r.contasFixas, 400);
      expect(r.diario, 20);
    });

    test('o dinheiro entra no dia dele, não todo no dia 1', () {
      final mes = horizonte.mes(
        perfil: const PerfilFinanceiro(gastoDiarioEstimado: 0),
        dividas: const [],
        saldoInicial: 0,
        entradas: entradas,
        referencia: DateTime(2026, 9, 1),
      );

      // Dia 4: nada entrou ainda. É a promessa de folga que o app fazia
      // errado quando somava tudo num dia só.
      expect(mes.dias[3].saldo, 0);
      expect(mes.dias[4].saldo, 600);
      expect(mes.dias[18].saldo, 600);
      expect(mes.dias[19].saldo, 1000);
      expect(mes.saldoFinal, 1000);
    });

    test('cada entrada aparece com o nome que ela deu', () {
      final mes = horizonte.mes(
        perfil: const PerfilFinanceiro(),
        dividas: const [],
        saldoInicial: 0,
        entradas: entradas,
        referencia: DateTime(2026, 9, 1),
      );

      expect(mes.dias[4].lancamentos.first.nome, 'salário');
      expect(mes.dias[19].lancamentos.first.nome, 'bico');
    });

    test('a conta fixa sai no dia dela', () {
      final mes = horizonte.mes(
        perfil: const PerfilFinanceiro(gastoDiarioEstimado: 0),
        dividas: const [],
        saldoInicial: 1000,
        contasFixas: const [
          ContaFixa(id: 'a', nome: 'aluguel', valor: 400, dia: 10),
        ],
        referencia: DateTime(2026, 9, 1),
      );

      expect(mes.dias[8].saldo, 1000);
      expect(mes.dias[9].saldo, 600);
      expect(mes.dias[9].lancamentos.first.nome, 'aluguel');
    });

    test('conta desligada continua cadastrada mas não pesa', () {
      final r = diario.calcular(
        perfil: const PerfilFinanceiro(),
        dividas: const [],
        entradas: entradas,
        contasFixas: const [
          ContaFixa(id: 'a', nome: 'aluguel', valor: 400, dia: 10),
          ContaFixa(id: 'b', nome: 'academia', valor: 100, dia: 10, ativa: false),
        ],
        referencia: DateTime(2026, 9, 6),
      );

      expect(r.contasFixas, 400);
    });

    test('lista vazia continua lendo o perfil antigo', () {
      // Quem ainda não passou pela migration não pode ver o app zerado.
      final r = diario.calcular(
        perfil: const PerfilFinanceiro(
          rendaMensal: 3000,
          contasFixasEstimadas: 900,
        ),
        dividas: const [],
        referencia: DateTime(2026, 9, 6),
      );

      expect(r.sobraMensal, 2100);
    });

    test('entrada dia 31 cai no último dia do mês curto', () {
      final mes = horizonte.mes(
        perfil: const PerfilFinanceiro(gastoDiarioEstimado: 0),
        dividas: const [],
        saldoInicial: 0,
        entradas: const [
          Entrada(id: '1', nome: 'salário', valor: 500, dia: 31),
        ],
        referencia: DateTime(2026, 2, 1),
      );

      // Sem isto o salário sumiria de fevereiro.
      expect(mes.dias.last.data.day, 28);
      expect(mes.dias.last.saldo, 500);
    });

    test('doze meses somam as listas', () {
      final meses = horizonte.doze(
        perfil: const PerfilFinanceiro(gastoDiarioEstimado: 0),
        dividas: const [],
        saldoInicial: 0,
        entradas: entradas,
        contasFixas: const [
          ContaFixa(id: 'a', nome: 'aluguel', valor: 400, dia: 10),
        ],
        referencia: DateTime(2026, 9, 1),
      );

      expect(meses.first.saldoFinal, 600);
      expect(meses[1].saldoFinal, 1200);
    });
  });
}
