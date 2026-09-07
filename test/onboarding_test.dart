import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/data/banco.dart' show Banco;
import 'package:kitamo/features/onboarding/onboarding_controller.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/repositories/divida_repository.dart';
import 'package:kitamo/repositories/perfil_repository.dart';

/// Fase 2: o onboarding.
///
/// A regra do produto que estes testes guardam: **pular não pode travar nem
/// inventar dado.** Quem pula tudo chega ao fim com um número incompleto,
/// não com erro — e campo pulado vira null, nunca zero. Zero é uma resposta
/// ("não tenho conta fixa"); null é "não respondeu".
void main() {
  late Banco banco;
  late OnboardingController c;
  late PerfilRepository perfis;
  late DividaRepository dividas;

  setUp(() {
    banco = Banco.memoria();
    perfis = PerfilRepositoryDrift(banco);
    dividas = DividaRepositoryDrift(banco);
    c = OnboardingController(perfis: perfis, dividas: dividas);
  });

  tearDown(() => banco.close());

  group('navegação', () {
    test('começa no primeiro passo e anda até o último', () {
      expect(c.indice, 0);
      expect(c.passo, PassoOnboarding.divida);

      for (var i = 0; i < PassoOnboarding.values.length - 1; i++) {
        c.avancar();
      }

      expect(c.ehUltimo, isTrue);
      expect(c.passo, PassoOnboarding.extrato);
    });

    test('não passa do último nem volta antes do primeiro', () {
      c.voltar();
      expect(c.indice, 0);

      for (var i = 0; i < 20; i++) {
        c.avancar();
      }
      expect(c.indice, PassoOnboarding.values.length - 1);
    });

    test('progresso vai de uma fração até 1', () {
      expect(c.progresso, closeTo(1 / 6, 0.001));

      while (!c.ehUltimo) {
        c.avancar();
      }
      expect(c.progresso, 1);
    });

    test('cada passo tem sua cor', () {
      final cores = PassoOnboarding.values.map((p) => p.cor).toSet();
      expect(cores.length, greaterThan(3),
          reason: 'as telas precisam se distinguir pela cor');
    });
  });

  group('dívidas', () {
    test('adiciona e remove rascunho, mas nunca fica sem nenhum', () {
      expect(c.rascunhos, hasLength(1));

      c.adicionarDivida();
      expect(c.rascunhos, hasLength(2));

      c.removerDivida(0);
      expect(c.rascunhos, hasLength(1));

      // O último não sai: a tela ficaria sem campo nenhum.
      c.removerDivida(0);
      expect(c.rascunhos, hasLength(1));
    });

    test('salva só as dívidas com nome', () async {
      c.rascunhos[0]
        ..nome = 'Nubank'
        ..parcela = 1534.06
        ..restantes = 4
        ..diaVencimento = 4;

      c.adicionarDivida(); // fica em branco de propósito

      await c.concluir();

      final salvas = await dividas.todas();
      expect(salvas, hasLength(1));
      expect(salvas.first.nome, 'Nubank');
      expect(salvas.first.valorParcela, 1534.06);
      expect(salvas.first.diaVencimento, 4);
    });

    test('estima o saldo pela parcela vezes o que falta', () async {
      // A pessoa sabe responder a parcela, não o saldo devedor exato.
      c.rascunhos[0]
        ..nome = 'Nubank'
        ..parcela = 1534.06
        ..restantes = 4;

      await c.concluir();

      expect((await dividas.todas()).first.saldoAtual, closeTo(6136.24, 0.01));
    });

    test('"não sei ainda" não grava dívida nenhuma', () async {
      c.rascunhos[0]
        ..nome = 'Nubank'
        ..parcela = 1000
        ..restantes = 3;

      c.alternarNaoSei();
      await c.concluir();

      expect(await dividas.todas(), isEmpty);
      // Mas o perfil existe: o onboarding foi concluído.
      expect(await perfis.precisaOnboarding(), isFalse);
    });

    test('dívida sem dia de vencimento cai no dia 1', () async {
      c.rascunhos[0]
        ..nome = 'Crediário'
        ..restantes = 3;

      await c.concluir();

      final d = (await dividas.todas()).first;
      expect(d.diaVencimento, 1);
      expect(d.valorParcela, 0);
    });
  });

  group('conclusão', () {
    test('salva as respostas', () async {
      c
        ..rendaMensal = 3650
        ..diaRenda = 6
        ..gastoDiario = 40
        ..contasFixas = 914;

      await c.concluir();

      final p = await perfis.carregar();
      expect(p!.rendaMensal, 3650);
      expect(p.diaRenda, 6);
      expect(p.gastoDiarioEstimado, 40);
      expect(p.contasFixasEstimadas, 914);
      expect(p.origem, OrigemPerfil.feeling);
    });

    test('pular tudo grava perfil vazio sem quebrar', () async {
      await c.concluir();

      final p = await perfis.carregar();
      expect(p, isNotNull);
      expect(p!.rendaMensal, isNull);
      expect(p.diaRenda, isNull);
      expect(await dividas.todas(), isEmpty);

      // O app não pede o onboarding de novo.
      expect(await perfis.precisaOnboarding(), isFalse);
    });

    test('campo pulado vira null, não zero', () async {
      // Zero é resposta ("não tenho conta fixa"); null é "não respondeu".
      // Confundir os dois faria o app calcular com dado inventado.
      c.rendaMensal = 3000;
      await c.concluir();

      final p = await perfis.carregar();
      expect(p!.rendaMensal, 3000);
      expect(p.contasFixasEstimadas, isNull);
      expect(p.gastoDiarioEstimado, isNull);
    });

    test('concluir duas vezes não duplica o perfil', () async {
      c.rendaMensal = 3000;
      await c.concluir();
      await c.concluir();

      expect((await perfis.carregar())!.rendaMensal, 3000);
    });
  });
}
