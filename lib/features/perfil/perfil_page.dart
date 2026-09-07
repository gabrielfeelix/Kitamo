import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/divida.dart';
import '../../models/perfil_financeiro.dart';
import '../../widgets/listas.dart';
import '../../widgets/moeda.dart';
import '../../widgets/pecas.dart';
import '../backup/backup_service.dart';
import '../dividas/editar_divida_page.dart';
import '../seguranca/bloqueio_service.dart';
import 'editar_perfil_page.dart';

/// "Perfil" (#16) do Kitamo App.dc.html.
///
/// Montada na ordem do design: o cartão da pessoa com o passarinho e o selo
/// de lápis, o cartão de acento com a casa, "O QUE A GENTE ACOMPANHA" e
/// "AJUSTES" — cada grupo um cartão branco só, com as linhas divididas por
/// 1px, nunca um cartão por linha.
///
/// Sem tela intermediária de "configurações": o perfil já é a lista.
class PerfilPage extends StatefulWidget {
  const PerfilPage({
    super.key,
    required this.dividas,
    required this.backup,
    required this.bloqueio,
    this.perfil,
    this.aoSalvarDivida,
    this.aoSalvarPerfil,
  });

  final List<Divida> dividas;
  final BackupService backup;
  final BloqueioService bloqueio;

  final PerfilFinanceiro? perfil;

  /// Null deixa o cadastro indisponível (usado em teste de tela).
  final Future<void> Function(Divida)? aoSalvarDivida;

  /// Null deixa "editar perfil" indisponível.
  final Future<void> Function(PerfilFinanceiro)? aoSalvarPerfil;

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

  Future<void> _editarPerfil() async {
    final salvar = widget.aoSalvarPerfil;
    if (salvar == null) return;

    await EditarPerfilPage.abrir(
      context,
      perfil: widget.perfil ?? const PerfilFinanceiro(),
      aoSalvar: salvar,
    );
  }

