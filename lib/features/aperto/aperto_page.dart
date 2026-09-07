import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/divida.dart';
import '../../models/perfil_financeiro.dart';
import 'caminhos.dart';

/// "A conta não fecha · escolher um caminho".
///
/// **Sem o joão-de-barro.** Bicho fofo em cima de má notícia é deboche —
/// nessa tela ele sai da frente.
class ApertoPage extends StatelessWidget {
  const ApertoPage({
    super.key,
    required this.perfil,
    required this.dividas,
    required this.faltaPorMes,
  });

  final PerfilFinanceiro? perfil;
  final List<Divida> dividas;
  final double faltaPorMes;

  @override
  Widget build(BuildContext context) {
    final caminhos =
        const Caminhos().montar(perfil: perfil, dividas: dividas);

    return Scaffold(
      backgroundColor: Cores.creme,
      appBar: AppBar(
        backgroundColor: Cores.vermelho,
        foregroundColor: Cores.branco,
        surfaceTintColor: Colors.transparent,
        title: Text('Escolher um caminho',
            style: Tipo.subtitulo.copyWith(color: Cores.branco)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Medidas.margem),
        children: [
          Text(
            'faltam R\$ ${faltaPorMes.toStringAsFixed(2).replaceAll('.', ',')} '
            'por mês pra conta fechar. Nenhum desses caminhos resolve '
            'sozinho — mas algum encurta o caminho.',
            style: Tipo.corpo,
          ),
          const SizedBox(height: Medidas.espacoGrande),
          for (final c in caminhos) _CartaoCaminho(caminho: c),
        ],
      ),
    );
  }
}

class _CartaoCaminho extends StatelessWidget {
  const _CartaoCaminho({required this.caminho});

  final Caminho caminho;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: Medidas.espaco),
        padding: const EdgeInsets.all(Medidas.margem),
        decoration: BoxDecoration(
          color: Cores.branco,
          borderRadius: BorderRadius.circular(Medidas.raioCartao),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(caminho.titulo, style: Tipo.corpoForte),
            const SizedBox(height: 6),
            Text(caminho.detalhe, style: Tipo.apoio),
            if (caminho.acao != null) ...[
              const SizedBox(height: Medidas.espaco),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Cores.barroClaro,
                  borderRadius: BorderRadius.circular(Medidas.raioPilula),
                ),
                child: Text(caminho.acao!,
                    style: Tipo.apoio.copyWith(color: Cores.barro)),
              ),
            ],
          ],
        ),
      );
}
