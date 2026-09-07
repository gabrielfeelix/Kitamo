import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../services/horizonte_service.dart';
import '../../widgets/moeda.dart';

/// O horizonte de 12 meses — a tela onde a pessoa vê a dívida acabando.
///
/// Cada mês é um bloco inteiro na cor do estado: a cor é a informação, e
/// se entende antes de ler o número.
class HorizontePage extends StatelessWidget {
  const HorizontePage({super.key, required this.meses});

  final List<MesResumo> meses;

  @override
  Widget build(BuildContext context) {
    final quitacao = meses.where((m) => m.ehQuitacao).firstOrNull;

    return Scaffold(
      backgroundColor: Cores.creme,
      appBar: AppBar(
        backgroundColor: Cores.creme,
        surfaceTintColor: Colors.transparent,
        title: Text('O ano inteiro', style: Tipo.subtitulo),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Medidas.margem),
        children: [
          if (quitacao != null) ...[
            _CartaoQuitacao(mes: quitacao),
            const SizedBox(height: Medidas.espacoGrande),
          ],
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: Medidas.espaco,
            crossAxisSpacing: Medidas.espaco,
            childAspectRatio: 0.95,
            children: [for (final m in meses) _BlocoMes(mes: m)],
          ),
        ],
      ),
    );
  }
}

class _CartaoQuitacao extends StatelessWidget {
  const _CartaoQuitacao({required this.mes});

  final MesResumo mes;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Medidas.margem),
        decoration: BoxDecoration(
          color: Cores.barro,
          borderRadius: BorderRadius.circular(Medidas.raioCartao),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SUA ÚLTIMA PARCELA CAI EM',
                style: Tipo.rotulo.copyWith(color: Cores.barroClaro)),
            const SizedBox(height: 8),
            Text(mes.rotulo, style: Tipo.numeroMedio.copyWith(color: Cores.branco)),
            const SizedBox(height: Medidas.espaco),
            Image.asset('assets/images/casa-5.png', height: 72),
          ],
        ),
      );
}

class _BlocoMes extends StatelessWidget {
  const _BlocoMes({required this.mes});

  final MesResumo mes;

  @override
  Widget build(BuildContext context) {
    final cor = mes.ehQuitacao ? Cores.barro : mes.estado.cor;
    final sobre = mes.estado == EstadoFinanceiro.atencao && !mes.ehQuitacao
        ? Cores.tinta
        : Cores.branco;

    return Semantics(
      label: '${mes.rotulo}, saldo ${dinheiro(mes.saldoFinal)}',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(Medidas.raioInterno),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(mes.rotulo, style: Tipo.rotulo.copyWith(color: sobre)),
            Text(
              dinheiro(mes.saldoFinal),
              style: Tipo.corpoForte.copyWith(color: sobre),
            ),
            if (mes.temDivida)
              Container(
                height: 3,
                width: 20,
                decoration: BoxDecoration(
                  color: sobre.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(Medidas.raioBarra),
                ),
              )
            else
              const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }
}