  void _avisar(String texto) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(texto, style: Tipo.corpo)));

  @override
  Widget build(BuildContext context) {
    final abertas = widget.dividas.where((d) => !d.estaQuitada).toList();
    final devendo = abertas.fold<double>(0, (s, d) => s + d.saldoAtual);
    final total = abertas.fold<int>(0, (s, d) => s + d.parcelasTotal);
    final pagas = abertas.fold<int>(0, (s, d) => s + d.parcelasPagas);

    return Scaffold(
      backgroundColor: Cores.creme,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Medidas.margem,
            6,
            Medidas.margem,
            Medidas.rodapeComBarra,
          ),
          children: [
            _CartaoDaPessoa(
              perfil: widget.perfil,
              aoTocar: widget.aoSalvarPerfil == null ? null : _editarPerfil,
            ),
            const SizedBox(height: 14),
            if (total > 0) ...[
              _CartaoDaCasa(pagas: pagas, total: total),
              const SizedBox(height: 14),
            ],
            const Rotulo('O QUE A GENTE ACOMPANHA'),
            const SizedBox(height: 10),
            GrupoDeLinhas(
              linhas: [
                LinhaDeLista(
                  titulo: 'dívidas',
                  apoio: abertas.isEmpty
                      ? 'nenhuma aberta'
                      : '${abertas.length} '
                          '${abertas.length == 1 ? 'ativa' : 'ativas'} · '
                          '${dinheiro(devendo)}',
                  tile: const _TileDeIcone(
                    fundo: Color(0xFFFBEAE3),
                    icone: Icons.credit_card_rounded,
                    cor: Cores.barro,
                  ),
                  aoTocar: widget.aoSalvarDivida == null
                      ? null
                      : () => _abrirDividas(abertas),
                ),
                LinhaDeLista(
                  titulo: 'contas conectadas',
                  apoio: 'nenhuma ainda',
                  tile: const _TileDeIcone(
                    fundo: Color(0xFFF4EDFB),
                    icone: Icons.account_balance_rounded,
                    cor: Color(0xFF6B3FA0),
                  ),
                  aoTocar: () => _avisar(
                    'conectar banco ainda não está pronto.',
                  ),
                ),
                LinhaDeLista(
                  titulo: 'categorias',
                  apoio: 'as que a Kitamo já viu',
                  tile: const _TileDeIcone(
                    fundo: Color(0xFFE4F0E3),
                    icone: Icons.donut_small_rounded,
                    cor: Cores.verde,
                  ),
                  aoTocar: () => _avisar('categorias ainda não estão prontas.'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Rotulo('AJUSTES'),
            const SizedBox(height: 10),
            GrupoDeLinhas(
              linhas: [
                LinhaDeLista(
                  titulo: 'exportar backup',
                  valor: 'copia pra você guardar',
                  alturaVertical: 14,
                  aoTocar: _exportar,
                ),
                _LinhaDoBloqueio(
                  disponivel: _bloqueioDisponivel,
                  ativo: _bloqueioAtivo,
                  aoTrocar: _alternarBloqueio,
                ),
                LinhaDeLista(
                  titulo: 'sobre a Kitamo',
                  alturaVertical: 14,
                  aoTocar: () => _avisar(
                    'a Kitamo guarda tudo no seu aparelho, cifrado.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A lista de dívidas ainda não tem tela própria (#21 no TELAS.md). Até
  /// lá, tocar abre direto a edição da primeira, ou o cadastro se não
  /// houver nenhuma.
  void _abrirDividas(List<Divida> abertas) =>
      _editarDivida(abertas.isEmpty ? null : abertas.first);
}

/// O cartão de cima: passarinho de 58px com o selo de lápis, nome em Outfit
/// 21, e o convite teal pra editar.
class _CartaoDaPessoa extends StatelessWidget {
  const _CartaoDaPessoa({required this.perfil, this.aoTocar});

  final PerfilFinanceiro? perfil;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final p = perfil;
    final nome = (p?.nome?.trim().isNotEmpty ?? false) ? p!.nome! : 'você';

    return Cartao(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      aoTocar: aoTocar,
      child: Row(
        children: [
          _RetratoComSelo(avatar: p?.avatarOuPadrao ?? 'av-1'),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nome,
                  style: Tipo.titulo.copyWith(fontSize: 21),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  p?.provedor == null
                      ? 'sem conta, tudo neste aparelho'
                      : 'entrou com ${p!.provedor!.nome}',
                  style: Tipo.apoio.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (aoTocar != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'editar nome e foto',
                    style: Tipo.apoio.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Cores.teal,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (aoTocar != null) const SetaDeLinha(),
        ],
      ),
    );
  }
}

/// O passarinho de 58px com o selo preto de lápis encostado no canto.
class _RetratoComSelo extends StatelessWidget {
  const _RetratoComSelo({required this.avatar});

  final String avatar;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 62,
        height: 62,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFFDF1E2),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/$avatar.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Cores.tinta,
                  shape: BoxShape.circle,
                  border: Border.all(color: Cores.branco, width: 2.5),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 11,
                  color: Cores.branco,
                ),
              ),
            ),
          ],
        ),
      );
}

/// "SUA CASA" — o cartão de acento da tela, o único em barro. A casa cresce
/// conforme as parcelas caem: 5 fases, uma por quinto do caminho.
class _CartaoDaCasa extends StatelessWidget {
  const _CartaoDaCasa({required this.pagas, required this.total});

  final int pagas;
  final int total;

  /// A casa em 5 fases, do design system. Fase 5 é só de quem terminou.
  String get _casa {
    if (total <= 0) return 'casa-1';
    if (pagas >= total) return 'casa-5';
    final fase = (pagas * 5 / total).floor() + 1;
    return 'casa-${fase.clamp(1, 4)}';
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Cores.barro,
          borderRadius: BorderRadius.circular(Medidas.raioCartao),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SUA CASA',
                    style: Tipo.rotulo.copyWith(color: Cores.branco),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$pagas de $total parcelas',
                    style: Tipo.titulo.copyWith(color: Cores.creme),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _frase,
                    style: Tipo.corpoMiudo.copyWith(color: Cores.branco),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(
              'assets/images/$_casa.png',
              height: 76,
              fit: BoxFit.contain,
            ),
          ],
        ),
      );

  String get _frase {
    final faltam = total - pagas;
    if (faltam <= 0) return 'a casa está de pé';
    if (faltam <= 3) return 'falta pouco pra fechar o teto';
    return 'cada parcela levanta uma parede';
  }
}

/// A linha da biometria. É a única com chave em vez de seta: ligar ou
/// desligar acontece aqui mesmo, não em outra tela.
class _LinhaDoBloqueio extends StatelessWidget {
  const _LinhaDoBloqueio({
    required this.disponivel,
    required this.ativo,
    required this.aoTrocar,
  });

  final bool disponivel;
  final bool ativo;
  final ValueChanged<bool> aoTrocar;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'pedir biometria ao abrir',
                    style: Tipo.corpoForte.copyWith(fontSize: 14.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    disponivel
                        ? 'protege suas dívidas se alguém pegar seu celular'
                        : 'este aparelho não tem biometria configurada',
                    style: Tipo.apoio,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Chave(
              ligada: ativo,
              aoTrocar: disponivel ? aoTrocar : null,
              rotuloSemantico: 'pedir biometria ao abrir',
            ),
          ],
        ),
      );
}

/// O tile de 38px com ícone, nas cores que o design deu a cada assunto.
class _TileDeIcone extends StatelessWidget {
  const _TileDeIcone({
    required this.fundo,
    required this.icone,
    required this.cor,
  });

  final Color fundo;
  final IconData icone;
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Icon(icone, size: 20, color: cor),
      );
}
