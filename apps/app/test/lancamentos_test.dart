import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/data/banco.dart' show Banco;
import 'package:kitamo/models/lancamento_registro.dart';
import 'package:kitamo/repositories/lancamento_repository.dart';

/// Lançamentos: o que a pessoa registra pelo botão `+`.
void main() {
  late Banco banco;
  late LancamentoRepository repo;

  setUp(() {
    banco = Banco.memoria();
    repo = LancamentoRepositoryDrift(banco);
  });

  tearDown(() => banco.close());

  LancamentoRegistro item({
    String id = '1',
    String descricao = 'Mercado',
    double valor = 87.4,
    TipoLancamento tipo = TipoLancamento.gasto,
    DateTime? data,
  }) =>
      LancamentoRegistro(
        id: id,
        descricao: descricao,
        valor: valor,
        tipo: tipo,
        data: data ?? DateTime(2026, 9, 6),
      );

  test('salva e lê de volta', () async {
    await repo.salvar(item());

    final l = (await repo.listar()).single;
    expect(l.descricao, 'Mercado');
    expect(l.valor, 87.4);
    expect(l.ehEntrada, isFalse);
  });

  test('centavos sobrevivem ao ida e volta', () async {
    await repo.salvar(item(valor: 0.1 + 0.2));

    expect((await repo.listar()).single.valor, 0.3);
  });

  test('filtra por entradas e saídas', () async {
    await repo.salvar(item(id: '1'));
    await repo.salvar(item(id: '2', tipo: TipoLancamento.entrada, valor: 500));

    expect(await repo.listar(filtro: FiltroLancamento.todos), hasLength(2));
    expect(
      (await repo.listar(filtro: FiltroLancamento.entradas)).single.valor,
      500,
    );
    expect(
      (await repo.listar(filtro: FiltroLancamento.saidas)).single.descricao,
      'Mercado',
    );
  });

  test('lista o mais recente primeiro', () async {
    await repo.salvar(item(id: 'velho', data: DateTime(2026, 9, 1)));
    await repo.salvar(item(id: 'novo', data: DateTime(2026, 9, 10)));

    expect((await repo.listar()).first.id, 'novo');
  });

  test('valor com sinal facilita somar lista misturada', () {
    expect(item(valor: 100).valorComSinal, -100);
    expect(item(valor: 100, tipo: TipoLancamento.entrada).valorComSinal, 100);
  });

  group('total do mês', () {
    test('soma só os gastos do mês pedido', () async {
      await repo.salvar(item(id: '1', valor: 100, data: DateTime(2026, 9, 5)));
      await repo.salvar(item(id: '2', valor: 50, data: DateTime(2026, 9, 20)));
      // Entrada não conta como gasto.
      await repo.salvar(item(
        id: '3',
        valor: 900,
        tipo: TipoLancamento.entrada,
        data: DateTime(2026, 9, 6),
      ));
      // Outro mês não entra.
      await repo.salvar(item(id: '4', valor: 700, data: DateTime(2026, 8, 30)));

      expect(await repo.totalGastoNoMes(DateTime(2026, 9, 1)), 150);
    });

    test('inclui o último dia do mês, com hora', () async {
      // O caso que um `<=` mal escrito perderia: gasto às 23h do dia 30.
      await repo.salvar(
          item(id: 'x', valor: 40, data: DateTime(2026, 9, 30, 23, 59)));

      expect(await repo.totalGastoNoMes(DateTime(2026, 9, 15)), 40);
    });

    test('mês sem gasto devolve zero', () async {
      expect(await repo.totalGastoNoMes(DateTime(2026, 1, 1)), 0);
    });
  });

  test('remover apaga', () async {
    await repo.salvar(item());
    await repo.remover('1');

    expect(await repo.listar(), isEmpty);
  });
}
