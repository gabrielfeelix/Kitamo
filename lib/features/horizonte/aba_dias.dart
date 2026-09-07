import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/lancamento_registro.dart';
import '../../services/horizonte_service.dart';
import '../../widgets/celula_de_saldo.dart';
import '../../widgets/moeda.dart';

/// A aba "dias" (#09): o mês linha a linha.
///
/// Quatro colunas — DIA, PODE GASTAR, GASTOU, SALDO — e o rodapé barro com
/// a média. É a tela que mostra o combinado contra o que aconteceu: sem a
/// coluna GASTOU o app só prevê, não acompanha.
class AbaDias extends StatelessWidget {
  const AbaDias({
    super.key,
    required this.mes,
    required this.lancamentos,
    required this.diario,
  });

  final MesProjetado mes;
  final List<LancamentoRegistro> lancamentos;
  final double diario;

  /// Quanto ela gastou em cada dia deste mês.
  Map<int, double> get _gastoPorDia {
    final mapa = <int, double>{};
    if (mes.dias.isEmpty) return mapa;

    final ref = mes.dias.first.data;
    for (final l in lancamentos) {
      if (l.ehEntrada) continue;
      if (l.data.year != ref.year || l.data.month != ref.month) continue;
      mapa[l.data.day] = (mapa[l.data.day] ?? 0) + l.valor;
    }
    return mapa;
  }

  @override
  Widget build(BuildContext context) {
    final gastos = _gastoPorDia;
    final hoje = DateTime.now();

    // A média só conta os dias que já aconteceram: dividir pelo mês
    // inteiro faria a média despencar no dia 2 e assustar à toa.
    final gastou = gastos.values.fold<double>(0, (s, v) => s + v);
    final diasComGasto = gastos.length;
    final media = diasComGasto == 0 ? 0.0 : gastou / diasComGasto;
    final acima = gastos.values.where((v) => v > diario).length;

    return Column(
      children: [
        const _Cabecalho(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, Medidas.espaco),
            itemCount: mes.dias.length,
            separatorBuilder: (_, _) => const SizedBox(height: 3),
            itemBuilder: (_, i) {
              final dia = mes.dias[i];
              final ehHoje = dia.data.year == hoje.year &&
                  dia.data.month == hoje.month &&
                  dia.data.day == hoje.day;

              return _Linha(
                dia: dia,
                gastou: gastos[dia.dia],
                podeGastar: diario,
                ehHoje: ehHoje,
              );
            },
          ),
        ),
        if (diasComGasto > 0)
          _RodapeBarro(media: media, diasAcima: acima),
      ],
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(
      fontFamily: Tipo.dmMono,
      fontSize: 10.5,
      letterSpacing: 10.5 * 0.08,
      color: Cores.apoio,
    );

    return const Padding(
      // +8 de cada lado para casar com o padding interno da linha, que
      // tem fundo branco e recuo próprio.
      padding: EdgeInsets.fromLTRB(24, 10, 24, 6),
      child: Row(
        children: [
          SizedBox(width: 26, child: Text('DIA', style: estilo)),
          SizedBox(width: 8),
          Expanded(flex: 4, child: Text('PODE GASTAR', style: estilo)),
          SizedBox(width: 8),
          Expanded(flex: 3, child: Text('GASTOU', style: estilo)),
          SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text('SALDO', style: estilo, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.dia,
    required this.gastou,
    required this.podeGastar,
    required this.ehHoje,
  });

  final DiaProjetado dia;
  final double? gastou;
  final double podeGastar;
  final bool ehHoje;

  @override
  Widget build(BuildContext context) {
    const mono = TextStyle(
      fontFamily: Tipo.dmMono,
      fontSize: 12.5,
      color: Cores.apoio,
    );

    // Gastou mais do que podia: o número fica vermelho. Não é bronca, é a
    // informação que ela precisa para entender o saldo da direita.
    final estourou = gastou != null && gastou! > podeGastar;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(Medidas.raioCelula),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D5C2E1A),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Container(
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ehHoje ? Cores.tinta : Cores.bege,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${dia.dia}',
                style: TextStyle(
                  fontFamily: Tipo.dmMono,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: ehHoje ? Cores.branco : Cores.tinta,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(dinheiro(podeGastar), style: mono),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                gastou == null ? '—' : dinheiro(gastou!),
                style: mono.copyWith(
                  fontWeight: FontWeight.w500,
                  color: estourou ? Cores.vermelho : Cores.tinta,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 5, child: CelulaDeSaldo(valor: dia.saldo)),
        ],
      ),
    );
  }
}

/// O rodapé barro: a média gasta e quantos dias passaram do diário.
class _RodapeBarro extends StatelessWidget {
  const _RodapeBarro({required this.media, required this.diasAcima});

  final double media;
  final int diasAcima;

  @override
  Widget build(BuildContext context) {
    const rotulo = TextStyle(
      fontFamily: Tipo.dmMono,
      fontSize: 10.5,
      letterSpacing: 10.5 * 0.08,
      color: Cores.branco,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, Medidas.espaco),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Cores.barro,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('GASTOU EM MÉDIA', style: rotulo),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dinheiro(media),
                    style: Tipo.titulo.copyWith(color: Cores.branco),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    diasAcima == 1
                        ? '1 DIA ACIMA DO DIÁRIO'
                        : '$diasAcima DIAS ACIMA DO DIÁRIO',
                    style: rotulo,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
