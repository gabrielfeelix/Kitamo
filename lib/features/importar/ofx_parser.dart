import '../../models/lancamento_registro.dart';

/// Lê um extrato OFX.
///
/// OFX é o formato que todo banco brasileiro exporta. É SGML, não XML: as
/// tags nem sempre fecham, então parser de XML engasga. Daí o parsing por
/// expressão regular, que aqui é a escolha certa e não gambiarra.
class OfxParser {
  const OfxParser();

  /// Cada transação vem num bloco STMTTRN.
  static final _transacao = RegExp(
    r'<STMTTRN>(.*?)</STMTTRN>',
    dotAll: true,
    caseSensitive: false,
  );

  static String? _campo(String bloco, String tag) {
    // Aceita tanto <TAG>valor quanto <TAG>valor</TAG>.
    final m = RegExp('<$tag>([^<\r\n]*)', caseSensitive: false).firstMatch(bloco);
    return m?.group(1)?.trim();
  }

  List<LancamentoRegistro> ler(String conteudo) {
    final itens = <LancamentoRegistro>[];

    for (final m in _transacao.allMatches(conteudo)) {
      final bloco = m.group(1)!;

      final valorBruto = _campo(bloco, 'TRNAMT');
      if (valorBruto == null) continue;

      final valor = double.tryParse(valorBruto.replaceAll(',', '.'));
      if (valor == null) continue;

      final data = _lerData(_campo(bloco, 'DTPOSTED'));
      if (data == null) continue;

      final descricao = _campo(bloco, 'MEMO') ??
          _campo(bloco, 'NAME') ??
          'lançamento importado';

      // No OFX o sinal do valor é o que diz se entrou ou saiu.
      final ehEntrada = valor > 0;

      itens.add(LancamentoRegistro(
        // FITID é o identificador do banco. Usar ele evita duplicar quando
        // a pessoa importa o mesmo extrato duas vezes — o que acontece.
        id: _campo(bloco, 'FITID') ??
            '${data.millisecondsSinceEpoch}_${valor.abs()}',
        descricao: descricao,
        valor: valor.abs(),
        tipo: ehEntrada ? TipoLancamento.entrada : TipoLancamento.gasto,
        data: data,
      ));
    }

    return itens;
  }

  /// OFX usa YYYYMMDD, às vezes com hora e fuso colados atrás.
  DateTime? _lerData(String? bruta) {
    if (bruta == null || bruta.length < 8) return null;

    final ano = int.tryParse(bruta.substring(0, 4));
    final mes = int.tryParse(bruta.substring(4, 6));
    final dia = int.tryParse(bruta.substring(6, 8));

    if (ano == null || mes == null || dia == null) return null;
    if (mes < 1 || mes > 12 || dia < 1 || dia > 31) return null;

    return DateTime(ano, mes, dia);
  }
}
