import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/divida.dart';
import '../../models/perfil_financeiro.dart';
import 'respostas.dart';

class _Balao {
  const _Balao(this.texto, {required this.daKitamo});
  final String texto;
  final bool daKitamo;
}

/// O chat. Conversa, não formulário.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.perfil, required this.dividas});

  final PerfilFinanceiro? perfil;
  final List<Divida> dividas;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _conversa = <_Balao>[];
  final _rolagem = ScrollController();

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  void _perguntar(Pergunta p) {
    setState(() {
      _conversa.add(_Balao(p.texto, daKitamo: false));
      _conversa.add(_Balao(
        const Respostas().responder(
          p.chave,
          perfil: widget.perfil,
          dividas: widget.dividas,
        ),
        daKitamo: true,
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_rolagem.hasClients) {
        _rolagem.animateTo(
          _rolagem.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Cores.creme,
        appBar: AppBar(
          backgroundColor: Cores.tealEscuro,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Cores.branco,
          title: Row(
            children: [
              // O bicho inteiro, não o close do rosto: o joao-avatar.png
              // é um recorte de 330px na cabeça, e esticado vira zoom
              // estranho. Foi o Gabriel que pegou, em 07/09.
              CircleAvatar(
                radius: 16,
                backgroundColor: Cores.branco,
                backgroundImage: const AssetImage('assets/images/joao.png'),
              ),
              const SizedBox(width: 10),
              Text('Kitamo',
                  style: Tipo.subtitulo.copyWith(color: Cores.branco)),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _conversa.isEmpty
                  ? _Inicio(nome: widget.perfil?.nome, aoTocar: _perguntar)
                  : ListView.builder(
                      controller: _rolagem,
                      padding: const EdgeInsets.all(Medidas.margem),
                      itemCount: _conversa.length,
                      itemBuilder: (_, i) => _BalaoWidget(balao: _conversa[i]),
                    ),
            ),
            _Sugestoes(aoTocar: _perguntar),
          ],
        ),
      );
}

/// O chat abria com "pergunta aí" e uma caixa vazia: quem chega não
/// descobre sozinho que ele sabe responder, e caixa de texto em branco
/// ninguém digita.
///
/// Agora ele começa falando, e as perguntas que ele sabe responder ficam
/// à vista, não só na tirinha do rodapé.
class _Inicio extends StatelessWidget {
  const _Inicio({required this.nome, required this.aoTocar});

  final String? nome;
  final void Function(Pergunta) aoTocar;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(Medidas.margem),
        children: [
          const SizedBox(height: Medidas.espaco),
          Center(
            child: Image.asset(
              // O bicho inteiro (897x937), não o recorte da cabeça.
              'assets/images/joao.png',
              height: 132,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: Medidas.espacoGrande),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Cores.barroClaro,
              borderRadius: BorderRadius.circular(Medidas.raioCartao),
              border: Border.all(color: Cores.borda, width: 1.5),
            ),
            child: Text(
              nome == null
                  ? 'oi. eu sei os seus números de cor. '
                      'pode perguntar do seu diário, das parcelas '
                      'ou de quanto ainda falta.'
                  : 'oi, $nome. eu sei os seus números de cor. '
                      'pode perguntar do seu diário, das parcelas '
                      'ou de quanto ainda falta.',
              style: Tipo.corpo.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: Medidas.espacoGrande),
          Text('O QUE EU SEI RESPONDER', style: Tipo.rotulo),
          const SizedBox(height: Medidas.espaco),
          for (final p in Respostas.sugestoes) ...[
            _PerguntaPronta(pergunta: p, aoTocar: () => aoTocar(p)),
            const SizedBox(height: 8),
          ],
        ],
      );
}

class _PerguntaPronta extends StatelessWidget {
  const _PerguntaPronta({required this.pergunta, required this.aoTocar});

  final Pergunta pergunta;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: aoTocar,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: Cores.branco,
            borderRadius: BorderRadius.circular(Medidas.raioLinha),
            boxShadow: Medidas.sombraCartao,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(pergunta.texto, style: Tipo.corpoForte),
              ),
              const Icon(Icons.chevron_right, size: 20, color: Cores.apoio),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalaoWidget extends StatelessWidget {
  const _BalaoWidget({required this.balao});

  final _Balao balao;

  @override
  Widget build(BuildContext context) => Align(
        alignment:
            balao.daKitamo ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: Medidas.espaco),
          padding: const EdgeInsets.all(14),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          decoration: BoxDecoration(
            color: balao.daKitamo ? Cores.barroClaro : Cores.branco,
            borderRadius: BorderRadius.circular(Medidas.raioInterno),
            border: balao.daKitamo
                ? Border.all(color: Cores.borda)
                : null,
          ),
          child: Text(balao.texto, style: Tipo.corpo),
        ),
      );
}

class _Sugestoes extends StatelessWidget {
  const _Sugestoes({required this.aoTocar});

  final void Function(Pergunta) aoTocar;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Medidas.margem),
            children: [
              for (final p in Respostas.sugestoes)
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: ActionChip(
                    label: Text(p.texto, style: Tipo.apoio),
                    onPressed: () => aoTocar(p),
                    backgroundColor: Cores.branco,
                    side: const BorderSide(color: Cores.bege),
                  ),
                ),
            ],
          ),
        ),
      );
}
