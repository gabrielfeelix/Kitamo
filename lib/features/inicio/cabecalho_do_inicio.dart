import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';

/// O cabeçalho da tela de Início, montado a partir do markup da tela
/// "INÍCIO · DIA TRANQUILO" do Kitamo App.dc.html.
///
/// A anatomia é do design, na ordem: saudação e data, sino com ponto e
/// avatar, rótulo mono, número de 54, frase de até 255px, dois chips — e o
/// joão encostado no canto de baixo à direita, **dentro** do cabeçalho.
/// Ele nunca fica solto no meio da tela.
class CabecalhoDoInicio extends StatelessWidget {
  const CabecalhoDoInicio({
    super.key,
    required this.estado,
    required this.rotulo,
    required this.numero,
    required this.frase,
    required this.chipSecundario,
    required this.nome,
    this.temAviso = false,
    this.aoTocarAvisos,
    this.aoTocarPerfil,
  });

  final CabecalhoDoDia estado;
  final String rotulo;
  final String numero;
  final String frase;
  final String chipSecundario;
  final String nome;
  final bool temAviso;
  final VoidCallback? aoTocarAvisos;
  final VoidCallback? aoTocarPerfil;

  @override
  Widget build(BuildContext context) {
    final topo = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: estado.fundo,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(Medidas.raioCabecalho),
        ),
      ),
      // O joão vaza um pouco para baixo no design (bottom:-4), mas aqui ele
      // fica contido: cortar o bico do bicho é pior que 4px de diferença.
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, topo + 8, 24, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _saudacao(context),
                const SizedBox(height: 22),
                Text(
                  rotulo.toUpperCase(),
                  style: Tipo.rotulo.copyWith(
                    color: estado.tinta,
                    letterSpacing: 11 * 0.12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  numero,
                  style: Tipo.display.copyWith(color: estado.tinta),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 255),
                  child: Text(
                    frase,
                    style: Tipo.corpo.copyWith(
                      color: estado.tinta,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _Chip(
                      texto: 'hoje',
                      fundo: estado.chipFundo,
                      tinta: estado.chipTinta,
                      peso: FontWeight.w700,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _Chip(
                        texto: chipSecundario,
                        fundo: estado.veu,
                        tinta: estado.tinta,
                        peso: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (estado.mostraPersonagem)
            Positioned(
              right: 10,
              bottom: 0,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/images/joao.png',
                  height: 126,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// "bom dia, Gabriel" e a data por extenso. O design abre a tela
  /// chamando a pessoa pelo nome — o app não fazia isso.
  Widget _saudacao(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nome.isEmpty ? saudacaoDaHora() : '${saudacaoDaHora()}, $nome',
                style: Tipo.corpo.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: estado.tintaFraca,
                ),
              ),
              Text(
                dataPorExtenso(),
                style: Tipo.apoio.copyWith(color: estado.tintaFraca),
              ),
            ],
          ),
        ),
        _Sino(
          estado: estado,
          temAviso: temAviso,
          aoTocar: aoTocarAvisos,
        ),
        const SizedBox(width: 12),
        Semantics(
          button: aoTocarPerfil != null,
          label: 'perfil',
          child: GestureDetector(
            onTap: aoTocarPerfil,
            child: ClipOval(
              child: Image.asset(
                'assets/images/joao-avatar-2.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "bom dia" / "boa tarde" / "boa noite" — minúsculo, como manda a voz.
String saudacaoDaHora([DateTime? agora]) {
  final h = (agora ?? DateTime.now()).hour;
  if (h < 12) return 'bom dia';
  if (h < 18) return 'boa tarde';
  return 'boa noite';
}

/// "quarta, 6 de setembro"
///
/// Escrito na mão em vez de depender de `DateFormat('EEEE', 'pt_BR')`: o
/// locale só existe depois de `initializeDateFormatting`, e um cabeçalho
/// que lança porque ninguém inicializou o intl derruba a tela inteira. A
/// data é fixa em português — não há o que traduzir.
String dataPorExtenso([DateTime? agora]) {
  final d = agora ?? DateTime.now();
  return '${_diasDaSemana[d.weekday - 1]}, ${d.day} de ${_meses[d.month - 1]}';
}

const _diasDaSemana = [
  'segunda',
  'terça',
  'quarta',
  'quinta',
  'sexta',
  'sábado',
  'domingo',
];

const _meses = [
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
];

/// Sino de 40px com ponto vermelho de 9px, borda branca, quando há aviso.
class _Sino extends StatelessWidget {
  const _Sino({required this.estado, required this.temAviso, this.aoTocar});

  final CabecalhoDoDia estado;
  final bool temAviso;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: temAviso ? 'avisos, há novidade' : 'avisos',
      child: GestureDetector(
        onTap: aoTocar,
        // O sino desenhado tem 40px; o alvo de toque mínimo é 44.
        child: Container(
          width: Medidas.alvoMinimo,
          height: Medidas.alvoMinimo,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: estado.veu,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: estado.tinta,
                ),
                if (temAviso)
                  Positioned(
                    top: 7,
                    right: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Cores.vermelho,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Cores.branco, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.texto,
    required this.fundo,
    required this.tinta,
    required this.peso,
  });

  final String texto;
  final Color fundo;
  final Color tinta;
  final FontWeight peso;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(Medidas.raioPilula),
      ),
      child: Text(
        texto,
        overflow: TextOverflow.ellipsis,
        style: Tipo.chip.copyWith(color: tinta, fontWeight: peso),
      ),
    );
  }
}
