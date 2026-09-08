import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/data/banco.dart' show Banco;
import 'package:kitamo/features/backup/backup_service.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/repositories/divida_repository.dart';
import 'package:kitamo/repositories/perfil_repository.dart';

/// Fase 5: backup por arquivo, sem servidor.
///
/// O que estes testes guardam: um backup que não volta é pior que não ter
/// backup, porque a pessoa confiou nele. E arquivo corrompido não pode
/// deixar o app com metade dos dados novos e metade dos antigos.
void main() {
  late Banco banco;
  late BackupService service;
  late DividaRepository dividas;
  late PerfilRepository perfis;

  setUp(() {
    banco = Banco.memoria();
    dividas = DividaRepositoryDrift(banco);
    perfis = PerfilRepositoryDrift(banco);
    service = BackupService(perfis, dividas);
  });

  tearDown(() => banco.close());

  final nubank = Divida(
    id: '1',
    nome: 'Nubank',
    saldoAtual: 6136.24,
    valorParcela: 1534.06,
    diaVencimento: 4,
    parcelasRestantes: 4,
    parcelasTotal: 10,
  );

  const perfil = PerfilFinanceiro(
    rendaMensal: 3650,
    diaRenda: 6,
    gastoDiarioEstimado: 40,
    contasFixasEstimadas: 914,
  );

  test('exporta e importa de volta sem perder nada', () async {
    await perfis.salvar(perfil);
    await dividas.salvar(nubank);

    final arquivo = await service.exportar();

    // Simula outro aparelho: banco limpo.
    final outro = Banco.memoria();
    addTearDown(outro.close);
    final outroServico =
        BackupService(PerfilRepositoryDrift(outro), DividaRepositoryDrift(outro));

    final quantas = await outroServico.importar(arquivo);

    expect(quantas, 1);

    final p = await PerfilRepositoryDrift(outro).carregar();
    expect(p!.rendaMensal, 3650);
    expect(p.diaRenda, 6);
    expect(p.contasFixasEstimadas, 914);

    final d = (await DividaRepositoryDrift(outro).todas()).first;
    expect(d.nome, 'Nubank');
    expect(d.valorParcela, 1534.06);
    expect(d.saldoAtual, 6136.24);
    expect(d.parcelasRestantes, 4);
    expect(d.parcelasTotal, 10);
  });

  test('o arquivo tem versão de formato', () async {
    final json = jsonDecode(await service.exportar()) as Map<String, dynamic>;

    expect(json['versao'], BackupService.versaoFormato);
    expect(json['exportado_em'], isA<String>());
  });

  test('exporta mesmo sem nada dentro', () async {
    final json = jsonDecode(await service.exportar()) as Map<String, dynamic>;

    expect(json['perfil'], isNull);
    expect(json['dividas'], isEmpty);
  });

  test('importar substitui o que existia', () async {
    await dividas.salvar(nubank);
    final arquivo = await service.exportar();

    await dividas.salvar(Divida(
      id: '2',
      nome: 'Outra',
      saldoAtual: 100,
      valorParcela: 50,
      diaVencimento: 10,
      parcelasRestantes: 2,
      parcelasTotal: 2,
    ));
    expect(await dividas.todas(), hasLength(2));

    await service.importar(arquivo);

    final todas = await dividas.todas();
    expect(todas, hasLength(1));
    expect(todas.first.nome, 'Nubank');
  });

  test('preserva a dívida já quitada', () async {
    await dividas.salvar(Divida(
      id: 'q',
      nome: 'Paga',
      saldoAtual: 0,
      valorParcela: 200,
      diaVencimento: 5,
      parcelasRestantes: 0,
      parcelasTotal: 6,
      quitadaEm: DateTime(2026, 3, 15),
    ));

    final arquivo = await service.exportar();
    await service.importar(arquivo);

    final d = (await dividas.todas()).first;
    expect(d.estaQuitada, isTrue);
    expect(d.quitadaEm, DateTime(2026, 3, 15));
  });

  group('arquivo ruim', () {
    test('texto que não é JSON', () async {
      expect(() => service.importar('isso não é json'),
          throwsA(isA<BackupInvalido>()));
    });

    test('JSON sem ser backup', () async {
      expect(() => service.importar('{"qualquer": "coisa"}'),
          throwsA(isA<BackupInvalido>()));
    });

    test('versão futura é recusada com explicação', () async {
      expect(
        () => service.importar('{"versao": 999, "dividas": []}'),
        throwsA(isA<BackupInvalido>().having(
          (e) => e.mensagem,
          'mensagem',
          contains('mais nova'),
        )),
      );
    });

    test('dívida sem nome falha antes de gravar', () async {
      await dividas.salvar(nubank);

      final ruim = jsonEncode({
        'versao': 1,
        'dividas': [
          {'nome': 'Boa', 'parcela': 100},
          {'parcela': 200}, // sem nome
        ],
      });

      await expectLater(
          () => service.importar(ruim), throwsA(isA<BackupInvalido>()));

      // O que existia continua intacto: nada foi gravado pela metade.
      final todas = await dividas.todas();
      expect(todas, hasLength(1));
      expect(todas.first.nome, 'Nubank');
    });

    test('dia de vencimento absurdo é ajustado, não aceito', () async {
      await service.importar(jsonEncode({
        'versao': 1,
        'dividas': [
          {'nome': 'X', 'dia_vencimento': 99, 'parcelas_restantes': 1},
        ],
      }));

      expect((await dividas.todas()).first.diaVencimento, 31);
    });
  });
}
