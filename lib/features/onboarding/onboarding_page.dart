import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/tipografia.dart';
import '../../widgets/campos.dart' as kt;
import '../../widgets/moeda.dart';
import 'onboarding_controller.dart';

/// "ONBOARDING · UMA PERGUNTA POR TELA · CADA UMA NA SUA COR".
///
/// A anatomia é a das telas 02 a 07 do Kitamo App.dc.html, e é sempre a
/// mesma: progresso e "pular" no topo, ilustração centralizada, a pergunta
/// em Outfit 27, o apoio em 14.5, o campo, e "continuar" colado embaixo.
///
/// Nada de título fora da pergunta: "a pergunta é o conteúdo", diz o
/// design system.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.controller,
    required this.aoConcluir,
  });

  final OnboardingController controller;
  final VoidCallback aoConcluir;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  OnboardingController get c => widget.controller;

  final _valor = TextEditingController();

  @override
  void initState() {
    super.initState();
    c.addListener(_atualizar);
  }

  @override
  void dispose() {
    c.removeListener(_atualizar);
    _valor.dispose();
    super.dispose();
  }

  void _atualizar() => setState(() {});

  Future<void> _avancar() async {
    if (!c.ehUltimo) {
      _valor.clear();
      c.avancar();
      return;
    }
    await c.concluir();
    if (mounted) widget.aoConcluir();
  }

  void _voltar() {
    _valor.clear();
    c.voltar();
  }

  Future<void> _pular() async {
    if (!c.ehUltimo) {
      _valor.clear();
      c.avancar();
      return;
    }
    await c.concluir();
    if (mounted) widget.aoConcluir();
  }

  @override
  Widget build(BuildContext context) {
    final passo = c.passo;

    return Scaffold(
      backgroundColor: passo.cor,
      body: SafeArea(
        child: Column(
          children: [
            _TopoDoPasso(
              passo: c.indice + 1,
              total: PassoOnboarding.values.length,
              cor: passo.sobre,
              aoPular: _pular,
              aoVoltar: c.indice == 0 ? null : _voltar,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 14, 28, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/${passo.ilustracao}',
                        height: 112,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      passo.pergunta,
                      style: Tipo.numero.copyWith(
                        fontSize: 27,
                        height: 1.22,
                        letterSpacing: -27 * 0.02,
                        color: passo.sobre,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      passo.apoio,
                      style: Tipo.corpo.copyWith(
                        height: 1.6,
                        color: passo.sobreFraco,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _campo(passo),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
              child: kt.BotaoSobreAcento(
                rotulo: c.ehUltimo ? 'ver meu plano' : 'continuar',
                tinta: passo.cor,
                aoTocar: c.salvando ? null : _avancar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(PassoOnboarding passo) => switch (passo) {
        PassoOnboarding.divida => _QuantoDeve(controller: c, campo: _valor),
        PassoOnboarding.renda => _ValorSobreAcento(
            campo: _valor,
            passo: passo,
            valor: c.rendaMensal,
            aoMudar: (v) => setState(() => c.rendaMensal = v),
            leitura: _leituraDaRenda(),
          ),
        PassoOnboarding.diaRenda => _DiaDoMes(controller: c, passo: passo),
        PassoOnboarding.gasto => _ValorSobreAcento(
            campo: _valor,
            passo: passo,
            valor: c.gastoDiario,
            sufixo: '/mês',
            aoMudar: (v) => setState(() => c.gastoDiario = v),
            leitura: _leituraDoGasto(),
          ),
        PassoOnboarding.fixas => _ValorSobreAcento(
            campo: _valor,
            passo: passo,
            valor: c.contasFixas,
            sufixo: '/mês',
            aoMudar: (v) => setState(() => c.contasFixas = v),
          ),
        PassoOnboarding.extrato => _Oferta(passo: passo),
      };

  /// "com o que você deve, dá pra quitar em 10 meses" — o design mostra a
  /// conta acontecendo enquanto a pessoa digita.
  String? _leituraDaRenda() {
    final devo = c.totalDevido;
    final renda = c.rendaMensal;
    if (devo == null || renda == null || renda <= 0 || devo <= 0) return null;
    // Um quinto da renda é o que costuma sobrar pra dívida sem sufocar.
    final meses = (devo / (renda * 0.2)).ceil();
    return 'com o que você deve, dá pra quitar em $meses meses';
  }

  String? _leituraDoGasto() {
    final mes = c.gastoDiario;
    if (mes == null || mes <= 0) return null;
    return 'isso dá ${dinheiro(mes / 30)} por dia.';
  }
}

/// Progresso e "pular". Nada mais: a pergunta é o conteúdo.
class _TopoDoPasso extends StatelessWidget {
  const _TopoDoPasso({
    required this.passo,
    required this.total,
    required this.cor,
    required this.aoPular,
    this.aoVoltar,
  });

  final int passo;
  final int total;
  final Color cor;
  final VoidCallback aoPular;

  /// Null na primeira pergunta: não há pra onde voltar.
  final VoidCallback? aoVoltar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 28, 0),
      child: Row(
        children: [
          // Voltar à esquerda, espelhando o pular. Sem isto a pessoa que
          // errou uma resposta ficava presa até o fim do onboarding.
          SizedBox(
            width: 44,
            height: 44,
            child: aoVoltar == null
                ? null
                : IconButton(
                    onPressed: aoVoltar,
                    icon: const Icon(Icons.arrow_back_rounded, size: 22),
                    color: cor,
                    tooltip: 'voltar',
                    padding: EdgeInsets.zero,
                  ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: kt.ProgressoDoOnboarding(passo: passo, total: total),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: aoPular,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'pular',
                style: Tipo.corpo.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// O campo de valor grande sobre fundo colorido, com a linha de 3px.
class _ValorSobreAcento extends StatelessWidget {
  const _ValorSobreAcento({
    required this.campo,
    required this.passo,
    required this.valor,
    required this.aoMudar,
    this.sufixo,
    this.leitura,
  });

  final TextEditingController campo;
  final PassoOnboarding passo;
  final double? valor;
  final ValueChanged<double?> aoMudar;
  final String? sufixo;
  final String? leitura;

  @override
  Widget build(BuildContext context) {
    final tinta = passo.sobre;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: tinta.withValues(alpha: 0.55),
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 6),
                child: Text(
                  r'R$',
                  style: Tipo.titulo.copyWith(
                    fontSize: 21,
                    color: tinta.withValues(alpha: 0.85),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: campo,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  // Formata enquanto digita: 3500 vira "3.500,00". Sem
                  // isto a pessoa via "3500" e não sabia se era três mil e
                  // quinhentos ou trinta e cinco reais.
                  inputFormatters: const [FormatadorDeDinheiro()],
                  onChanged: (t) => aoMudar(lerDinheiro(t)),
                  cursorColor: tinta,
                  cursorWidth: 2,
                  style: Tipo.numero.copyWith(
                    fontSize: 38,
                    height: 1,
                    letterSpacing: -38 * 0.028,
                    color: tinta,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0,00',
                    hintStyle: Tipo.numero.copyWith(
                      fontSize: 38,
                      height: 1,
                      color: tinta.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
              if (sufixo != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    sufixo!,
                    style: Tipo.corpo.copyWith(
                      color: tinta.withValues(alpha: 0.85),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (leitura != null) ...[
          const SizedBox(height: 14),
          Text(
            leitura!,
            style: Tipo.corpo.copyWith(color: passo.sobreFraco),
          ),
        ],
      ],
    );
  }
}

/// "quanto você deve hoje?" — o valor grande e, embaixo, as faixas.
class _QuantoDeve extends StatelessWidget {
  const _QuantoDeve({required this.controller, required this.campo});

  final OnboardingController controller;
  final TextEditingController campo;

  @override
  Widget build(BuildContext context) {
    const passo = PassoOnboarding.divida;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ValorSobreAcento(
          campo: campo,
          passo: passo,
          valor: controller.totalDevido,
          aoMudar: controller.digitarTotal,
        ),
        const SizedBox(height: 16),
        Text(
          'OU ESCOLHA UMA FAIXA',
          style: Tipo.rotulo.copyWith(fontSize: 10.5, color: Cores.branco),
        ),
        const SizedBox(height: 8),
        for (final f in FaixaDeDivida.values) ...[
          _FaixaEscolhivel(
            faixa: f,
            marcada: controller.faixa == f,
            cor: passo.cor,
            aoTocar: () {
              campo.clear();
              controller.escolherFaixa(f);
            },
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// A faixa marcada fica branca com texto na cor da tela, e traz o rótulo
/// "É O MEU CASO" — como no design.
class _FaixaEscolhivel extends StatelessWidget {
  const _FaixaEscolhivel({
    required this.faixa,
    required this.marcada,
    required this.cor,
    required this.aoTocar,
  });

  final FaixaDeDivida faixa;
  final bool marcada;
  final Color cor;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: marcada,
      button: true,
      child: GestureDetector(
        onTap: aoTocar,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          decoration: BoxDecoration(
            color: marcada ? Cores.branco : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: marcada
                  ? Cores.branco
                  : Cores.branco.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: marcada ? cor : Cores.branco,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: marcada
                    ? Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: cor,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  faixa.rotulo,
                  style: Tipo.corpoForte.copyWith(
                    fontSize: 15,
                    fontWeight:
                        marcada ? FontWeight.w600 : FontWeight.w500,
                    color: marcada ? cor : Cores.branco,
                  ),
                ),
              ),
              if (marcada)
                Text(
                  'É O MEU CASO',
                  style: Tipo.rotulo.copyWith(fontSize: 11, color: cor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "que dia cai?" — a grade de 31 dias do design.
class _DiaDoMes extends StatelessWidget {
  const _DiaDoMes({required this.controller, required this.passo});

  final OnboardingController controller;
  final PassoOnboarding passo;

  @override
  Widget build(BuildContext context) {
    final escolhido = controller.diaRenda;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(31, (i) {
            final dia = i + 1;
            final marcado = escolhido == dia;
            return Semantics(
              selected: marcado,
              button: true,
              label: 'dia $dia',
              child: GestureDetector(
                onTap: () => controller.diaRenda = dia,
                child: Container(
                  width: 44,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: marcado
                        ? Cores.creme
                        : Cores.branco.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$dia',
                    style: Tipo.corpoForte.copyWith(
                      color: marcado ? passo.cor : Cores.creme,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (escolhido != null) ...[
          const SizedBox(height: 16),
          Text(
            'o dia $escolhido é o divisor do seu mês: '
            'tudo que cai antes disso é aperto.',
            style: Tipo.corpo.copyWith(
              height: 1.5,
              color: passo.sobreFraco,
            ),
          ),
        ],
      ],
    );
  }
}

/// A última tela: a oferta de ler o extrato.
class _Oferta extends StatelessWidget {
  const _Oferta({required this.passo});

  final PassoOnboarding passo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Cores.branco.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'o arquivo fica no seu celular. a Kitamo não pede senha de banco, '
        'não pede cartão e não manda nada pra nuvem.',
        style: Tipo.corpo.copyWith(height: 1.55, color: passo.sobre),
      ),
    );
  }
}
