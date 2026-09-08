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

  group('o dia em que o dinheiro entra', () {
    // O toque no dia não pintava nada: `diaRenda` era campo solto, então
    // gravava o valor sem avisar a tela, e ela nunca se redesenhava. Na
    // mão do Gabriel isso é "o botão não funciona", e nenhum teste de
    // lógica pegava, porque o valor até chegava no controller.
    test('escolher o dia avisa a tela', () {
      var avisos = 0;
      c.addListener(() => avisos++);

      c.diaRenda = 6;

      expect(c.diaRenda, 6);
      expect(avisos, 1, reason: 'sem aviso a tela não redesenha, e o dia '
          'escolhido não fica marcado');
    });

    test('escolher o mesmo dia de novo não redesenha à toa', () {
      c.diaRenda = 6;

      var avisos = 0;
      c.addListener(() => avisos++);
      c.diaRenda = 6;

      expect(avisos, 0);
    });
  });

  group('navegação', () {
    test('começa no primeiro passo e anda até o último', () {
      expect(c.indice, 0);
      expect(c.passo, PassoOnboarding.nome);

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
      expect(c.progresso, closeTo(1 / PassoOnboarding.values.length, 0.001));

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

  group('as faixas de dívida', () {
    test('escolher uma faixa preenche o total pelo meio dela', () {
      c.escolherFaixa(FaixaDeDivida.entre10e15);

      expect(c.faixa, FaixaDeDivida.entre10e15);
      expect(c.totalDevido, 12500);
    });

    test('"não sei" é resposta, e deixa o total em aberto', () {
      c.escolherFaixa(FaixaDeDivida.naoSei);

      expect(c.faixa, FaixaDeDivida.naoSei);
      expect(c.totalDevido, isNull);
    });

    test('digitar um número desmarca a faixa', () {
      c.escolherFaixa(FaixaDeDivida.ate5mil);
      c.digitarTotal(8300);

      expect(c.faixa, isNull);
      expect(c.totalDevido, 8300);
    });

    test('sem saber em quantas vezes, não inventa parcela', () async {
      // O bug que o Gabriel pegou: o app espalhava o total em 12 meses e
      // mostrava "0 de 12" numa dívida de 4. Palpite com cara de fato.
      c.digitarTotal(12000);
      await c.concluir();

      final salvas = await dividas.todas();
      expect(salvas, hasLength(1));
      expect(salvas.first.saldoAtual, 12000);
      expect(salvas.first.parcelasTotal, 0,
          reason: 'campo vazio é melhor que número falso');
      expect(salvas.first.valorParcela, 0);
    });

    test('sem parcela, a dívida não pesa no diário como se tivesse', () async {
      // parcelasRestantes zero significa "não sei", não "acabou". O que
      // não pode é o app inventar uma parcela mensal que ninguém informou.
      c.digitarTotal(12000);
      await c.concluir();

      final salvas = await dividas.todas();
      expect(salvas.first.valorParcela, 0);
      expect(salvas.first.estaQuitada, isFalse,
          reason: 'a dívida existe, só não se sabe em quantas vezes');
    });

    test('quando ela diz em quantas vezes, a parcela sai daí', () async {
      c.digitarTotal(12000);
      c.parcelasDoTotal = 4;
      await c.concluir();

      final salvas = await dividas.todas();
      expect(salvas.first.parcelasTotal, 4);
      expect(salvas.first.parcelasRestantes, 4);
      expect(salvas.first.valorParcela, 3000);
    });

    test('o nome que ela deu vai pro perfil', () async {
      // Sem isso o Início dava "bom dia" a alguém que o app não conhecia.
      c.nome = '  Gabriel  ';
      await c.concluir();

      expect((await perfis.carregar())!.nome, 'Gabriel');
    });

    test('nome em branco não vira nome vazio', () async {
      c.nome = '   ';
      await c.concluir();

      expect((await perfis.carregar())!.nome, equals(null));
    });

    test('"não sei quanto devo" não grava dívida nem com total digitado',
        () async {
      c.digitarTotal(9000);
      c.alternarNaoSei();
      await c.concluir();

      expect(await dividas.todas(), isEmpty);
    });
  });

  group('cada pergunta na sua cor', () {
    test('as seis perguntas têm cor, ilustração e texto do design', () {
      for (final p in PassoOnboarding.values) {
        expect(p.ilustracao, endsWith('.png'));
        expect(p.pergunta, isNotEmpty);
        expect(p.apoio, isNotEmpty);
        // A voz da Kitamo é minúscula nos títulos.
        expect(p.pergunta[0], p.pergunta[0].toLowerCase(),
            reason: 'a pergunta "${p.pergunta}" começa em maiúscula');
      }
    });

    test('as cores não se repetem: a sequência é o ritmo do onboarding', () {
      final cores = PassoOnboarding.values.map((p) => p.cor).toSet();
      expect(cores, hasLength(PassoOnboarding.values.length));
    });
  });
}
