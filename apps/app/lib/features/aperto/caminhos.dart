import '../../models/divida.dart';
import '../../models/perfil_financeiro.dart';
import '../../services/diario_service.dart';

/// Um caminho de saída quando a conta não fecha.
class Caminho {
  const Caminho({
    required this.titulo,
    required this.detalhe,
    this.acao,
  });

  final String titulo;
  final String detalhe;

  /// O que a pessoa pode fazer. Null quando é só constatação.
  final String? acao;
}

/// Monta os caminhos da tela "a conta não fecha".
///
/// A regra de tom: **honesto sem ser cruel, e nunca sermão.** Quem está no
/// aperto já sabe que está — o que falta é o que fazer. Cada item aponta um
/// número concreto, não um conselho genérico como "corte gastos".
class Caminhos {
  const Caminhos();

  List<Caminho> montar({
    required PerfilFinanceiro? perfil,
    required List<Divida> dividas,
  }) {
    final abertas = dividas.where((d) => !d.estaQuitada).toList();
    final r = const DiarioService().calcular(perfil: perfil, dividas: abertas);

    final lista = <Caminho>[];

    // 1. Onde o dinheiro está comprometido. Mostrar o maior primeiro é o
    // que responde "por que não sobra".
    if (r.parcelasDoMes > 0 || r.contasFixas > 0) {
      lista.add(Caminho(
        titulo: 'Onde seu dinheiro já está',
        detalhe: 'parcelas somam R\$ ${_fmt(r.parcelasDoMes)} e as contas '
            'fixas R\$ ${_fmt(r.contasFixas)} por mês.',
      ));
    }

    // 2. O descasamento de datas — o caso que custou R$ 1.674 em 12 meses.
    // É o item de maior retorno e custo zero.
    final diaRenda = perfil?.diaRenda;
    if (diaRenda != null) {
      final antes =
          abertas.where((d) => d.diaVencimento < diaRenda).toList();

      if (antes.isNotEmpty) {
        final nomes = antes.map((d) => d.nome).join(', ');
        lista.add(Caminho(
          titulo: 'Uma parcela vence antes do seu salário',
          detalhe: 'a do $nomes cai antes do dia $diaRenda. Quando isso '
              'acontece, o atraso vira juros todo mês.',
          acao: 'peça ao banco para mudar o vencimento',
        ));
      }
    }

    // 3. A menor parcela: a que sai mais rápido do caminho.
    if (abertas.length > 1) {
      final menor = abertas
          .reduce((a, b) => a.valorParcela <= b.valorParcela ? a : b);

      lista.add(Caminho(
        titulo: 'A menor sai primeiro',
        detalhe: 'a do ${menor.nome} é R\$ ${_fmt(menor.valorParcela)} e '
            'faltam ${menor.parcelasRestantes}. Quitando ela, sobra esse '
            'valor todo mês.',
      ));
    }

    // 4. Renegociação, sem prometer o que o app não faz.
    lista.add(const Caminho(
      titulo: 'Dá pra renegociar',
      detalhe: 'bancos costumam aceitar renegociar quando você procura '
          'antes de atrasar. Peça o CET por escrito e compare com o que '
          'você paga hoje.',
    ));

    return lista;
  }

  String _fmt(double v) => v.toStringAsFixed(2).replaceAll('.', ',');
}
