import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/lancamento_registro.dart';
import '../../repositories/lancamento_repository.dart';
import '../../widgets/moeda.dart';
import 'pra_onde_vai.dart';

/// A lista do que entrou e saiu, com os chips do design.
class LancamentosPage extends StatefulWidget {
  const LancamentosPage({super.key, required this.repositorio});

  final LancamentoRepository repositorio;

  @override
  State<LancamentosPage> createState() => _LancamentosPageState();
}

class _LancamentosPageState extends State<LancamentosPage> {
  FiltroLancamento _filtro = FiltroLancamento.todos;

  static const _rotulos = {
    FiltroLancamento.todos: 'Todos',
    FiltroLancamento.entradas: 'Entradas',
    FiltroLancamento.saidas: 'Saídas',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Cores.creme,
        appBar: AppBar(
          backgroundColor: Cores.creme,
          surfaceTintColor: Colors.transparent,
          title: Text('Lançamentos', style: Tipo.subtitulo),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: Medidas.margem),
                children: [
                  for (final f in FiltroLancamento.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_rotulos[f]!),
                        selected: _filtro == f,
                        onSelected: (_) => setState(() => _filtro = f),
                        selectedColor: Cores.teal,
                        backgroundColor: Cores.branco,
                        labelStyle: Tipo.corpo.copyWith(
                          color: _filtro == f ? Cores.branco : Cores.tinta,
                        ),
                        side: BorderSide.none,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<LancamentoRegistro>>(
                stream: widget.repositorio.observar(filtro: _filtro),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final itens = snap.data!;
                  if (itens.isEmpty) return const _Vazio();

                  return ListView(
                    padding: const EdgeInsets.all(Medidas.margem),
                    children: [
                      if (_filtro != FiltroLancamento.entradas) ...[
                        PraOndeVai(lancamentos: itens),
                        const SizedBox(height: Medidas.espacoGrande),
                      ],
                      for (final l in itens)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _Item(lancamento: l),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
}

class _Item extends StatelessWidget {
  const _Item({required this.lancamento});

  final LancamentoRegistro lancamento;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Cores.branco,
          borderRadius: BorderRadius.circular(Medidas.raioInterno),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lancamento.descricao, style: Tipo.corpoForte),
                  Text(
                    '${lancamento.data.day}/${lancamento.data.month}',
                    style: Tipo.apoio,
                  ),
                ],
              ),
            ),
            Text(
              '${lancamento.ehEntrada ? '+' : '−'} '
              '${dinheiro(lancamento.valor)}',
              style: Tipo.corpoForte.copyWith(
                color: lancamento.ehEntrada ? Cores.verde : Cores.tinta,
              ),
            ),
          ],
        ),
      );
}

/// Vazio com o pássaro e um caminho — nunca "nenhum registro encontrado".
class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/joao-avatar.png', height: 100),
            const SizedBox(height: Medidas.espaco),
            Text('nada lançado ainda', style: Tipo.corpo),
            const SizedBox(height: 4),
            Text('toque no + pra começar', style: Tipo.apoio),
          ],
        ),
      );
}
