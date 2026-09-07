import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/data/banco.dart' show Banco;
import 'package:kitamo/features/quitar/quitar_service.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/repositories/divida_repository.dart';

/// Fase 4: "quitei essa".
///
/// O risco aqui é duplo e os dois lados doem: baixar parcela a mais faz a
/// pessoa achar que deve menos do que deve; não registrar a antecipação
/// tira o retorno de quem se esforçou para pagar adiantado.
void main() {
  late Banco banco;
  late DividaRepository repo;
  late QuitarService service;

  setUp(() {
    banco = Banco.memoria();
    repo = DividaRepositoryDrift(banco);
    service = QuitarService(repo);
  });

  tearDown(() => banco.close());

  Divida nubank({int restantes = 4, int total = 10}) => Divida(
        id: '1',
        nome: 'Nubank',
        saldoAtual: 1534.06 * restantes,
        valorParcela: 1534.06,
        diaVencimento: 4,
        parcelasRestantes: restantes,
        parcelasTotal: total,
      );

  const perfil = PerfilFinanceiro(rendaMensal: 3650, diaRenda: 6);

  test('baixa uma parcela e devolve o resultado', () async {
    await repo.salvar(nubank());

    final r = await service.quitarParcela('1', perfil: perfil);

    expect(r, isNotNull);
    expect(r!.divida.parcelasRestantes, 3);
    expect(r.divida.parcelasPagas, 7);
    expect(r.acabou, isFalse);
  });

  test('a última parcela encerra e a casa fica pronta', () async {
    await repo.salvar(nubank(restantes: 1));

    final r = await service.quitarParcela('1', perfil: perfil);

    expect(r!.acabou, isTrue);
    expect(r.faseDaCasa, 5);
    expect(r.caminhoDaCasa, 'assets/images/casa-5.png');
  });

  test('a data de quitação recua ao antecipar', () async {
    await repo.salvar(nubank(restantes: 4));

    final r = await service.quitarParcela('1', perfil: perfil);

    expect(r!.quitacaoAntes, isNotNull);
    expect(r.quitacaoDepois, isNotNull);
    expect(r.quitacaoDepois!.isBefore(r.quitacaoAntes!), isTrue,
        reason: 'antecipar precisa dar retorno visível');
  });

  test('quitar dívida inexistente devolve null', () async {
    expect(await service.quitarParcela('nao-existe'), isNull);
  });

  group('casa', () {
    test('cresce conforme as parcelas caem', () async {
      await repo.salvar(nubank(restantes: 10, total: 10));

      final fases = <int>[];
      for (var i = 0; i < 9; i++) {
        final r = await service.quitarParcela('1', perfil: perfil);
        fases.add(r!.faseDaCasa);
      }

      // Nunca regride, e não chega na 5 antes de terminar.
      for (var i = 1; i < fases.length; i++) {
        expect(fases[i], greaterThanOrEqualTo(fases[i - 1]));
      }
      expect(fases.every((f) => f >= 1 && f <= 4), isTrue);
    });

    test('a fase 5 é exclusiva de quem terminou', () async {
      await repo.salvar(nubank(restantes: 2, total: 2));

      final meio = await service.quitarParcela('1', perfil: perfil);
      expect(meio!.faseDaCasa, lessThan(5));

      final fim = await service.quitarParcela('1', perfil: perfil);
      expect(fim!.faseDaCasa, 5);
    });
  });
}
