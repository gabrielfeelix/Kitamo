import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/divida.dart';
import '../../models/lancamento_registro.dart';
import '../../models/perfil_financeiro.dart';
import '../../repositories/lancamento_repository.dart';
import '../backup/backup_service.dart';
import '../chat/chat_page.dart';
import '../inicio/inicio_page.dart';
import '../lancamentos/lancamentos_page.dart';
import '../lancamentos/lancar_sheet.dart';
import '../perfil/perfil_page.dart';
import '../seguranca/bloqueio_service.dart';

/// A casca com a navegação: Início · Lançamentos · [+] · Perfil.
///
/// O `+` fica no centro, preto e redondo — flutuando por cima, não como
/// item da barra.
class Casca extends StatefulWidget {
  const Casca({
    super.key,
    required this.perfil,
    required this.dividas,
    required this.lancamentos,
    required this.backup,
    required this.bloqueio,
    this.aoQuitar,
    this.aoSalvarDivida,
  });

  final PerfilFinanceiro? perfil;
  final List<Divida> dividas;
  final LancamentoRepository lancamentos;
  final BackupService backup;
  final BloqueioService bloqueio;
  final void Function(Divida)? aoQuitar;
  final Future<void> Function(Divida)? aoSalvarDivida;

  @override
  State<Casca> createState() => _CascaState();
}

class _CascaState extends State<Casca> {
  int _aba = 0;

  Future<void> _lancar() async {
    final tipo = await showModalBottomSheet<TipoLancamento>(
      context: context,
      backgroundColor: Cores.creme,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(Medidas.raioCartao)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Medidas.espaco),
            ListTile(
              title: Text('Gastei', style: Tipo.subtitulo),
              onTap: () => Navigator.pop(context, TipoLancamento.gasto),
            ),
            ListTile(
              title: Text('Recebi', style: Tipo.subtitulo),
              onTap: () => Navigator.pop(context, TipoLancamento.entrada),
            ),
            const SizedBox(height: Medidas.espaco),
          ],
        ),
      ),
    );

    if (tipo == null || !mounted) return;

    final novo = await LancarSheet.abrir(context, tipo);
    if (novo != null) await widget.lancamentos.salvar(novo);
  }

  @override
  Widget build(BuildContext context) {
    final telas = [
      InicioPage(
        perfil: widget.perfil,
        dividas: widget.dividas,
        aoQuitar: widget.aoQuitar,
      ),
      LancamentosPage(repositorio: widget.lancamentos),
      ChatPage(perfil: widget.perfil, dividas: widget.dividas),
      PerfilPage(
        dividas: widget.dividas,
        backup: widget.backup,
        bloqueio: widget.bloqueio,
        aoSalvarDivida: widget.aoSalvarDivida,
      ),
    ];

    return Scaffold(
      backgroundColor: Cores.creme,
      body: IndexedStack(index: _aba, children: telas),
      floatingActionButton: FloatingActionButton(
        onPressed: _lancar,
        backgroundColor: Cores.tinta,
        foregroundColor: Cores.branco,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Cores.branco,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Item(
              icone: Icons.home_outlined,
              rotulo: 'Início',
              ativo: _aba == 0,
              aoTocar: () => setState(() => _aba = 0),
            ),
            _Item(
              icone: Icons.receipt_long_outlined,
              rotulo: 'Lançamentos',
              ativo: _aba == 1,
              aoTocar: () => setState(() => _aba = 1),
            ),
            const SizedBox(width: 48), // espaço do +
            _Item(
              icone: Icons.chat_bubble_outline,
              rotulo: 'Chat',
              ativo: _aba == 2,
              aoTocar: () => setState(() => _aba = 2),
            ),
            _Item(
              icone: Icons.person_outline,
              rotulo: 'Perfil',
              ativo: _aba == 3,
              aoTocar: () => setState(() => _aba = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icone,
    required this.rotulo,
    required this.ativo,
    required this.aoTocar,
  });

  final IconData icone;
  final String rotulo;
  final bool ativo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final cor = ativo ? Cores.teal : Cores.apoio;

    return Semantics(
      button: true,
      selected: ativo,
      label: rotulo,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, color: cor, size: 24),
              const SizedBox(height: 2),
              Text(rotulo,
                  style: Tipo.rotulo.copyWith(color: cor, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
