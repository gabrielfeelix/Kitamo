import 'package:flutter/material.dart';

import 'cores.dart';

/// Tipografia da Kitamo.
///
/// Os tamanhos vêm da seção "02 · TIPOGRAFIA" do Kitamo Design System, sem
/// arredondar: o design pediu 54/32/19 e 14.5, e é isso que o app usa.
///
/// A divisão de famílias também é do design:
/// **Outfit** em número e título, **Figtree** em interface e texto corrido,
/// **DM Mono** em rótulo de caixa alta.
///
/// Regra da marca: número na frente, frase curta explica o número.
///
/// As fontes vêm do APK, não do google_fonts: sem rede, o download falha e
/// a tela inteira cai no Roboto. Ver a nota no pubspec.
abstract final class Tipo {
  /// Número e título.
  static const outfit = 'Outfit';

  /// Interface e texto corrido.
  static const figtree = 'Figtree';

  /// Rótulo em caixa alta.
  static const dmMono = 'DM Mono';

  /// A interface é Figtree. Outfit entra só onde o design pede.
  static TextTheme tema(TextTheme base) =>
      base.apply(fontFamily: figtree);

  /// DISPLAY 54/600/-3.5% — o número do cabeçalho. Um por tela.
  static const TextStyle display = TextStyle(
        fontFamily: outfit,
        fontSize: 54,
        fontWeight: FontWeight.w600,
        height: 1.02,
        letterSpacing: -54 * 0.035,
      );

  /// NÚMERO 32/600 — valor grande fora do cabeçalho.
  static const TextStyle numero = TextStyle(
        fontFamily: outfit,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -32 * 0.025,
      );

  /// TÍTULO 19/600 — título de tela e de cartão de acento.
  static const TextStyle titulo = TextStyle(
        fontFamily: outfit,
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -19 * 0.01,
      );

  /// Valor em linha de lista e de cartão. Valor é sempre Outfit.
  static const TextStyle valor = TextStyle(
        fontFamily: outfit,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      );

  /// CORPO FORTE 15/600 — rótulo de item.
  static const TextStyle corpoForte = TextStyle(
        fontFamily: figtree,
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
      );

  /// CORPO 14.5/400 — texto corrido de explicação.
  static const TextStyle corpo = TextStyle(
        fontFamily: figtree,
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  /// APOIO 12.5/400 — metadado. O mínimo que o design permite.
  static const TextStyle apoio = TextStyle(
        fontFamily: figtree,
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: Cores.apoio,
      );

  /// Texto dentro de cartão, entre o corpo e o apoio.
  static const TextStyle corpoMiudo = TextStyle(
        fontFamily: figtree,
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  /// RÓTULO EM CAIXA ALTA · MONO 10.5/+10%. Só etiqueta, nunca frase.
  static const TextStyle rotulo = TextStyle(
        fontFamily: dmMono,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 11 * 0.1,
      );

  // ── Nomes antigos ────────────────────────────────────────────────────
  // As telas que ainda não foram refeitas a partir do HTML usam estes.
  // Apontam para os tamanhos certos do design, então já corrigem a tela
  // enquanto ela espera a vez. Somem quando a última for refeita.

  @Deprecated('use Tipo.display — refazer a tela a partir do .dc.html')
  static TextStyle get numeroGigante => display;

  @Deprecated('use Tipo.numero — refazer a tela a partir do .dc.html')
  static TextStyle get numeroMedio => numero;

  @Deprecated('use Tipo.titulo — refazer a tela a partir do .dc.html')
  static TextStyle get subtitulo => titulo;

  /// Chip do cabeçalho e da barra.
  static const TextStyle chip = TextStyle(
        fontFamily: figtree,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      );
}
