import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/divida.dart';
import '../../models/lancamento_registro.dart';
import '../../models/perfil_financeiro.dart';
import '../../services/dia_de_hoje.dart';
import '../../services/diario_service.dart';
import '../../services/horizonte_service.dart';
import '../../widgets/moeda.dart';
import '../../widgets/pecas.dart';
import '../aperto/aperto_page.dart';
import '../avisos/avisos.dart';
import '../avisos/avisos_page.dart';
import '../horizonte/horizonte_page.dart';
import 'cabecalho_do_inicio.dart';
import 'cartoes_do_inicio.dart';

/// A tela que a pessoa abre todo dia.
///
/// Montada a partir da tela "INÍCIO · DIA TRANQUILO" do Kitamo App.dc.html,
/// na ordem do design: cabeçalho colorido com o número e o joão encostado no
/// canto, e abaixo, em creme, os cartões brancos a 9px um do outro.
class InicioPage extends StatelessWidget {
  const InicioPage({
    super.key,
    required this.perfil,
    required this.dividas,
    this.aoQuitar,
    this.lancamentosDeHoje = const [],
    this.aoAbrirPerfil,
    this.aoAbrirHistorico,
  });

  final PerfilFinanceiro? perfil;
  final List<Divida> dividas;

  /// Leva para a aba do histórico. Null empilha a tela, como antes.
  final VoidCallback? aoAbrirHistorico;

  /// Chamado ao tocar em "quitei essa". Null deixa o botão inerte, o que
  /// serve para teste de tela.
  final void Function(Divida divida)? aoQuitar;

  /// Alimenta o "você passou R$ X do dia".
  final List<LancamentoRegistro> lancamentosDeHoje;

  /// Tocar no avatar do cabeçalho leva ao perfil. Sem isto o avatar era
  /// só desenho, e a pessoa tocava nele esperando ir pra algum lugar.
  final VoidCallback? aoAbrirPerfil;

