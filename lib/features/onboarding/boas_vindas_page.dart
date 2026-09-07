import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/tipografia.dart';
import '../../widgets/campos.dart';

/// "01 · BOAS-VINDAS" do Kitamo App.dc.html.
///
/// Fundo teal escuro, o joão grande centralizado, a promessa em Outfit 30,
/// e os dois botões. É a primeira coisa que a pessoa vê — antes desta tela
/// o app já pedia o cadastro de uma dívida, o que é a maior fonte de
/// abandono num app financeiro.
///
/// Sem rolagem: a ilustração cede o espaço que faltar (`Flexible` com
/// `FittedBox`), e os botões ficam sempre no mesmo lugar. Uma versão
/// anterior punha isto num `SingleChildScrollView` com `IntrinsicHeight` e
/// o "começar" ficava intocável no aparelho, mesmo passando nos testes.
class BoasVindasPage extends StatelessWidget {
  const BoasVindasPage({
    super.key,
    required this.aoComecar,
    this.aoEntrar,
  });

  final VoidCallback aoComecar;
  final VoidCallback? aoEntrar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.tealEscuro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // O joão manda no espaço que sobra, e encolhe se faltar.
              Flexible(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.asset(
                      'assets/images/joao.png',
                      height: 230,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'primeiro a gente quita,\ndepois a gente cresce.',
                style: Tipo.numero.copyWith(
                  fontSize: 30,
                  height: 1.18,
                  letterSpacing: -30 * 0.022,
                  color: Cores.creme,
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  'a gente monta seu plano em 90 segundos. '
                  'sem banco, sem planilha.',
                  style: Tipo.corpo.copyWith(
                    height: 1.6,
                    color: const Color(0xFFEAFBF7),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              BotaoSobreAcento(
                rotulo: 'começar',
                tinta: Cores.tinta,
                aoTocar: aoComecar,
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: aoEntrar,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    foregroundColor: Cores.creme,
                  ),
                  child: Text(
                    'já tenho conta',
                    style: Tipo.corpo.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Cores.creme,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
