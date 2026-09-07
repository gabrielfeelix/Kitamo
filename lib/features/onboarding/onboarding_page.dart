import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import 'onboarding_controller.dart';

/// O onboarding: uma pergunta por tela, tela cheia na cor do passo.
///
/// "Pular" nunca some. Menos de 90 segundos até o número.
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

  @override
  void initState() {
    super.initState();
    c.addListener(_atualizar);
  }

  @override
  void dispose() {
    c.removeListener(_atualizar);
    super.dispose();
  }

  void _atualizar() => setState(() {});

  Future<void> _avancar() async {
    if (!c.ehUltimo) {
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
            _Progresso(valor: c.progresso, cor: passo.sobre),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Medidas.margem),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _conteudo(passo),
                ),
              ),
            ),
            _Acoes(
              controller: c,
              cor: passo.sobre,
              aoAvancar: _avancar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _conteudo(PassoOnboarding passo) => switch (passo) {
        PassoOnboarding.divida => _PerguntaDivida(controller: c),
        PassoOnboarding.renda => _PerguntaValor(
            key: const ValueKey('renda'),
            titulo: 'Quanto entra por mês?',
            apoio: 'Salário, pró-labore, o que for fixo.',
            valor: c.rendaMensal,
            cor: passo.sobre,
            aoMudar: (v) => c.rendaMensal = v,
          ),
        PassoOnboarding.diaRenda => _PerguntaValor(
            key: const ValueKey('dia'),
            titulo: 'Que dia cai?',
            apoio: 'Serve pra saber se alguma parcela vence antes.',
            valor: c.diaRenda?.toDouble(),
            cor: passo.sobre,
            dica: 'dia 5',
            inteiro: true,
            aoMudar: (v) => c.diaRenda = v?.round(),
          ),
        PassoOnboarding.gasto => _PerguntaValor(
            key: const ValueKey('gasto'),
            titulo: 'Quanto sai com o dia a dia?',
            apoio: 'Vai no feeling: mercado, padaria, iFood… por dia.',
            valor: c.gastoDiario,
            cor: passo.sobre,
            aoMudar: (v) => c.gastoDiario = v,
          ),
        PassoOnboarding.fixas => _PerguntaValor(
            key: const ValueKey('fixas'),
            titulo: 'Tem alguma conta fixa?',
            apoio: 'Aluguel, luz, internet, assinatura. Some tudo.',
            valor: c.contasFixas,
            cor: passo.sobre,
            aoMudar: (v) => c.contasFixas = v,
          ),
        PassoOnboarding.extrato => _Oferta(cor: passo.sobre),
      };
}

class _Progresso extends StatelessWidget {
  const _Progresso({required this.valor, required this.cor});

  final double valor;
  final Color cor;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'progresso do cadastro',
        value: '${(valor * 100).round()}%',
        child: LinearProgressIndicator(
          value: valor,
          minHeight: 4,
          backgroundColor: cor.withValues(alpha: 0.25),
          valueColor: AlwaysStoppedAnimation(cor),
        ),
      );
}

class _Titulo extends StatelessWidget {
  const _Titulo({required this.titulo, required this.apoio, required this.cor});

  final String titulo;
  final String apoio;
  final Color cor;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Medidas.espacoGrande),
          Text(titulo, style: Tipo.titulo.copyWith(color: cor)),
          const SizedBox(height: 8),
          Text(apoio,
              style: Tipo.corpo.copyWith(color: cor.withValues(alpha: 0.85))),
          const SizedBox(height: Medidas.espacoGrande),
        ],
      );
}

class _PerguntaValor extends StatelessWidget {
  const _PerguntaValor({
    super.key,
    required this.titulo,
    required this.apoio,
    required this.valor,
    required this.cor,
    required this.aoMudar,
    this.dica = r'R$ 0,00',
    this.inteiro = false,
  });

  final String titulo;
  final String apoio;
  final double? valor;
  final Color cor;
  final ValueChanged<double?> aoMudar;
  final String dica;
  final bool inteiro;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Titulo(titulo: titulo, apoio: apoio, cor: cor),
          TextFormField(
            initialValue: valor == null
                ? ''
                : (inteiro ? valor!.round().toString() : valor.toString()),
            keyboardType: TextInputType.numberWithOptions(decimal: !inteiro),
            style: Tipo.numeroMedio.copyWith(color: Cores.tinta),
            decoration: _decoracao(dica),
            onChanged: (t) => aoMudar(double.tryParse(t.replaceAll(',', '.'))),
          ),
        ],
      );
}

InputDecoration _decoracao(String dica) => InputDecoration(
      hintText: dica,
      hintStyle: Tipo.corpo.copyWith(color: Cores.apoio),
      filled: true,
      fillColor: Cores.branco,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Medidas.raioInterno),
        borderSide: BorderSide.none,
      ),
    );

