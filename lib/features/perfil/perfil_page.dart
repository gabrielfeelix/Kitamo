import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/divida.dart';
import '../backup/backup_service.dart';
import '../dividas/editar_divida_page.dart';
import '../seguranca/bloqueio_service.dart';

/// Perfil. Sem tela intermediária de "configurações": o perfil já é a
/// lista, agrupada por assunto.
class PerfilPage extends StatefulWidget {
  const PerfilPage({
    super.key,
    required this.dividas,
    required this.backup,
    required this.bloqueio,
    this.aoSalvarDivida,
  });

  final List<Divida> dividas;
  final BackupService backup;
  final BloqueioService bloqueio;

  /// Null deixa o cadastro indisponível (usado em teste de tela).
  final Future<void> Function(Divida)? aoSalvarDivida;

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool _bloqueioAtivo = false;
  bool _bloqueioDisponivel = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final ativo = await widget.bloqueio.estaAtivo();
    final disponivel = await widget.bloqueio.disponivel();
    if (mounted) {
      setState(() {
        _bloqueioAtivo = ativo;
        _bloqueioDisponivel = disponivel;
      });
    }
  }

  Future<void> _alternarBloqueio(bool ligar) async {
    if (ligar) {
      final ok = await widget.bloqueio.ativar();
      if (!mounted) return;
      if (!ok) {
        _avisar('Não deu pra confirmar. O bloqueio continua desligado.');
        return;
      }
    } else {
      await widget.bloqueio.desativar();
    }
    if (mounted) setState(() => _bloqueioAtivo = ligar);
  }

  Future<void> _exportar() async {
    final conteudo = await widget.backup.exportar();
    if (!mounted) return;

    await Clipboard.setData(ClipboardData(text: conteudo));
    if (!mounted) return;

    _avisar('Backup copiado. ${BackupService.avisoDeExportacao}');
  }

  Future<void> _editarDivida([Divida? original]) async {
    final salvar = widget.aoSalvarDivida;
    if (salvar == null) return;

    final nova = await EditarDividaPage.abrir(context, original: original);
    if (nova != null) await salvar(nova);
  }

  void _avisar(String texto) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(texto, style: Tipo.corpo)));

  @override
  Widget build(BuildContext context) {
    final abertas = widget.dividas.where((d) => !d.estaQuitada).toList();
    final faltam = abertas.fold<int>(0, (s, d) => s + d.parcelasRestantes);

    return Scaffold(
      backgroundColor: Cores.creme,
      appBar: AppBar(
        backgroundColor: Cores.creme,
        surfaceTintColor: Colors.transparent,
        title: Text('Perfil', style: Tipo.subtitulo),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Medidas.margem),
        children: [
          if (faltam > 0)
            Container(
              padding: const EdgeInsets.all(Medidas.margem),
              decoration: BoxDecoration(
                color: Cores.barroClaro,
                borderRadius: BorderRadius.circular(Medidas.raioCartao),
              ),
              child: Text(
                'faltam $faltam ${faltam == 1 ? 'parcela' : 'parcelas'}',
                style: Tipo.corpoForte.copyWith(color: Cores.barro),
              ),
            ),

          const _Grupo('Minha dívida'),
          for (final d in abertas)
            _Linha(
              titulo: d.nome,
              apoio: '${d.parcelasPagas} de ${d.parcelasTotal} · '
                  'vence dia ${d.diaVencimento}',
              aoTocar: widget.aoSalvarDivida == null
                  ? null
                  : () => _editarDivida(d),
            ),
          if (abertas.isEmpty)
            const _Linha(titulo: 'Nenhuma dívida', apoio: 'você está livre'),
          if (widget.aoSalvarDivida != null)
            _Linha(
              titulo: '+ Nova dívida',
              apoio: 'cartão, empréstimo, crediário',
              aoTocar: _editarDivida,
            ),

          const _Grupo('Dados'),
          _Linha(
            titulo: 'Exportar backup',
            apoio: 'copia seus dados para você guardar',
            aoTocar: _exportar,
          ),

          const _Grupo('Segurança'),
          if (_bloqueioDisponivel)
            SwitchListTile(
              value: _bloqueioAtivo,
              onChanged: _alternarBloqueio,
              activeThumbColor: Cores.teal,
              title: Text('Pedir biometria ao abrir', style: Tipo.corpoForte),
              subtitle: Text(
                'protege suas dívidas se alguém pegar seu celular',
                style: Tipo.apoio,
              ),
            )
          else
            const _Linha(
              titulo: 'Bloqueio indisponível',
              apoio: 'este aparelho não tem biometria configurada',
            ),
        ],
      ),
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo(this.titulo);

  final String titulo;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
          top: Medidas.espacoGrande,
          bottom: Medidas.espaco,
        ),
        child: Text(
          titulo.toUpperCase(),
          style: Tipo.rotulo.copyWith(color: Cores.apoio),
        ),
      );
}

class _Linha extends StatelessWidget {
  const _Linha({required this.titulo, required this.apoio, this.aoTocar});

  final String titulo;
  final String apoio;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(Medidas.raioInterno),
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: Cores.branco,
            borderRadius: BorderRadius.circular(Medidas.raioInterno),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: Tipo.corpoForte),
                    Text(apoio, style: Tipo.apoio),
                  ],
                ),
              ),
              if (aoTocar != null)
                const Icon(Icons.chevron_right, color: Cores.apoio),
            ],
          ),
        ),
      );
}
