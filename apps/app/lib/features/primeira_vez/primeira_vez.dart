import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';

/// Um passo do onboarding: o que explicar e onde ele aponta.
class PassoDaPrimeiraVez {
  const PassoDaPrimeiraVez({
    required this.rotulo,
    required this.titulo,
    required this.texto,
    required this.alinhamento,
    this.rodape,
  });

  /// "1 DE 3 · ESSE NÚMERO"
  final String rotulo;

  final String titulo;
  final String texto;

  /// Onde o balão fica, para não cobrir o que está sendo explicado.
  final Alignment alinhamento;

  /// A fala do joão no rodapé. Null no último passo.
  final String? rodape;
}

/// A #32 "Primeira vez": o **onboarding de verdade**.
///
/// Não confundir com as perguntas iniciais nem com o resultado (#17). Este
/// é o que **ensina a usar**, depois de tudo respondido: véu escuro sobre
/// o Início já preenchido, e três balões explicando de onde vem o número,
/// onde lançar gasto e onde ficam os avisos.
///
/// Palavras do Gabriel: *"onboarding é dps q eu respondi tudo oq vai me
/// ensinar a usar o app"*.
///
/// Vem por cima da tela real, não por cima de um desenho dela: a pessoa
/// aprende olhando o próprio número, não um exemplo.
class PrimeiraVez extends StatefulWidget {
  const PrimeiraVez({
    super.key,
    required this.aoTerminar,
    this.passos = passosPadrao,
  });

  final VoidCallback aoTerminar;
  final List<PassoDaPrimeiraVez> passos;

  static const passosPadrao = [
    PassoDaPrimeiraVez(
      rotulo: '1 DE 3 · ESSE NÚMERO',
      titulo: 'é quanto dá pra gastar hoje sem atrasar a quitação',
      texto: 'a gente pega o que entra, tira as parcelas e as contas '
          'fixas, e divide o resto pelos dias que faltam. '
          'ele muda todo dia.',
      alinhamento: Alignment.center,
      rodape: 'depois eu te mostro o botão de lançar e onde ficam '
          'seus avisos.',
    ),
    PassoDaPrimeiraVez(
      rotulo: '2 DE 3 · O BOTÃO DO MEIO',
      titulo: 'é aqui que você me conta o que gastou',
      texto: 'leva 5 segundos. quanto mais você lança, mais o número '
          'em cima fica com a sua cara.',
      // Embaixo fica o botão de lançar: o balão sobe para não cobri-lo.
      alinhamento: Alignment.topCenter,
      rodape: 'não precisa lançar tudo. o que você lembrar já ajuda.',
    ),
    PassoDaPrimeiraVez(
      rotulo: '3 DE 3 · O HISTÓRICO',
      titulo: 'aqui você vê o mês inteiro, dia a dia',
      texto: 'o que podia gastar, o que gastou e como fica o saldo. '
          'dá pra ver os meses à frente e o ano todo.',
      alinhamento: Alignment.center,
    ),
  ];

  @override
  State<PrimeiraVez> createState() => _PrimeiraVezState();
}

class _PrimeiraVezState extends State<PrimeiraVez> {
  int _passo = 0;

  void _avancar() {
    if (_passo + 1 >= widget.passos.length) {
      widget.aoTerminar();
      return;
    }
    setState(() => _passo++);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.passos[_passo];

    return Material(
      // Véu escuro sobre o Início já preenchido: a pessoa aprende olhando
      // o próprio número, não um exemplo inventado.
      color: const Color(0xB31C1917),
      child: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: p.alinhamento,
              child: Padding(
                padding: const EdgeInsets.all(Medidas.margem),
                child: _Balao(
                  passo: p,
                  indice: _passo,
                  total: widget.passos.length,
                  aoEntendi: _avancar,
                  aoPular: widget.aoTerminar,
                ),
              ),
            ),
            if (p.rodape != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Medidas.margem, 0, Medidas.margem, Medidas.espacoGrande),
                  child: _FalaDoJoao(texto: p.rodape!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Balao extends StatelessWidget {
  const _Balao({
    required this.passo,
    required this.indice,
    required this.total,
    required this.aoEntendi,
    required this.aoPular,
  });

  final PassoDaPrimeiraVez passo;
  final int indice;
  final int total;
  final VoidCallback aoEntendi;
  final VoidCallback aoPular;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Cores.creme,
        borderRadius: BorderRadius.circular(Medidas.raioCartao),
        boxShadow: Medidas.sombraCartao,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(passo.rotulo, style: Tipo.rotulo.copyWith(color: Cores.barro)),
          const SizedBox(height: 10),
          Text(passo.titulo, style: Tipo.titulo),
          const SizedBox(height: 8),
          Text(
            passo.texto,
            style: Tipo.corpo.copyWith(color: Cores.apoio),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: aoEntendi,
                  style: FilledButton.styleFrom(
                    backgroundColor: Cores.tinta,
                    foregroundColor: Cores.creme,
                    minimumSize: const Size.fromHeight(Medidas.alvoMinimo),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Medidas.raioPilula),
                    ),
                  ),
                  child: Text(
                    indice + 1 == total ? 'entendi' : 'entendi',
                    style: Tipo.corpoForte.copyWith(color: Cores.creme),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // "pular" sempre visível: nada pode prender a pessoa. É
              // regra do design system, não conveniência.
              Semantics(
                button: true,
                child: GestureDetector(
                  onTap: aoPular,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: Medidas.alvoMinimo,
                      minWidth: Medidas.alvoMinimo,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'pular',
                      style: Tipo.corpoForte.copyWith(color: Cores.apoio),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Container(
                  width: i == indice ? 22 : 8,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == indice ? Cores.tinta : Cores.bege,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FalaDoJoao extends StatelessWidget {
  const _FalaDoJoao({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Cores.barroClaro,
        borderRadius: BorderRadius.circular(Medidas.raioCartao),
        border: Border.all(color: Cores.borda, width: 1.5),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/joao.png',
            height: 44,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: Tipo.corpoMiudo.copyWith(color: Cores.barro),
            ),
          ),
        ],
      ),
    );
  }
}
