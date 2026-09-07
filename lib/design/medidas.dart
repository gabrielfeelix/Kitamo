import 'package:flutter/material.dart';

/// Espaço, raio e sombra — seção "04 · CARTÕES, SOMBRA E RAIO" e
/// "07 · ESPAÇO, GRADE E VOZ" do Kitamo Design System.
///
/// Os números não são arredondados de propósito: o design pediu cartões a
/// 9px de distância e rodapé de 112px quando a barra existe.
abstract final class Medidas {
  // Raio, por uso — o design nomeia cada um.
  /// Célula e tag.
  static const raioCelula = 12.0;

  /// Opção de escolha.
  static const raioEscolha = 16.0;

  /// Linha de lista.
  static const raioLinha = 20.0;

  /// Cartão.
  static const raioCartao = 22.0;

  /// Cabeçalho — só nos cantos de baixo.
  static const raioCabecalho = 34.0;

  static const raioPilula = 999.0;

  /// Margem lateral da tela.
  static const margem = 20.0;

  /// Distância entre cartões.
  static const entreCartoes = 9.0;

  static const espaco = 12.0;
  static const espacoGrande = 24.0;

  /// Respiro do rodapé quando a barra de navegação existe.
  static const rodapeComBarra = 112.0;

  /// Respiro do rodapé sem barra.
  static const rodape = 24.0;

  /// Altura da barra de navegação.
  static const alturaBarra = 94.0;

  /// Alvo de toque mínimo. O design não deixa passar disso.
  static const alvoMinimo = 44.0;

  // Nomes antigos, das telas que ainda não foram refeitas.
  @Deprecated('use Medidas.raioEscolha — refazer a tela a partir do .dc.html')
  static const raioInterno = raioEscolha;

  @Deprecated('use 4.0 direto — a trilha do design tem 4px de raio')
  static const raioBarra = 4.0;

  /// Sombra de cartão padrão.
  static const sombraCartao = [
    BoxShadow(
      color: Color(0x145C2E1A),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  /// Sombra do joão sobre o cabeçalho.
  static const sombraPersonagem = [
    BoxShadow(
      color: Color(0x38143214),
      blurRadius: 18,
      offset: Offset(0, 10),
    ),
  ];

  // Duração — seção "11 · MOVIMENTO".
  static const toque = Duration(milliseconds: 120);
  static const trocaDeTela = Duration(milliseconds: 240);
  static const folhaSubindo = Duration(milliseconds: 280);
  static const numeroQueMuda = Duration(milliseconds: 400);
}
