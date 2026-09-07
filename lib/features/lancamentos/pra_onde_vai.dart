import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/lancamento_registro.dart';
import '../../widgets/moeda.dart';

/// Uma fatia do gasto do mês.
class Fatia {
  const Fatia({
    required this.nome,
    required this.total,
    required this.proporcao,
  });

  final String nome;
  final double total;
  final double proporcao;
}

/// Agrupa os gastos por descrição.
///
/// Sem categoria cadastrada, a descrição é o que existe — e agrupar por ela
/// já responde "pra onde vai" na prática, porque as pessoas repetem os
/// mesmos nomes ("mercado", "ifood").
List<Fatia> agruparGastos(List<LancamentoRegistro> lancamentos) {
  final gastos = lancamentos.where((l) => !l.ehEntrada);
  if (gastos.isEmpty) return const [];

  final porNome = <String, double>{};
  for (final g in gastos) {
    final chave = (g.categoria ?? g.descricao).trim().toLowerCase();
    porNome[chave] = (porNome[chave] ?? 0) + g.valor;
  }

  final total = porNome.values.fold<double>(0, (a, b) => a + b);
  if (total <= 0) return const [];

  final fatias = porNome.entries
      .map((e) => Fatia(
            nome: e.key,
            total: (e.value * 100).round() / 100,
            proporcao: e.value / total,
          ))
      .toList();

  // Maior primeiro: quem abre essa tela quer saber o que mais pesa.
  fatias.sort((a, b) => b.total.compareTo(a.total));
  return fatias;
}

/// "Pra onde vai" — barras horizontais, do maior pro menor.
///
/// Sem pizza: comparar ângulo é mais difícil que comparar comprimento, e a
/// pergunta aqui é "o que mais pesa".
class PraOndeVai extends StatelessWidget {
  const PraOndeVai({super.key, required this.lancamentos});

  final List<LancamentoRegistro> lancamentos;

  static const _cores = [
    Cores.barro,
    Cores.teal,
    Cores.verde,
    Cores.ambar,
    Cores.vermelho,
  ];

  @override
  Widget build(BuildContext context) {
    final fatias = agruparGastos(lancamentos);
    if (fatias.isEmpty) return const SizedBox.shrink();

    final total = fatias.fold<double>(0, (a, f) => a + f.total);

    return Container(
      padding: const EdgeInsets.all(Medidas.margem),
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(Medidas.raioCartao),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PRA ONDE VAI', style: Tipo.rotulo.copyWith(color: Cores.apoio)),
          const SizedBox(height: 6),
          Text(dinheiro(total), style: Tipo.numeroMedio),
          const SizedBox(height: Medidas.espacoGrande),
          for (var i = 0; i < fatias.length && i < 6; i++)
            _Barra(fatia: fatias[i], cor: _cores[i % _cores.length]),
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.fatia, required this.cor});

  final Fatia fatia;
  final Color cor;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '${fatia.nome}, ${dinheiro(fatia.total)}, '
            '${(fatia.proporcao * 100).round()} por cento',
        child: Padding(
          padding: const EdgeInsets.only(bottom: Medidas.espaco),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      fatia.nome,
                      style: Tipo.corpo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(dinheiro(fatia.total), style: Tipo.corpoForte),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(Medidas.raioBarra),
                child: LinearProgressIndicator(
                  value: fatia.proporcao,
                  minHeight: 8,
                  backgroundColor: Cores.bege,
                  valueColor: AlwaysStoppedAnimation(cor),
                ),
              ),
            ],
          ),
        ),
      );
}
