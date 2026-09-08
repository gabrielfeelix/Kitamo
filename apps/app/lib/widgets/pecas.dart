import 'package:flutter/material.dart';

import '../design/cores.dart';
import '../design/medidas.dart';
import '../design/tipografia.dart';

/// As peças do "Kitamo Design System", uma classe por componente nomeado.
/// Se o design deu nome, aqui tem widget — as telas não desenham cartão na
/// mão.

/// CARTÃO PADRÃO — branco, raio 22, sombra suave, padding 16.
class Cartao extends StatelessWidget {
  const Cartao({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.raio = Medidas.raioCartao,
    this.aoTocar,
  });

  final Widget child;
  final EdgeInsets padding;
  final double raio;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final corpo = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(raio),
        boxShadow: Medidas.sombraCartao,
      ),
      child: child,
    );

    if (aoTocar == null) return corpo;
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(raio),
      child: corpo,
    );
  }
}

/// CARTÃO DE ACENTO — barro, sem sombra, texto branco cheio, ilustração na
/// direita. **Um por tela**, diz o design.
class CartaoDeAcento extends StatelessWidget {
  const CartaoDeAcento({
    super.key,
    required this.titulo,
    required this.apoio,
    this.ilustracao,
    this.alturaIlustracao = 58,
    this.aoTocar,
  });

  final String titulo;
  final String apoio;
  final String? ilustracao;
  final double alturaIlustracao;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final corpo = Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
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
                  titulo,
                  style: Tipo.titulo.copyWith(color: Cores.creme),
                ),
                const SizedBox(height: 4),
                Text(
                  apoio,
                  style: Tipo.corpoMiudo.copyWith(color: Cores.branco),
                ),
              ],
            ),
          ),
          if (ilustracao != null) ...[
            const SizedBox(width: 10),
            Image.asset(
              'assets/images/$ilustracao',
              height: alturaIlustracao,
              fit: BoxFit.contain,
            ),
          ],
        ],
      ),
    );

    if (aoTocar == null) return corpo;
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(Medidas.raioCartao),
      child: corpo,
    );
  }
}

/// CARTÃO DE FALA DO JOÃO — fundo #FFF1E8 com borda #F0D3C1.
/// Só para leitura da Kitamo, **nunca para dado**.
class FalaDaKitamo extends StatelessWidget {
  const FalaDaKitamo({super.key, required this.texto, this.comAvatar = true});

  final String texto;
  final bool comAvatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Cores.barroClaro,
        borderRadius: BorderRadius.circular(Medidas.raioCartao),
        border: Border.all(color: Cores.borda, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comAvatar) ...[
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Cores.branco,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.all(3),
              child: Image.asset(
                'assets/images/joao-voando.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 11),
          ],
          Expanded(
            child: Text(texto, style: Tipo.corpoMiudo),
          ),
        ],
      ),
    );
  }
}

/// RÓTULO EM CAIXA ALTA — mono, espaçado. Só etiqueta.
class Rotulo extends StatelessWidget {
  const Rotulo(this.texto, {super.key, this.cor});

  final String texto;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto.toUpperCase(),
      style: Tipo.rotulo.copyWith(color: cor ?? Cores.apoio),
    );
  }
}

/// Tile de 38px que segura logo de banco ou iniciais em bege.
class Tile extends StatelessWidget {
  const Tile({super.key, this.logo, this.iniciais, this.fundo});

  final String? logo;
  final String? iniciais;
  final Color? fundo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: fundo ?? Cores.bege,
        borderRadius: BorderRadius.circular(19),
      ),
      alignment: Alignment.center,
      child: logo != null
          ? Image.asset('assets/images/$logo', width: 21, fit: BoxFit.contain)
          : Text(
              (iniciais ?? '?').toUpperCase(),
              style: Tipo.rotulo.copyWith(color: Cores.apoio),
            ),
    );
  }
}

/// Botão principal — 50px, raio total, tinta sobre creme.
/// "uma por tela, no rodapé", diz o design.
class BotaoPrincipal extends StatelessWidget {
  const BotaoPrincipal({
    super.key,
    required this.rotulo,
    this.aoTocar,
    this.altura = 50,
  });

  final String rotulo;
  final VoidCallback? aoTocar;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final ligado = aoTocar != null;
    return SizedBox(
      height: altura,
      width: double.infinity,
      // FilledButton, não Material+InkWell na mão: o nativo trata
      // hit-test e estado pressionado sozinho.
      child: FilledButton(
        onPressed: aoTocar,
        style: FilledButton.styleFrom(
          backgroundColor: Cores.tinta,
          foregroundColor: Cores.creme,
          disabledBackgroundColor: Cores.bege,
          disabledForegroundColor: Cores.apoio,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Medidas.raioPilula),
          ),
        ),
        child: Text(
          rotulo,
          style: Tipo.corpoForte.copyWith(
            color: ligado ? Cores.creme : Cores.apoio,
          ),
        ),
      ),
    );
  }
}
