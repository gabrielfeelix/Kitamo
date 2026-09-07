import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../services/horizonte_service.dart';
import '../../widgets/moeda.dart';

/// O mês dia a dia — a planilha do Breno, mas falando.
///
/// Cada linha tem nome ("parcela do Nubank", não "R$ 1.534") e toda cor vem
/// com motivo. Vermelho sem explicação é só um susto.
class MesPage extends StatelessWidget {
  const MesPage({super.key, required this.mes, required this.titulo});

  final MesProjetado mes;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();

    return Scaffold(
      backgroundColor: Cores.creme,
      appBar: AppBar(
        backgroundColor: Cores.creme,
        surfaceTintColor: Colors.transparent,
        title: Text(titulo, style: Tipo.subtitulo),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(Medidas.margem),
        itemCount: mes.dias.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, i) {
          final d = mes.dias[i];
          return _LinhaDia(
            dia: d,
            ehHoje: d.data.year == hoje.year &&
                d.data.month == hoje.month &&
                d.data.day == hoje.day,
          );
        },
      ),
    );
  }
}

class _LinhaDia extends StatelessWidget {
  const _LinhaDia({required this.dia, required this.ehHoje});

  final DiaProjetado dia;
  final bool ehHoje;

  @override
  Widget build(BuildContext context) {
    final temConteudo = dia.lancamentos.isNotEmpty || dia.motivo != null;

    return Semantics(
      label: 'dia ${dia.dia}, saldo ${dinheiro(dia.saldo)}'
          '${dia.motivo == null ? '' : ', ${dia.motivo}'}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: dia.estado.fundo,
          borderRadius: BorderRadius.circular(Medidas.raioInterno),
          border: ehHoje ? Border.all(color: Cores.teal, width: 2) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${dia.dia}',
                style: Tipo.corpoForte.copyWith(
                  color: ehHoje ? Cores.teal : Cores.apoio,
                ),
              ),
            ),
            Expanded(
              child: temConteudo
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final l in dia.lancamentos)
                          Text(l.nome, style: Tipo.corpoForte),
                        if (dia.motivo != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(dia.motivo!, style: Tipo.apoio),
                          ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            Text(
              dinheiro(dia.saldo),
              style: Tipo.corpo.copyWith(
                color: dia.saldo < 0 ? Cores.vermelho : Cores.apoio,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
