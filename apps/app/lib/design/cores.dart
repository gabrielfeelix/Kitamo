import 'package:flutter/material.dart';

/// Paleta da Kitamo.
///
/// Extraída do "Kitamo Design System" do Claude Design (06/09/2026) — é a
/// fonte da verdade. Os valores são mais escuros que a proposta original
/// porque garantem contraste AA com texto branco: o app precisa ser legível
/// a 60 anos.
///
/// A regra que não se quebra: **fundo sempre creme, cartão sempre branco,
/// um acento por tela.** O barro é acento, nunca parede.
abstract final class Cores {
  /// Fundo de tela e cartão claro.
  static const creme = Color(0xFFFAF7F2);

  /// Texto principal e botão escuro.
  static const tinta = Color(0xFF1C1917);

  /// Texto secundário. É o mínimo legível sobre branco — não clarear.
  static const apoio = Color(0xFF6B615A);

  /// Marca, cartão de acento, progresso. O barro do joão-de-barro.
  static const barro = Color(0xFFA34A24);

  /// Fala do joão, fundo de conquista.
  static const barroClaro = Color(0xFFFFF1E8);

  /// Link, seleção, item ativo.
  static const teal = Color(0xFF0C7468);

  /// Cabeçalho do chat e da abertura.
  static const tealEscuro = Color(0xFF0F766E);

  /// Dia tranquilo, confirmação.
  static const verde = Color(0xFF3F7A3D);

  /// Dia apertado, atenção.
  static const ambar = Color(0xFFE8A33D);

  /// No vermelho, vencimento, erro. É vermelho de barro, não de sistema:
  /// dívida é situação, não bug.
  static const vermelho = Color(0xFFB23D1B);

  /// Trilha, divisória, botão desativado.
  static const bege = Color(0xFFEFE6DB);

  /// Contorno de cartão de fala.
  static const borda = Color(0xFFF0D3C1);

  static const branco = Color(0xFFFFFFFF);
}

/// O estado de um dia ou de um mês. A cor é a informação: a pessoa entende
/// antes de ler o número.
enum EstadoFinanceiro {
  tranquilo,
  atencao,
  aperto;

  Color get cor => switch (this) {
        EstadoFinanceiro.tranquilo => Cores.verde,
        EstadoFinanceiro.atencao => Cores.ambar,
        EstadoFinanceiro.aperto => Cores.vermelho,
      };

  /// Fundo suave para a linha do dia no horizonte.
  Color get fundo => switch (this) {
        EstadoFinanceiro.tranquilo => Cores.branco,
        EstadoFinanceiro.atencao => const Color(0xFFFDF3E0),
        EstadoFinanceiro.aperto => const Color(0xFFFBEAE4),
      };

  /// O âmbar é claro demais para texto branco por cima.
  Color get sobre =>
      this == EstadoFinanceiro.atencao ? Cores.tinta : Cores.branco;
}

/// O cabeçalho do Início inteiro, por estado do dia.
///
/// Vem do bloco `hd` do "Kitamo App.dc.html": cada estado traz fundo, tinta,
/// tinta apagada e as cores do chip. O âmbar inverte — texto escuro sobre
/// fundo claro — porque não passa contraste com branco.
enum CabecalhoDoDia {
  tranquilo(
    fundo: Color(0xFF3F7A3D),
    tinta: Color(0xFFFFFFFF),
    tintaFraca: Color(0xFFF1FAF0),
    chipFundo: Color(0xFFFAF7F2),
    chipTinta: Color(0xFF2F5C2E),
  ),
  atencao(
    fundo: Color(0xFFE8A33D),
    tinta: Color(0xFF2B1F0C),
    tintaFraca: Color(0xFF3F2E0F),
    chipFundo: Color(0xFF2B1F0C),
    chipTinta: Color(0xFFFAF7F2),
  ),
  aperto(
    fundo: Color(0xFFB23D1B),
    tinta: Color(0xFFFFFFFF),
    tintaFraca: Color(0xFFFFFFFF),
    chipFundo: Color(0xFFFAF7F2),
    chipTinta: Color(0xFF8E3F20),
  );

  const CabecalhoDoDia({
    required this.fundo,
    required this.tinta,
    required this.tintaFraca,
    required this.chipFundo,
    required this.chipTinta,
  });

  final Color fundo;
  final Color tinta;
  final Color tintaFraca;
  final Color chipFundo;
  final Color chipTinta;

  /// Véu escuro sobre o cabeçalho: sino, chip secundário, botões de mês.
  Color get veu => const Color(0x29000000);

  /// O joão some quando a conta não fecha. Bicho fofo sobre má notícia é
  /// deboche — é regra do design, não preferência.
  bool get mostraPersonagem => this != CabecalhoDoDia.aperto;
}