  @override
  Widget build(BuildContext context) {
    final r = const DiarioService().calcular(perfil: perfil, dividas: dividas);
    final proxima = _proximaParcela();
    final hoje = DiaDeHoje.calcular(
      diario: r.diario,
      lancamentos: lancamentosDeHoje,
    );
    final avisos = const Avisos().montar(perfil: perfil, dividas: dividas);
    final estado = _estadoDoDia(r, hoje);

    return Scaffold(
      backgroundColor: Cores.creme,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CabecalhoDoInicio(
            estado: estado,
            rotulo: r.fecha
                ? 'você pode gastar hoje'
                : 'falta por mês pra conta fechar',
            numero: dinheiro(r.fecha ? r.diario : -r.faltaPorMes),
            frase: _frase(r, hoje),
            chipSecundario: r.fecha
                ? 'sobra no mês: ${dinheiro(r.sobraMensal)}'
                : '3 caminhos pra resolver',
            nome: perfil?.nome ?? '',
            temAviso: avisos.isNotEmpty,
            aoTocarAvisos: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AvisosPage(avisos: avisos)),
            ),
            aoTocarPerfil: aoAbrirPerfil,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Medidas.margem,
              Medidas.espaco,
              Medidas.margem,
              Medidas.rodapeComBarra,
            ),
            child: Column(
              children: [
                if (!r.fecha) ...[
                  _CartaoCaminhos(
                    perfil: perfil,
                    dividas: dividas,
                    falta: r.faltaPorMes,
                  ),
                  const SizedBox(height: Medidas.entreCartoes),
                ],
                if (proxima != null) ...[
                  CartaoProximaParcela(
                    divida: proxima,
                    diaRenda: perfil?.diaRenda,
                    aoQuitar:
                        aoQuitar == null ? null : () => aoQuitar!(proxima),
                  ),
                  const SizedBox(height: Medidas.entreCartoes),
                ],
                if (r.fecha && r.diario > 0) ...[
                  _CartaoHoje(hoje: hoje),
                  const SizedBox(height: Medidas.entreCartoes),
                ],
                _cartaoDoMes(context),
                const SizedBox(height: Medidas.entreCartoes),
                if (proxima != null) _cartaoDaCasa(context, proxima),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// O gráfico do Início: o saldo projetado dia a dia deste mês.
  Widget _cartaoDoMes(BuildContext context) {
    const horizonte = HorizonteService();
    final gastos = <int, double>{};
    final agora = DateTime.now();
    for (final l in lancamentosDeHoje) {
      if (l.ehEntrada) continue;
      if (l.data.year != agora.year || l.data.month != agora.month) continue;
      gastos[l.data.day] = (gastos[l.data.day] ?? 0) + l.valor;
    }

    final mes = horizonte.mes(
      perfil: perfil,
      dividas: dividas,
      saldoInicial: 0,
      gastos: gastos,
    );
    final saldos = mes.dias.map((d) => d.saldo).toList();
    final fundo = mes.primeiroDiaApertado;

    return CartaoDoMes(
      titulo: '${_mesPorExtenso(DateTime.now().month)}, dia a dia',
      saldos: saldos,
      leitura: fundo == null ? null : 'dia ${fundo.day} é o fundo do mês',
      // O cartão fala do mês, então abre no mês. As outras duas abas ficam
      // a um toque, no segmentado do topo.
      aoVerDoze: () => _abrirHorizonte(context, AbaDoHorizonte.dias),
    );
  }

  /// O horizonte é **uma tela só**, com o segmentado dias | meses | ano.
  ///
  /// Antes eram duas telas soltas, e o mensal abria tocando no cartão da
  /// casa — nada no cartão avisava, e ninguém adivinhava o caminho.
  void _abrirHorizonte(BuildContext context, AbaDoHorizonte aba) {
    // O histórico agora é aba: trocar de aba é melhor que empilhar uma
    // segunda cópia da mesma tela por cima da barra.
    if (aoAbrirHistorico != null) {
      aoAbrirHistorico!();
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => HorizontePage(
        perfil: perfil,
        dividas: dividas,
        lancamentos: lancamentosDeHoje,
        abaInicial: aba,
      ),
    ));
  }

  /// O cartão de acento: a casa que sobe conforme as parcelas caem.
  /// Um por tela — por isso ele é o último e não divide espaço com outro.
  Widget _cartaoDaCasa(BuildContext context, Divida d) {
    final pagas = d.parcelasPagas;
    final total = d.parcelasTotal;
    if (total <= 0) return const SizedBox.shrink();

    final faltam = total - pagas;
    final quitacao = d.previsaoQuitacao();

    return CartaoDeAcento(
      titulo: '$pagas de $total.\nfaltam $faltam.',
      apoio: quitacao == null
          ? 'a casa sobe a cada parcela'
          : 'a última cai em ${quitacao.day} de ${_mesPorExtenso(quitacao.month)}',
      ilustracao: 'casa-${_faseDaCasa(pagas, total)}.png',
      // A casa é a dívida acabando, então abre no ano — onde o cartão
      // barro diz quando a última parcela cai.
      aoTocar: () => _abrirHorizonte(context, AbaDoHorizonte.ano),
    );
  }

  /// A fase 5 é exclusiva de quem terminou — a regra que os testes guardam.
  static int _faseDaCasa(int pagas, int total) {
    if (total <= 0) return 1;
    if (pagas >= total) return 5;
    final p = pagas / total;
    if (p < 0.2) return 1;
    if (p < 0.45) return 2;
    if (p < 0.7) return 3;
    return 4;
  }

  /// A cor do cabeçalho conta o estado antes de a pessoa ler o número.
  static CabecalhoDoDia _estadoDoDia(ResultadoDiario r, DiaDeHoje hoje) {
    if (!r.fecha) return CabecalhoDoDia.aperto;
    if (hoje.passou) return CabecalhoDoDia.atencao;
    return CabecalhoDoDia.tranquilo;
  }

  /// A voz da Kitamo: número primeiro, frase curta depois, sem culpa.
  String _frase(ResultadoDiario r, DiaDeHoje hoje) {
    if (!r.fecha) {
      final ate = r.quitacaoLabel;
      return ate == null
          ? 'sem mexer em nada, a conta não fecha'
          : 'sem mexer em nada, a conta não fecha até $ate';
    }
    if (hoje.passou) {
      return 'hoje você já passou ${dinheiro(hoje.quantoPassou)} do combinado';
    }
    final ate = r.quitacaoLabel;
    return ate == null
        ? 'gastando até isso hoje, o mês fecha'
        : 'gastando até isso hoje, a última parcela ainda cai em $ate';
  }

  /// A que vence primeiro a partir de hoje.
  Divida? _proximaParcela() {
    final abertas =
        dividas.where((d) => !d.estaQuitada && d.parcelasRestantes > 0).toList();
    if (abertas.isEmpty) return null;

    abertas.sort((a, b) => a.diaVencimento.compareTo(b.diaVencimento));
    return abertas.first;
  }
}

String _mesPorExtenso(int m) => const [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ][m - 1];

/// "você passou R$ 14,56 do dia" — o real contra o planejado.
class _CartaoHoje extends StatelessWidget {
  const _CartaoHoje({required this.hoje});

  final DiaDeHoje hoje;

  @override
  Widget build(BuildContext context) {
    final passou = hoje.passou;

    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Rotulo('hoje'),
          const SizedBox(height: 8),
          Text(
            passou
                ? 'você passou ${dinheiro(hoje.quantoPassou)} do dia'
                : 'ainda dá pra gastar ${dinheiro(hoje.sobra)}',
            style: Tipo.corpoForte.copyWith(
              color: passou ? Cores.vermelho : Cores.tinta,
            ),
          ),
          const SizedBox(height: Medidas.espaco),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              // Estourou passa de 1: a barra mostra o excesso cheia, não
              // some com ele.
              value: hoje.proporcao.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Cores.bege,
              valueColor: AlwaysStoppedAnimation(
                passou ? Cores.vermelho : Cores.verde,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'gastou ${dinheiro(hoje.jaGastou)} de ${dinheiro(hoje.podeGastar)}',
            style: Tipo.apoio,
          ),
        ],
      ),
    );
  }
}

/// Quando a conta não fecha: leva para os caminhos, sem sermão.
class _CartaoCaminhos extends StatelessWidget {
  const _CartaoCaminhos({
    required this.perfil,
    required this.dividas,
    required this.falta,
  });

  final PerfilFinanceiro? perfil;
  final List<Divida> dividas;
  final double falta;

  @override
  Widget build(BuildContext context) => Cartao(
        aoTocar: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ApertoPage(
            perfil: perfil,
            dividas: dividas,
            faltaPorMes: falta,
          ),
        )),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('escolher um caminho', style: Tipo.corpoForte),
                  const SizedBox(height: 4),
                  Text('o que dá pra fazer sobre isso', style: Tipo.apoio),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Cores.apoio),
          ],
        ),
      );
}
