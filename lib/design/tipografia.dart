import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
abstract final class Tipo {
  /// A interface é Figtree. Outfit entra só onde o design pede.
  static TextTheme tema(TextTheme base) => GoogleFonts.figtreeTextTheme(base);

  /// DISPLAY 54/600/-3.5% — o número do cabeçalho. Um por tela.
  static TextStyle get display => GoogleFonts.outfit(
        fontSize: 54,
        fontWeight: FontWeight.w600,
        height: 1.02,
        letterSpacing: -54 * 0.035,
      );

  /// NÚMERO 32/600 — valor grande fora do cabeçalho.
  static TextStyle get numero => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -32 * 0.025,
      );

  /// TÍTULO 19/600 — título de tela e de cartão de acento.
  static TextStyle get titulo => GoogleFonts.outfit(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -19 * 0.01,
      );

  /// Valor em linha de lista e de cartão. Valor é sempre Outfit.
  static TextStyle get valor => GoogleFonts.outfit(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      );

  /// CORPO FORTE 15/600 — rótulo de item.
  static TextStyle get corpoForte => GoogleFonts.figtree(
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
      );

  /// CORPO 14.5/400 — texto corrido de explicação.
  static TextStyle get corpo => GoogleFonts.figtree(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  /// APOIO 12.5/400 — metadado. O mínimo que o design permite.
  static TextStyle get apoio => GoogleFonts.figtree(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: Cores.apoio,
      );

  /// Texto dentro de cartão, entre o corpo e o apoio.
  static TextStyle get corpoMiudo => GoogleFonts.figtree(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  /// RÓTULO EM CAIXA ALTA · MONO 10.5/+10%. Só etiqueta, nunca frase.
  static TextStyle get rotulo => GoogleFonts.dmMono(
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
  static TextStyle get chip => GoogleFonts.figtree(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      );
}
