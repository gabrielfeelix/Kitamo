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
              CircleAvatar(
                radius: 16,
                backgroundColor: Cores.branco,
                backgroundImage:
                    const AssetImage('assets/images/joao-avatar.png'),
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
                  ? const _Inicio()
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

class _Inicio extends StatelessWidget {
  const _Inicio();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Medidas.margem),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/joao-avatar.png', height: 96),
              const SizedBox(height: Medidas.espaco),
              Text('pergunta aí', style: Tipo.subtitulo),
              const SizedBox(height: 4),
              Text(
                'eu falo do seu diário, das suas parcelas e de quanto falta',
                style: Tipo.apoio,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
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
