/// Conversão entre reais (o que a tela mostra) e centavos (o que o banco
/// guarda).
///
/// Existe para que o arredondamento aconteça em **um lugar só**. Espalhar
/// `(v * 100).round()` pelo código é como o centavo some.
abstract final class Dinheiro {
  static int paraCentavos(double reais) => (reais * 100).round();

  static double paraReais(int centavos) => centavos / 100;

  static int? paraCentavosNulo(double? reais) =>
      reais == null ? null : paraCentavos(reais);

  static double? paraReaisNulo(int? centavos) =>
      centavos == null ? null : paraReais(centavos);
}
