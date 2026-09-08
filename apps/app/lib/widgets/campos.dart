import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/cores.dart';
import '../design/medidas.dart';
import '../design/tipografia.dart';

/// Seção "12 · CAMPOS" e "05 · CONTROLES E ESTADOS DE ESCOLHA" do design
/// system. As medidas são as do documento, não aproximações.

/// CAMPO DE VALOR — "o valor vem primeiro, sempre. Linha de 3px, cifrão em
/// cinza, cursor visível."
class CampoDeValor extends StatelessWidget {
  const CampoDeValor({
    super.key,
    required this.controlador,
    this.dica = '0,00',
    this.aoMudar,
    this.foco,
  });

  final TextEditingController controlador;
  final String dica;
  final ValueChanged<String>? aoMudar;
  final FocusNode? foco;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFDCD2C8), width: 3),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4, right: 6),
            child: Text(
              r'R$',
              style: Tipo.titulo.copyWith(color: Cores.apoio),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controlador,
              focusNode: foco,
              onChanged: aoMudar,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              cursorColor: Cores.tinta,
              cursorWidth: 2,
              cursorHeight: 30,
              style: Tipo.numero.copyWith(
                fontSize: 36,
                letterSpacing: -36 * 0.028,
                height: 1,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: dica,
                hintStyle: Tipo.numero.copyWith(
                  fontSize: 36,
                  height: 1,
                  color: const Color(0xFFDCD2C8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CAMPO DE TEXTO — rótulo mono em cima, resposta em 16/600 embaixo.
/// Raio 18, sombra de cartão.
class CampoDeTexto extends StatelessWidget {
  const CampoDeTexto({
    super.key,
    required this.rotulo,
    required this.controlador,
    this.dica,
    this.teclado,
    this.aoMudar,
  });

  final String rotulo;
  final TextEditingController controlador;
  final String? dica;
  final TextInputType? teclado;
  final ValueChanged<String>? aoMudar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(18),
        boxShadow: Medidas.sombraCartao,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rotulo.toUpperCase(),
            style: Tipo.rotulo.copyWith(fontSize: 10, color: Cores.apoio),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controlador,
            keyboardType: teclado,
            onChanged: aoMudar,
            cursorColor: Cores.tinta,
            style: Tipo.corpoForte.copyWith(fontSize: 16),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: dica,
              hintStyle: Tipo.corpoForte.copyWith(
                fontSize: 16,
                color: const Color(0xFFBDB3A9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// RÁDIO · UMA ESCOLHA — a linha inteira é o alvo, com borda teal quando
/// marcada. Raio 16.
class Radio extends StatelessWidget {
  const Radio({
    super.key,
    required this.rotulo,
    required this.marcado,
    required this.aoTocar,
    this.apoio,
  });

  final String rotulo;
  final String? apoio;
  final bool marcado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: marcado,
      button: true,
      child: GestureDetector(
        onTap: aoTocar,
        child: Container(
          constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Cores.branco,
            borderRadius: BorderRadius.circular(Medidas.raioEscolha),
            border: Border.all(
              color: marcado ? Cores.teal : Cores.bege,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: marcado ? Cores.teal : const Color(0xFFDCD2C8),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: marcado
                    ? Container(
                        width: 11,
                        height: 11,
                        decoration: const BoxDecoration(
                          color: Cores.teal,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rotulo,
                      style: Tipo.corpo.copyWith(
                        fontWeight:
                            marcado ? FontWeight.w600 : FontWeight.w400,
                        color: marcado
                            ? const Color(0xFF0B5F59)
                            : const Color(0xFF4A423C),
                      ),
                    ),
                    if (apoio != null)
                      Text(apoio!, style: Tipo.apoio),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CHECKBOX · VÁRIAS — quadrado de 24 com raio 7, verde quando marcado.
class Checkbox extends StatelessWidget {
  const Checkbox({
    super.key,
    required this.rotulo,
    required this.marcado,
    required this.aoTocar,
    this.apoio,
    this.aDireita,
  });

  final String rotulo;
  final String? apoio;
  final bool marcado;
  final VoidCallback aoTocar;

  /// O valor que aparece na ponta direita, como "−R$ 180 / POR MÊS".
  final Widget? aDireita;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: marcado,
      button: true,
      child: GestureDetector(
        onTap: aoTocar,
        child: Container(
          constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: marcado ? Cores.branco : const Color(0xFFFBF7F2),
            borderRadius: BorderRadius.circular(Medidas.raioEscolha),
            border: Border.all(
              color: marcado ? Cores.verde : Cores.bege,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: marcado ? Cores.verde : Cores.branco,
                  borderRadius: BorderRadius.circular(7),
                  border: marcado
                      ? null
                      : Border.all(color: const Color(0xFFDCD2C8), width: 2),
                ),
                child: marcado
                    ? const Icon(Icons.check_rounded,
                        size: 15, color: Cores.branco)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rotulo,
                      style: Tipo.corpo.copyWith(
                        fontWeight:
                            marcado ? FontWeight.w600 : FontWeight.w400,
                        color: marcado
                            ? Cores.tinta
                            : const Color(0xFF4A423C),
                      ),
                    ),
                    if (apoio != null) Text(apoio!, style: Tipo.apoio),
                  ],
                ),
              ),
              if (aDireita != null) ...[
                const SizedBox(width: 10),
                aDireita!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão "sobre acento" — creme com texto teal escuro, para usar dentro de
/// cabeçalho colorido. Altura 50.
class BotaoSobreAcento extends StatelessWidget {
  const BotaoSobreAcento({
    super.key,
    required this.rotulo,
    this.aoTocar,
    this.tinta = const Color(0xFF0B5F59),
  });

  final String rotulo;
  final VoidCallback? aoTocar;
  final Color tinta;

  @override
  Widget build(BuildContext context) {
    // FilledButton em vez de Material+InkWell na mão: o botão nativo já
    // trata hit-test, estado pressionado e acessibilidade. A versão
    // artesanal ficava intocável em algumas telas, e isso não aparece em
    // teste de widget — só no aparelho.
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: FilledButton(
        onPressed: aoTocar,
        style: FilledButton.styleFrom(
          backgroundColor: Cores.creme,
          foregroundColor: tinta,
          disabledBackgroundColor: Cores.creme.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Medidas.raioPilula),
          ),
        ),
        child: Text(
          rotulo,
          style: Tipo.corpoForte.copyWith(color: tinta),
        ),
      ),
    );
  }
}

/// Botão de contorno — recusa e ação alternativa. Branco com borda bege.
class BotaoDeContorno extends StatelessWidget {
  const BotaoDeContorno({super.key, required this.rotulo, this.aoTocar});

  final String rotulo;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: Material(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(Medidas.raioPilula),
        child: InkWell(
          onTap: aoTocar,
          borderRadius: BorderRadius.circular(Medidas.raioPilula),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Medidas.raioPilula),
              border: Border.all(color: Cores.bege, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              rotulo,
              style: Tipo.corpoForte.copyWith(color: Cores.apoio),
            ),
          ),
        ),
      ),
    );
  }
}

/// A barra de progresso do onboarding: trilha translúcida sobre o acento,
/// com o trecho andado em branco.
class ProgressoDoOnboarding extends StatelessWidget {
  const ProgressoDoOnboarding({
    super.key,
    required this.passo,
    required this.total,
  });

  final int passo;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'passo $passo de $total',
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
              decoration: BoxDecoration(
                color: i < passo
                    ? Cores.branco
                    : Cores.branco.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}