class _PerguntaDivida extends StatelessWidget {
  const _PerguntaDivida({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final cor = controller.passo.sobre;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Titulo(
          titulo: 'Quanto você deve hoje?',
          apoio: 'Cartão, empréstimo, crediário — o que estiver pesando.',
          cor: cor,
        ),
        InkWell(
          onTap: controller.alternarNaoSei,
          child: Row(
            children: [
              Checkbox(
                value: controller.naoSeiQuantoDevo,
                onChanged: (_) => controller.alternarNaoSei(),
                fillColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.selected)
                      ? Cores.branco
                      : Colors.transparent,
                ),
                checkColor: Cores.vermelho,
                side: BorderSide(color: cor, width: 2),
              ),
              Text('não sei ainda', style: Tipo.corpo.copyWith(color: cor)),
            ],
          ),
        ),
        if (!controller.naoSeiQuantoDevo) ...[
          const SizedBox(height: Medidas.espaco),
          for (var i = 0; i < controller.rascunhos.length; i++)
            _CampoDivida(
              key: ValueKey(i),
              rascunho: controller.rascunhos[i],
              cor: cor,
              aoRemover: controller.rascunhos.length > 1
                  ? () => controller.removerDivida(i)
                  : null,
            ),
          TextButton(
            onPressed: controller.adicionarDivida,
            child: Text('+ tenho outra',
                style: Tipo.corpoForte.copyWith(color: cor)),
          ),
        ],
      ],
    );
  }
}

class _CampoDivida extends StatelessWidget {
  const _CampoDivida({
    super.key,
    required this.rascunho,
    required this.cor,
    this.aoRemover,
  });

  final RascunhoDivida rascunho;
  final Color cor;
  final VoidCallback? aoRemover;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Medidas.espacoGrande),
        child: Column(
          children: [
            TextFormField(
              initialValue: rascunho.nome,
              style: Tipo.corpo.copyWith(color: Cores.tinta),
              decoration: _decoracao('de quem? (Nubank, Itaú…)'),
              onChanged: (t) => rascunho.nome = t,
            ),
            const SizedBox(height: Medidas.espaco),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: Tipo.corpo.copyWith(color: Cores.tinta),
                    decoration: _decoracao('parcela R\$'),
                    onChanged: (t) =>
                        rascunho.parcela = double.tryParse(t.replaceAll(',', '.')),
                  ),
                ),
                const SizedBox(width: Medidas.espaco),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    style: Tipo.corpo.copyWith(color: Cores.tinta),
                    decoration: _decoracao('faltam'),
                    onChanged: (t) => rascunho.restantes = int.tryParse(t),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Medidas.espaco),
            TextFormField(
              keyboardType: TextInputType.number,
              style: Tipo.corpo.copyWith(color: Cores.tinta),
              decoration: _decoracao('vence dia'),
              onChanged: (t) => rascunho.diaVencimento = int.tryParse(t),
            ),
            if (aoRemover != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: aoRemover,
                  child: Text('remover',
                      style: Tipo.apoio.copyWith(color: cor)),
                ),
              ),
          ],
        ),
      );
}

class _Oferta extends StatelessWidget {
  const _Oferta({required this.cor});

  final Color cor;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Titulo(
            titulo: 'Quer que a gente leia seu extrato?',
            apoio: 'Em vez de chutar, a gente lê o arquivo que o seu banco '
                'exporta e preenche com número real. Dá pra fazer depois.',
            cor: cor,
          ),
          Image.asset('assets/images/joao-avatar.png', height: 140),
        ],
      );
}

class _Acoes extends StatelessWidget {
  const _Acoes({
    required this.controller,
    required this.cor,
    required this.aoAvancar,
  });

  final OnboardingController controller;
  final Color cor;
  final Future<void> Function() aoAvancar;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(Medidas.margem),
        child: Row(
          children: [
            if (controller.indice > 0)
              TextButton(
                onPressed: controller.voltar,
                child: Text('voltar', style: Tipo.corpo.copyWith(color: cor)),
              ),
            // "Pular" nunca some: dado obrigatório antes de mostrar valor é
            // a maior fonte de abandono.
            TextButton(
              onPressed: controller.salvando ? null : aoAvancar,
              child: Text('pular', style: Tipo.corpo.copyWith(color: cor)),
            ),
            const Spacer(),
            FilledButton(
              onPressed: controller.salvando ? null : aoAvancar,
              style: FilledButton.styleFrom(
                backgroundColor: Cores.tinta,
                foregroundColor: Cores.branco,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Medidas.raioPilula),
                ),
              ),
              child: Text(
                controller.ehUltimo ? 'ver meu número' : 'continuar',
                style: Tipo.corpoForte,
              ),
            ),
          ],
        ),
      );
}
