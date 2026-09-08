import 'package:flutter/widgets.dart';

import '../../design/cores.dart';
import '../../models/divida.dart';
import '../../models/perfil_financeiro.dart';
import '../../services/diario_service.dart';
import '../../widgets/moeda.dart';

enum TipoAviso { vencimento, descasamento, conquista, aperto }

class Aviso {
  const Aviso({
    required this.tipo,
    required this.titulo,
    required this.detalhe,
    this.quando = 'agora',
    this.deHoje = true,
    this.icone,
    this.acao,
  });

  final TipoAviso tipo;
  final String titulo;
  final String detalhe;

  /// O carimbo mono da direita: "1h", "ter", "2 set". Aqui tudo é
  /// calculado na abertura, então o que existe é "agora".
  final String quando;

  /// Separa as duas seções da tela: HOJE e ANTES.
  final bool deHoje;

  /// Arquivo de imagem do tile de 38px, quando faz sentido mostrar um: o
  /// logo do banco, a casa, o joão. Null cai no ícone do tipo.
  final String? icone;

  /// O botão de largura cheia dentro do cartão. Só alguns avisos têm.
  final String? acao;

  /// A cor da faixa de 3px. É a única cor do cartão, diz o design system:
  /// a anatomia é idêntica, o que muda é o estado.
  Color get faixa => switch (tipo) {
        TipoAviso.vencimento => Cores.vermelho,
        TipoAviso.descasamento => Cores.ambar,
        TipoAviso.conquista => Cores.barro,
        TipoAviso.aperto => Cores.vermelho,
      };
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
          detalhe: '${dinheiro(d.valorParcela)} · dia ${d.diaVencimento}',
          icone: _logo(d.nome),
          acao: 'quitei essa',
        ));
      } else if (faltam == 1) {
        lista.add(Aviso(
          tipo: TipoAviso.vencimento,
          titulo: 'a parcela do ${d.nome} vence amanhã',
          detalhe: '${dinheiro(d.valorParcela)} · dia ${d.diaVencimento}',
          icone: _logo(d.nome),
          acao: 'quitei essa',
        ));
      }

      final diaRenda = perfil?.diaRenda;
      if (diaRenda != null && d.diaVencimento < diaRenda && faltam <= 5) {
        lista.add(Aviso(
          tipo: TipoAviso.descasamento,
          titulo: 'essa parcela cai antes do seu salário',
          detalhe: 'dia ${d.diaVencimento} sai, dia $diaRenda entra',
          acao: 'pedir pra mudar o vencimento',
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
        detalhe: 'a casa está quase de pé',
        deHoje: false,
        quando: 'esta semana',
        icone: 'casa-3.png',
      ));
    }

    final r = const DiarioService().calcular(perfil: perfil, dividas: abertas);
    if (!r.fecha && (perfil?.rendaMensal ?? 0) > 0) {
      lista.add(Aviso(
        tipo: TipoAviso.aperto,
        titulo: 'esse mês a conta não fecha',
        detalhe: 'faltam ${dinheiro(r.faltaPorMes)}. Veja os caminhos.',
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

  /// O logo do banco quando o nome da dívida diz qual é. Sem chute: se não
  /// bate, o cartão fica com o ícone do tipo.
  String? _logo(String nome) {
    final n = nome.toLowerCase();
    if (n.contains('nubank') || n.contains('nu ')) return 'bank-nubank.png';
    if (n.contains('itau') || n.contains('itaú')) return 'bank-itau.png';
    if (n.contains('mercado')) return 'bank-mp.png';
    return null;
  }

}
