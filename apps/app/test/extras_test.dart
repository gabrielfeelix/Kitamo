import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/features/chat/respostas.dart';
import 'package:kitamo/features/importar/ofx_parser.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/lancamento_registro.dart';
import 'package:kitamo/models/perfil_financeiro.dart';

/// OFX e chat.
///
/// O risco do OFX é duplicar lançamento quando a pessoa importa o mesmo
/// extrato duas vezes — o que acontece na prática. O do chat é dizer um
/// número errado: um chat que erra a parcela é pior que não ter chat.
void main() {
  group('OFX', () {
    const parser = OfxParser();

    const extrato = '''
OFXHEADER:100
<OFX><BANKMSGSRSV1><STMTTRNRS><STMTRS><BANKTRANLIST>
<STMTTRN>
<TRNTYPE>DEBIT
<DTPOSTED>20260904120000[-3:BRT]
<TRNAMT>-87.40
<FITID>2026090401
<MEMO>SUPERMERCADO XYZ
</STMTTRN>
<STMTTRN>
<TRNTYPE>CREDIT
<DTPOSTED>20260906
<TRNAMT>3650.00
<FITID>2026090601
<MEMO>SALARIO
</STMTTRN>
</BANKTRANLIST></STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>
''';

    test('lê as transações do extrato', () {
      final itens = parser.ler(extrato);

      expect(itens, hasLength(2));
      expect(itens[0].descricao, 'SUPERMERCADO XYZ');
      expect(itens[0].valor, 87.40);
      expect(itens[0].tipo, TipoLancamento.gasto);
      expect(itens[0].data, DateTime(2026, 9, 4));
    });

    test('o sinal do valor decide entrada ou saída', () {
      final itens = parser.ler(extrato);

      expect(itens[1].tipo, TipoLancamento.entrada);
      expect(itens[1].valor, 3650);
    });

    test('usa o FITID como id, para não duplicar em reimportação', () {
      // Importar o mesmo arquivo duas vezes tem que gerar os mesmos ids,
      // senão o insertOnConflictUpdate duplica tudo.
      final a = parser.ler(extrato).map((e) => e.id).toList();
      final b = parser.ler(extrato).map((e) => e.id).toList();

      expect(a, b);
      expect(a.first, '2026090401');
    });

    test('lê data com hora e fuso colados', () {
      expect(parser.ler(extrato)[0].data, DateTime(2026, 9, 4));
    });

    test('arquivo vazio ou sem transação devolve lista vazia', () {
      expect(parser.ler(''), isEmpty);
      expect(parser.ler('<OFX></OFX>'), isEmpty);
    });

    test('transação corrompida é pulada, não derruba o resto', () {
      const ruim = '''
<STMTTRN><TRNAMT>abc<DTPOSTED>20260904<MEMO>ruim</STMTTRN>
<STMTTRN><TRNAMT>-10.00<DTPOSTED>20260905<MEMO>boa</STMTTRN>
''';
      final itens = parser.ler(ruim);

      expect(itens, hasLength(1));
      expect(itens.first.descricao, 'boa');
    });

    test('data inválida é recusada', () {
      const ruim = '<STMTTRN><TRNAMT>-10<DTPOSTED>2026994<MEMO>x</STMTTRN>';
      expect(parser.ler(ruim), isEmpty);
    });
  });

  group('chat', () {
    const respostas = Respostas();

    final nubank = Divida(
      id: '1',
      nome: 'Nubank',
      saldoAtual: 6136.24,
      valorParcela: 1534.06,
      diaVencimento: 4,
      parcelasRestantes: 4,
      parcelasTotal: 10,
    );

    const folgado = PerfilFinanceiro(
      rendaMensal: 5000,
      diaRenda: 6,
      contasFixasEstimadas: 900,
    );

    const apertado = PerfilFinanceiro(
      rendaMensal: 2000,
      diaRenda: 6,
      contasFixasEstimadas: 900,
    );

    test('diz quanto falta com número real', () {
      final r = respostas.responder('falta',
          perfil: folgado, dividas: [nubank]);

      expect(r, contains('4 parcelas'));
      expect(r, contains('6.136,24'));
    });

    test('explica o diário pela conta que fez', () {
      final r = respostas.responder('diario',
          perfil: folgado, dividas: [nubank]);

      expect(r, contains('sobra'));
      expect(r, contains('dias'));
    });

    test('quando a conta não fecha, não sugere antecipar', () {
      final r = respostas.responder('antecipar',
          perfil: apertado, dividas: [nubank]);

      expect(r, contains('apertado'));
      expect(r, isNot(contains('menor parcela')));
    });

    test('sem dívida responde sem inventar', () {
      expect(respostas.responder('falta', perfil: folgado, dividas: []),
          contains('não tem dívida'));
      expect(respostas.responder('proxima', perfil: folgado, dividas: []),
          contains('não tem parcela'));
    });

    test('pergunta desconhecida admite que não sabe', () {
      final r = respostas.responder('qualquer-coisa',
          perfil: folgado, dividas: [nubank]);

      expect(r, contains('ainda não sei'));
    });

    test('dívida quitada não entra na conta', () {
      final quitada = Divida(
        id: 'q',
        nome: 'Paga',
        saldoAtual: 0,
        valorParcela: 500,
        diaVencimento: 5,
        parcelasRestantes: 0,
        parcelasTotal: 5,
        quitadaEm: DateTime(2026, 1, 1),
      );

      final r = respostas.responder('falta',
          perfil: folgado, dividas: [nubank, quitada]);

      expect(r, contains('4 parcelas'));
    });
  });
}
