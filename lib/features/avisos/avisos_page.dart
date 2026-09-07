import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import 'avisos.dart';

/// O sino. "Uma anatomia só": todo aviso tem o mesmo formato, muda a cor.
class AvisosPage extends StatelessWidget {
  const AvisosPage({super.key, required this.avisos});

  final List<Aviso> avisos;

  static Color _cor(TipoAviso t) => switch (t) {
        TipoAviso.vencimento => Cores.ambar,
        TipoAviso.descasamento => Cores.ambar,
        TipoAviso.conquista => Cores.barro,
        TipoAviso.aperto => Cores.vermelho,
      };

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Cores.creme,
        appBar: AppBar(
          backgroundColor: Cores.creme,
          surfaceTintColor: Colors.transparent,
          title: Text('Avisos', style: Tipo.subtitulo),
        ),
        body: avisos.isEmpty
            ? _Vazio()
            : ListView.builder(
                padding: const EdgeInsets.all(Medidas.margem),
                itemCount: avisos.length,
                itemBuilder: (_, i) => _Item(
                  aviso: avisos[i],
                  cor: _cor(avisos[i].tipo),
                ),
              ),
      );
}

class _Item extends StatelessWidget {
  const _Item({required this.aviso, required this.cor});

  final Aviso aviso;
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: Medidas.espaco),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Cores.branco,
          borderRadius: BorderRadius.circular(Medidas.raioInterno),
          border: Border(left: BorderSide(color: cor, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(aviso.titulo, style: Tipo.corpoForte),
            const SizedBox(height: 4),
            Text(aviso.detalhe, style: Tipo.apoio),
          ],
        ),
      );
}

class _Vazio extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/joao-avatar.png', height: 96),
            const SizedBox(height: Medidas.espaco),
            Text('só isso. Você está em dia.', style: Tipo.corpo),
          ],
        ),
      );
}
