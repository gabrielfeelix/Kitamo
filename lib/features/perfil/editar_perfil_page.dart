import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/perfil_financeiro.dart';
import '../../widgets/listas.dart';
import '../../widgets/topo_de_tela.dart';

/// "Editar perfil" (#24) do Kitamo App.dc.html.
///
/// Na ordem do design: o passarinho grande de 96px com borda branca, o
/// campo do nome com rótulo mono e a linha teal, o acervo de 8 passarinhos
/// em grade de 4 colunas com o escolhido marcado, as duas linhas de leitura
/// e o "salvar" colado no rodapé.
///
/// Não há backend. O que muda aqui é gravado no banco local cifrado, e é
/// só isso — decisão do Gabriel em 07/09/2026.
class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({
    super.key,
    required this.perfil,
    required this.aoSalvar,
  });

  final PerfilFinanceiro perfil;

  /// Devolve o perfil já com nome e passarinho novos.
  final Future<void> Function(PerfilFinanceiro) aoSalvar;

  /// Abre a tela e volta true quando salvou.
  static Future<bool?> abrir(
    BuildContext context, {
    required PerfilFinanceiro perfil,
    required Future<void> Function(PerfilFinanceiro) aoSalvar,
  }) =>
      Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => EditarPerfilPage(perfil: perfil, aoSalvar: aoSalvar),
        ),
      );

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  late final TextEditingController _nome =
      TextEditingController(text: widget.perfil.nome ?? '');
  late String _avatar = widget.perfil.avatarOuPadrao;
  bool _salvando = false;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_salvando) return;
    setState(() => _salvando = true);

    final limpo = _nome.text.trim();
    await widget.aoSalvar(widget.perfil.copyWith(
      // Nome em branco volta a ser nulo: aí o cabeçalho diz só "bom dia",
      // que é melhor do que "bom dia, " com vírgula solta.
      nome: limpo.isEmpty ? null : limpo,
      limparNome: limpo.isEmpty,
      avatar: _avatar,
    ));

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.perfil;

    return Scaffold(
      backgroundColor: Cores.creme,
      body: SafeArea(
        child: Column(
          children: [
            TopoDeTela(titulo: 'editar perfil'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Medidas.margem,
                  0,
                  Medidas.margem,
                  Medidas.rodape,
                ),
                children: [
                  _RetratoGrande(avatar: _avatar),
                  const SizedBox(height: 14),
                  _CampoDoNome(controlador: _nome),
                  const SizedBox(height: 16),
                  const _RotuloMiudo('O ACERVO DO JOÃO'),
                  const SizedBox(height: 10),
                  _AcervoDeAvatares(
                    escolhido: _avatar,
                    aoEscolher: (a) => setState(() => _avatar = a),
                  ),
                  const SizedBox(height: 14),
                  GrupoDeLinhas(
                    linhas: [
                      LinhaDeLista(
                        titulo: 'e-mail',
                        valor: p.email ?? 'sem conta',
                        temSeta: false,
                        alturaVertical: 14,
                      ),
                      LinhaDeLista(
                        titulo: 'dia que o dinheiro entra',
                        valor: p.diaRenda == null
                            ? 'não definido'
                            : 'todo dia ${p.diaRenda}',
                        temSeta: false,
                        alturaVertical: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _BotaoSalvar(aoTocar: _salvando ? null : _salvar),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// O passarinho de 96px com borda branca de 3px e sombra, e o atalho teal
/// logo abaixo.
class _RetratoGrande extends StatelessWidget {
  const _RetratoGrande({required this.avatar});

  final String avatar;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Cores.branco, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x245C2E1A),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/$avatar.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'escolher outro passarinho',
            style: Tipo.corpoMiudo.copyWith(
              fontWeight: FontWeight.w600,
              color: Cores.teal,
            ),
          ),
        ],
      );
}

/// "COMO A GENTE TE CHAMA": cartão branco, rótulo mono, o nome em 17/600
/// sobre a linha bege de 2px.
class _CampoDoNome extends StatelessWidget {
  const _CampoDoNome({required this.controlador});

  final TextEditingController controlador;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: Cores.branco,
          borderRadius: BorderRadius.circular(Medidas.raioCartao),
          boxShadow: Medidas.sombraCartao,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _RotuloMiudo('COMO A GENTE TE CHAMA'),
            const SizedBox(height: 5),
            TextField(
              controller: controlador,
              textCapitalization: TextCapitalization.words,
              maxLength: 60,
              style: Tipo.valor,
              cursorColor: Cores.teal,
              cursorWidth: 2,
              decoration: const InputDecoration(
                isDense: true,
                counterText: '',
                hintText: 'seu nome',
                contentPadding: EdgeInsets.only(bottom: 8),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Cores.bege, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Cores.teal, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text('é o nome que aparece no bom dia', style: Tipo.apoio),
          ],
        ),
      );
}

/// A grade de 4 colunas com os 8 passarinhos. O escolhido ganha contorno
/// teal e o selo de confirmação no canto.
class _AcervoDeAvatares extends StatelessWidget {
  const _AcervoDeAvatares({
    required this.escolhido,
    required this.aoEscolher,
  });

  final String escolhido;
  final ValueChanged<String> aoEscolher;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final a in PerfilFinanceiro.avatares)
            _Passarinho(
              avatar: a,
              marcado: a == escolhido,
              aoTocar: () => aoEscolher(a),
            ),
        ],
      );
}

class _Passarinho extends StatelessWidget {
  const _Passarinho({
    required this.avatar,
    required this.marcado,
    required this.aoTocar,
  });

  final String avatar;
  final bool marcado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: marcado,
      label: 'passarinho ${avatar.replaceAll('av-', '')}',
      child: GestureDetector(
        onTap: aoTocar,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: marcado
                    ? Border.all(color: Cores.teal, width: 3)
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/$avatar.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            if (marcado)
              Positioned(
                right: -3,
                bottom: -3,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Cores.teal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Cores.creme, width: 2.5),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 13,
                    color: Cores.branco,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// O "salvar" do design: preto, 50px, raio total.
class _BotaoSalvar extends StatelessWidget {
  const _BotaoSalvar({this.aoTocar});

  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        width: double.infinity,
        child: FilledButton(
          onPressed: aoTocar,
          style: FilledButton.styleFrom(
            backgroundColor: Cores.tinta,
            foregroundColor: Cores.creme,
            disabledBackgroundColor: Cores.bege,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Medidas.raioPilula),
            ),
          ),
          child: Text(
            'salvar',
            style: Tipo.corpoForte.copyWith(color: Cores.creme),
          ),
        ),
      );
}

/// O rótulo mono desta tela. O design pede 10.5px aqui, meio ponto abaixo
/// do Rotulo de pecas.dart, que vale 11 no resto do app.
class _RotuloMiudo extends StatelessWidget {
  const _RotuloMiudo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: Tipo.rotulo.copyWith(fontSize: 10.5, color: Cores.apoio),
      );
}
