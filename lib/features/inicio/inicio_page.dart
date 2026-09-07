import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/divida.dart';
import '../../models/perfil_financeiro.dart';
import '../../services/diario_service.dart';
import '../../services/horizonte_service.dart';
import '../../widgets/moeda.dart';
import '../horizonte/horizonte_page.dart';
import '../horizonte/mes_page.dart';

/// A tela que a pessoa abre todo dia.
///
/// Estrutura do design system: topo colorido com o número, cartão branco da
/// próxima parcela sobreposto, e o mês embaixo em fundo creme.
class InicioPage extends StatelessWidget {
  const InicioPage({
    super.key,
    required this.perfil,
    required this.dividas,
    this.aoQuitar,
  });

  final PerfilFinanceiro? perfil;
  final List<Divida> dividas;

  /// Chamado ao tocar em "quitei essa". Null deixa o botão inerte, o que
  /// serve para teste de tela.
  final void Function(Divida divida)? aoQuitar;

  @override
  Widget build(BuildContext context) {
    final r = const DiarioService().calcular(perfil: perfil, dividas: dividas);
    final proxima = _proximaParcela();

    return Scaffold(
      backgroundColor: Cores.creme,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Topo(resultado: r),
          if (proxima != null)
            Transform.translate(
              offset: const Offset(0, -28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Medidas.margem),
                child: _CartaoProximaParcela(
                  divida: proxima,
                  perfil: perfil,
                  aoQuitar: aoQuitar == null ? null : () => aoQuitar!(proxima),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Medidas.margem),
            child: _Atalhos(perfil: perfil, dividas: dividas),
          ),
          const SizedBox(height: Medidas.espacoGrande),
        ],
      ),
    );
  }

  /// A que vence primeiro a partir de hoje.
  Divida? _proximaParcela() {
    final abertas =
        dividas.where((d) => !d.estaQuitada && d.parcelasRestantes > 0).toList();
    if (abertas.isEmpty) return null;

    abertas.sort((a, b) {
      final va = a.previsaoQuitacao();
      final vb = b.previsaoQuitacao();
      if (va == null || vb == null) return 0;
      return a.diaVencimento.compareTo(b.diaVencimento);
    });
    return abertas.first;
  }
}

class _Topo extends StatelessWidget {
  const _Topo({required this.resultado});

  final ResultadoDiario resultado;

  @override
  Widget build(BuildContext context) {
    final fecha = resultado.fecha;
    final cor = fecha ? Cores.verde : Cores.vermelho;

    final rotulo = fecha
        ? (resultado.quitacaoLabel != null
            ? 'pra quitar até ${resultado.quitacaoLabel}'
            : 'pra hoje')
        : 'hoje a conta não fecha';

    final valor = fecha ? resultado.diario : resultado.faltaPorMes;
    final apoio = fecha ? 'é o seu diário' : 'é o que falta por mês pra fechar';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        Medidas.margem,
        MediaQuery.of(context).padding.top + 28,
        Medidas.margem,
        56,
      ),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(Medidas.raioCartao),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: Tipo.corpo.copyWith(color: Cores.branco.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 6),
          Text(
            dinheiroRedondo(valor),
            style: Tipo.numeroGigante.copyWith(color: Cores.branco),
          ),
          const SizedBox(height: 8),
          Text(
            apoio,
            style: Tipo.corpo.copyWith(color: Cores.branco.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _CartaoProximaParcela extends StatelessWidget {
  const _CartaoProximaParcela({
    required this.divida,
    required this.perfil,
    this.aoQuitar,
  });

  final Divida divida;
  final PerfilFinanceiro? perfil;
  final VoidCallback? aoQuitar;

  @override
  Widget build(BuildContext context) {
    // O descasamento que gera juros: a parcela vence antes de a renda cair.
    final diaRenda = perfil?.diaRenda;
    final caiAntes = diaRenda != null && divida.diaVencimento < diaRenda;

    return Container(
      padding: const EdgeInsets.all(Medidas.margem),
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(Medidas.raioCartao),
        boxShadow: const [
          BoxShadow(
            color: Color(0x145C2E1A),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PRÓXIMA', style: Tipo.rotulo.copyWith(color: Cores.apoio)),
          const SizedBox(height: 8),
          Text('parcela do ${divida.nome}', style: Tipo.subtitulo),
          const SizedBox(height: 4),
          Text(
            '${dinheiro(divida.valorParcela)} · vence dia ${divida.diaVencimento}',
            style: Tipo.apoio,
          ),
          if (caiAntes) ...[
            const SizedBox(height: Medidas.espaco),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: EstadoFinanceiro.atencao.fundo,
                borderRadius: BorderRadius.circular(Medidas.raioInterno),
              ),
              child: Text(
                'cai antes do salário do dia $diaRenda',
                style: Tipo.apoio.copyWith(color: Cores.tinta),
              ),
            ),
          ],
          const SizedBox(height: Medidas.espacoGrande),
          Row(
            children: [
              Text(
                '${divida.parcelasPagas} de ${divida.parcelasTotal}',
                style: Tipo.corpoForte.copyWith(color: Cores.apoio),
              ),
              const Spacer(),
              FilledButton(
                onPressed: aoQuitar,
                style: FilledButton.styleFrom(
                  backgroundColor: Cores.tinta,
                  foregroundColor: Cores.branco,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Medidas.raioPilula),
                  ),
                ),
                child: Text('quitei essa', style: Tipo.corpoForte),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


/// Atalhos para as duas visões do horizonte.
class _Atalhos extends StatelessWidget {
  const _Atalhos({required this.perfil, required this.dividas});

  final PerfilFinanceiro? perfil;
  final List<Divida> dividas;

  @override
  Widget build(BuildContext context) {
    const horizonte = HorizonteService();

    return Row(
      children: [
        Expanded(
          child: _Atalho(
            titulo: 'Seu mês',
            apoio: 'dia a dia',
            aoTocar: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MesPage(
                titulo: 'Seu mês',
                mes: horizonte.mes(
                  perfil: perfil,
                  dividas: dividas,
                  saldoInicial: 0,
                ),
              ),
            )),
          ),
        ),
        const SizedBox(width: Medidas.espaco),
        Expanded(
          child: _Atalho(
            titulo: 'O ano inteiro',
            apoio: '12 meses',
            aoTocar: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => HorizontePage(
                meses: horizonte.doze(
                  perfil: perfil,
                  dividas: dividas,
                  saldoInicial: 0,
                ),
              ),
            )),
          ),
        ),
      ],
    );
  }
}

class _Atalho extends StatelessWidget {
  const _Atalho({
    required this.titulo,
    required this.apoio,
    required this.aoTocar,
  });

  final String titulo;
  final String apoio;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(Medidas.raioCartao),
        child: Container(
          padding: const EdgeInsets.all(Medidas.margem),
          decoration: BoxDecoration(
            color: Cores.branco,
            borderRadius: BorderRadius.circular(Medidas.raioCartao),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: Tipo.corpoForte),
              const SizedBox(height: 2),
              Text(apoio, style: Tipo.apoio),
            ],
          ),
        ),
      );
}
