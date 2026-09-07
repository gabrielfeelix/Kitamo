import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../widgets/barra_de_navegacao.dart';
import '../../models/divida.dart';
import '../../models/lancamento_registro.dart';
import '../../models/perfil_financeiro.dart';
import '../../repositories/lancamento_repository.dart';
import '../backup/backup_service.dart';
import '../chat/chat_page.dart';
import '../inicio/inicio_page.dart';
import '../primeira_vez/primeira_vez.dart';
import '../horizonte/horizonte_page.dart';
import '../lancamentos/lancamentos_page.dart';
import '../lancamentos/lancar_sheet.dart';
import '../perfil/perfil_page.dart';
import '../seguranca/bloqueio_service.dart';

/// A casca com a navegação do design:
/// **Início · Lançamentos · falar(joão) · Lançar · Perfil**.
///
/// O joão no centro é a ação principal — falar com a Kitamo. Antes daqui
/// existia um `+` preto no centro e o chat escondido como quarta aba, o
/// que invertia a prioridade: a Kitamo é uma conversa, não um formulário.
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
    this.aoSalvarPerfil,
    this.ensinarAUsar = false,
    this.aoTerminarDeEnsinar,
  });

  final PerfilFinanceiro? perfil;
  final List<Divida> dividas;
  final LancamentoRepository lancamentos;
  final BackupService backup;
  final BloqueioService bloqueio;
  final void Function(Divida)? aoQuitar;
  final Future<void> Function(Divida)? aoSalvarDivida;

  /// Grava nome e passarinho vindos de "Editar perfil". Null deixa a
  /// edição indisponível, o que serve para teste de tela.
  final Future<void> Function(PerfilFinanceiro)? aoSalvarPerfil;

  /// true na primeira vez que a pessoa chega no app depois de responder
  /// tudo: mostra a #32 por cima do Início já preenchido.
  final bool ensinarAUsar;

  /// Chamado quando ela termina ou pula, para não mostrar de novo.
  final VoidCallback? aoTerminarDeEnsinar;

  @override
  State<Casca> createState() => _CascaState();
}

class _CascaState extends State<Casca> {
  int _aba = 0;
  List<LancamentoRegistro> _deHoje = const [];
  late bool _ensinando = widget.ensinarAUsar;

  @override
  void initState() {
    super.initState();
    _carregarHoje();
  }

  Future<void> _carregarHoje() async {
    final todos = await widget.lancamentos.listar();
    if (mounted) setState(() => _deHoje = todos);
  }

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
    if (novo != null) {
      await widget.lancamentos.salvar(novo);
      await _carregarHoje();
    }
  }

  @override
  Widget build(BuildContext context) {
    final telas = [
      InicioPage(
        perfil: widget.perfil,
        dividas: widget.dividas,
        aoQuitar: widget.aoQuitar,
        lancamentosDeHoje: _deHoje,
        aoAbrirPerfil: () => _trocar(AbaDaKitamo.perfil),
        aoAbrirHistorico: () => _trocar(AbaDaKitamo.historico),
      ),
      // A segunda aba é o histórico. Os lançamentos soltos ficam a um
      // toque de dentro dele, no lugar de disputar a barra.
      HorizontePage(
        perfil: widget.perfil,
        dividas: widget.dividas,
        lancamentos: _deHoje,
        semVoltar: true,
        aoVerLancamentos: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LancamentosPage(repositorio: widget.lancamentos),
        )),
      ),
      ChatPage(perfil: widget.perfil, dividas: widget.dividas),
      PerfilPage(
        perfil: widget.perfil,
        dividas: widget.dividas,
        backup: widget.backup,
        bloqueio: widget.bloqueio,
        aoSalvarDivida: widget.aoSalvarDivida,
        aoSalvarPerfil: widget.aoSalvarPerfil,
      ),
    ];

    final app = Scaffold(
      backgroundColor: Cores.creme,
      body: IndexedStack(index: _aba, children: telas),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BarraDeNavegacao(
          ativa: _abaAtual,
          aoTrocar: _trocar,
        ),
      ),
    );

    if (!_ensinando) return app;

    // O véu vai POR CIMA do app de verdade, não de um desenho dele: a
    // pessoa aprende olhando o próprio número.
    return Stack(
      children: [
        app,
        PrimeiraVez(
          aoTerminar: () {
            setState(() => _ensinando = false);
            widget.aoTerminarDeEnsinar?.call();
          },
        ),
      ],
    );
  }

  /// "Lançar" não é tela: abre a folha por cima e a aba não muda.
  AbaDaKitamo get _abaAtual => switch (_aba) {
        0 => AbaDaKitamo.inicio,
        1 => AbaDaKitamo.historico,
        2 => AbaDaKitamo.chat,
        _ => AbaDaKitamo.perfil,
      };

  void _trocar(AbaDaKitamo aba) {
    if (aba == AbaDaKitamo.lancar) {
      _lancar();
      return;
    }
    setState(() => _aba = switch (aba) {
          AbaDaKitamo.inicio => 0,
          AbaDaKitamo.historico => 1,
          AbaDaKitamo.chat => 2,
          AbaDaKitamo.perfil => 3,
          AbaDaKitamo.lancar => _aba,
        });
  }
}
