import '../../models/divida.dart';
import '../../models/perfil_financeiro.dart';
import '../../services/diario_service.dart';

enum TipoAviso { vencimento, descasamento, conquista, aperto }

class Aviso {
  const Aviso({
    required this.tipo,
    required this.titulo,
    required this.detalhe,
  });

  final TipoAviso tipo;
  final String titulo;
  final String detalhe;
}

/// Os avisos do sino.
///
/// Todos são **calculados na hora**, não guardados. Um aviso salvo fica
/// velho: "vence amanhã" gravado ontem vira mentira hoje. Calcular a cada
/// abertura garante que o que está na tela é verdade agora.
class Avisos {
  const Avisos();

  List<Aviso> montar({
    required PerfilFinanceiro? perfil,
    required List<Divida> dividas,
    DateTime? hoje,
  }) {
    final dia = hoje ?? DateTime.now();
    final abertas = dividas.where((d) => !d.estaQuitada).toList();
    final lista = <Aviso>[];

    for (final d in abertas) {
      if (d.parcelasRestantes < 1) continue;

      final faltam = _diasAte(d.diaVencimento, dia);

      if (faltam == 0) {
        lista.add(Aviso(
          tipo: TipoAviso.vencimento,
          titulo: 'a parcela do ${d.nome} vence hoje',
          detalhe: _real(d.valorParcela),
        ));
      } else if (faltam == 1) {
        lista.add(Aviso(
          tipo: TipoAviso.vencimento,
          titulo: 'a parcela do ${d.nome} vence amanhã',
          detalhe: _real(d.valorParcela),
        ));
      }

      final diaRenda = perfil?.diaRenda;
      if (diaRenda != null && d.diaVencimento < diaRenda && faltam <= 5) {
        lista.add(Aviso(
          tipo: TipoAviso.descasamento,
          titulo: 'essa parcela cai antes do seu salário',
          detalhe: 'vence dia ${d.diaVencimento}, o salário entra dia '
              '$diaRenda. Vale pedir para mudar o vencimento.',
        ));
      }
    }

    // Conquista: só quando está perto do fim, senão vira ruído todo mês.
    final faltamParcelas =
        abertas.fold<int>(0, (s, d) => s + d.parcelasRestantes);
    if (faltamParcelas > 0 && faltamParcelas <= 3) {
      lista.add(Aviso(
        tipo: TipoAviso.conquista,
        titulo: faltamParcelas == 1
            ? 'falta uma parcela'
            : 'faltam $faltamParcelas parcelas',
        detalhe: 'a casa está quase de pé.',
      ));
    }

    final r = const DiarioService().calcular(perfil: perfil, dividas: abertas);
    if (!r.fecha && (perfil?.rendaMensal ?? 0) > 0) {
      lista.add(Aviso(
        tipo: TipoAviso.aperto,
        titulo: 'esse mês a conta não fecha',
        detalhe: 'faltam ${_real(r.faltaPorMes)}. Veja os caminhos.',
      ));
    }

    return lista;
  }

  /// Dias até o vencimento, respeitando meses curtos: um vencimento dia 31
  /// em fevereiro cai no dia 28.
  int _diasAte(int diaVencimento, DateTime hoje) {
    final ultimoDia = DateTime(hoje.year, hoje.month + 1, 0).day;
    final alvo = diaVencimento < ultimoDia ? diaVencimento : ultimoDia;

    if (alvo >= hoje.day) return alvo - hoje.day;

    // Já passou: conta para o mês seguinte.
    final prox = DateTime(hoje.year, hoje.month + 1, 1);
    final ultimoProx = DateTime(prox.year, prox.month + 1, 0).day;
    final alvoProx = diaVencimento < ultimoProx ? diaVencimento : ultimoProx;

    return (ultimoDia - hoje.day) + alvoProx;
  }

  String _real(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';
}
