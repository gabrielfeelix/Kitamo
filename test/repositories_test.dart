import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/data/banco.dart' show Banco;
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/repositories/dinheiro.dart';
import 'package:kitamo/repositories/divida_repository.dart';
import 'package:kitamo/repositories/perfil_repository.dart';

/// Fase 1: o app lembra do que a pessoa respondeu.
///
/// O risco maior aqui é silencioso: centavo perdido em arredondamento e
/// parcela baixada duas vezes. Os dois só aparecem quando o usuário
/// confere com a fatura — e aí ele para de confiar no app.
void main() {
  late Banco banco;
  late DividaRepository dividas;
  late PerfilRepository perfis;

  setUp(() {
    banco = Banco.memoria();
    dividas = DividaRepositoryDrift(banco);
    perfis = PerfilRepositoryDrift(banco);
  });

  tearDown(() => banco.close());

  Divida nubank({
    String id = '1',
    int restantes = 4,
    int total = 10,
    double parcela = 1534.06,
    double saldo = 6136.24,
  }) =>
      Divida(
        id: id,
        nome: 'Nubank',
        saldoAtual: saldo,
        valorParcela: parcela,
        diaVencimento: 4,
        parcelasRestantes: restantes,
        parcelasTotal: total,
      );

  group('dinheiro', () {
    test('vai e volta sem perder centavo', () {
      for (final v in [0.0, 0.01, 1534.06, 6136.24, 99999.99, 0.1 + 0.2]) {
        expect(Dinheiro.paraReais(Dinheiro.paraCentavos(v)),
            closeTo(v, 0.005), reason: 'valor $v');
      }
    });

    test('guarda em centavos, não em double', () {
      // 0.1 + 0.2 em double dá 0.30000000000000004. Em centavos, 30.
      expect(Dinheiro.paraCentavos(0.1 + 0.2), 30);
      expect(Dinheiro.paraCentavos(1534.06), 153406);
    });
  });

  group('dívidas', () {
    test('salva e lê de volta com os mesmos valores', () async {
      await dividas.salvar(nubank());

      final lidas = await dividas.emAberto();
      expect(lidas, hasLength(1));
      expect(lidas.first.nome, 'Nubank');
      expect(lidas.first.valorParcela, 1534.06);
      expect(lidas.first.saldoAtual, 6136.24);
      expect(lidas.first.parcelasPagas, 6);
    });

    test('salvar de novo atualiza em vez de duplicar', () async {
      await dividas.salvar(nubank());
      await dividas.salvar(nubank(restantes: 3));

      final lidas = await dividas.todas();
      expect(lidas, hasLength(1));
      expect(lidas.first.parcelasRestantes, 3);
    });

    test('quitar parcela baixa uma e desconta o saldo', () async {
      await dividas.salvar(nubank());

      final r = await dividas.quitarParcela('1');

      expect(r!.parcelasRestantes, 3);
      expect(r.saldoAtual, closeTo(4602.18, 0.001));
      expect(r.estaQuitada, isFalse);
      expect(r.parcelasPagas, 7);
    });

    test('a última parcela encerra a dívida', () async {
      await dividas.salvar(nubank(restantes: 1, saldo: 1534.06));

      final r = await dividas.quitarParcela('1');

      expect(r!.parcelasRestantes, 0);
      expect(r.estaQuitada, isTrue);
      expect(r.quitadaEm, isNotNull);
      expect(await dividas.emAberto(), isEmpty);
    });

    test('quitar duas vezes seguidas não baixa duas parcelas', () async {
      // Toque duplo no botão não pode custar uma parcela ao usuário.
      await dividas.salvar(nubank(restantes: 1, saldo: 1534.06));

      await dividas.quitarParcela('1');
      final segunda = await dividas.quitarParcela('1');

      expect(segunda!.parcelasRestantes, 0);
      expect((await dividas.todas()).first.parcelasRestantes, 0);
    });

    test('saldo nunca fica negativo', () async {
      // A última parcela raramente bate com o saldo nos centavos.
      await dividas.salvar(nubank(restantes: 1, saldo: 1500));

      final r = await dividas.quitarParcela('1');

      expect(r!.saldoAtual, 0);
    });

    test('quitar dívida inexistente devolve null', () async {
      expect(await dividas.quitarParcela('nao-existe'), isNull);
    });

    test('remover apaga', () async {
      await dividas.salvar(nubank());
      await dividas.remover('1');

      expect(await dividas.todas(), isEmpty);
    });

    test('observar emite a mudança', () async {
      // A tela precisa reagir sem recarregar na mão: espera o primeiro
      // evento que já tenha a dívida.
      final futuro = dividas
          .observarEmAberto()
          .firstWhere((lista) => lista.isNotEmpty)
          .timeout(const Duration(seconds: 5));

      await dividas.salvar(nubank());

      expect((await futuro).first.nome, 'Nubank');
    });
  });

  group('perfil', () {
    test('não existe antes do onboarding', () async {
      expect(await perfis.carregar(), isNull);
      expect(await perfis.precisaOnboarding(), isTrue);
    });

    test('salva e lê as respostas', () async {
      await perfis.salvar(const PerfilFinanceiro(
        rendaMensal: 3650,
        diaRenda: 6,
        gastoDiarioEstimado: 40,
        contasFixasEstimadas: 914.50,
      ));

      final p = await perfis.carregar();
      expect(p!.rendaMensal, 3650);
      expect(p.diaRenda, 6);
      expect(p.contasFixasEstimadas, 914.50);
      expect(p.origem, OrigemPerfil.feeling);
      expect(await perfis.precisaOnboarding(), isFalse);
    });

    test('é linha única: salvar de novo atualiza', () async {
      await perfis.salvar(const PerfilFinanceiro(rendaMensal: 3000));
      await perfis.salvar(const PerfilFinanceiro(rendaMensal: 4000));

      expect((await perfis.carregar())!.rendaMensal, 4000);
    });

    test('pular tudo no onboarding grava perfil vazio sem quebrar', () async {
      await perfis.salvar(const PerfilFinanceiro());

      final p = await perfis.carregar();
      expect(p, isNotNull);
      expect(p!.rendaMensal, isNull);
      expect(p.diaRenda, isNull);
    });

    test('guarda a origem do extrato', () async {
      await perfis.salvar(const PerfilFinanceiro(
        rendaMensal: 3650,
        origem: OrigemPerfil.ofx,
      ));

      expect((await perfis.carregar())!.veioDeExtrato, isTrue);
    });
  });
}
