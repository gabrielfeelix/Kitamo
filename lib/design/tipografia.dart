import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cores.dart';

/// Tipografia da Kitamo.
///
/// Outfit para display e interface, DM Mono para rótulos curtos em
/// maiúsculas — como no design system do Claude Design.
///
/// Regra da marca: **número na frente, frase explica o número.** Por isso
/// [numeroGigante] existe e é usado sem medo.
abstract final class Tipo {
  static TextTheme tema(TextTheme base) => GoogleFonts.outfitTextTheme(base);

  /// O número do dia. Grande de verdade — é o protagonista da tela.
  static TextStyle get numeroGigante => GoogleFonts.outfit(
        fontSize: 64,
        fontWeight: FontWeight.w800,
        height: 1,
        letterSpacing: -1.5,
      );

  static TextStyle get numeroMedio => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.1,
      );

  static TextStyle get titulo => GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get subtitulo => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  /// Texto corrido. Nunca abaixo de 16 — legível a 60 anos.
  static TextStyle get corpo => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle get corpoForte => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get apoio => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Cores.apoio,
      );

  /// Rótulo curto em maiúsculas. Só para etiqueta, nunca para frase.
  static TextStyle get rotulo => GoogleFonts.dmMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
      );
}
