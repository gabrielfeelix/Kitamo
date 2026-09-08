import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/lancamento_registro.dart';
import '../../repositories/lancamento_repository.dart';
import '../../widgets/pecas.dart';
import '../../widgets/moeda.dart';
import '../../widgets/topo_de_tela.dart';
import 'ofx_parser.dart';

/// A #27 "Importar extrato": o OFX do banco, lido no aparelho.
///
/// A regra que o design deixa explícita, e que é o produto:
/// ***"nada muda até você aplicar"***. A pessoa vê o que foi achado antes
/// de qualquer coisa entrar na conta dela. Importar às cegas, num app de
/// dívida, é o jeito mais rápido de perder a confiança.
///
/// Nada sai do aparelho: o arquivo é lido aqui e nunca enviado.
class ImportarPage extends StatefulWidget {
  const ImportarPage({
    super.key,
    required this.lancamentos,
    this.aoAplicar,
  });

  final LancamentoRepository lancamentos;

  /// Chamado depois de gravar, com quantos entraram.
  final void Function(int quantos)? aoAplicar;

  @override
  State<ImportarPage> createState() => _ImportarPageState();
}

class _ImportarPageState extends State<ImportarPage> {
  List<LancamentoRegistro>? _achados;
  String? _arquivo;
  String? _erro;
  bool _lendo = false;
  bool _aplicando = false;

  Future<void> _escolher() async {
    setState(() {
      _lendo = true;
      _erro = null;
    });

    try {
      final escolhido = await FilePicker.pickFile(
        // OFX é o formato que todo banco brasileiro exporta. Alguns
        // entregam com extensão .txt, por isso ela também entra.
        type: FileType.custom,
        allowedExtensions: const ['ofx', 'OFX', 'txt'],
      );

      final caminho = escolhido?.path;
      if (caminho == null) {
        setState(() => _lendo = false);
        return;
      }

      final conteudo = await File(caminho).readAsString();
      final itens = const OfxParser().ler(conteudo);

      setState(() {
        _achados = itens;
        _arquivo = escolhido!.name;
        _lendo = false;
        _erro = itens.isEmpty
            ? 'não achei lançamento nenhum nesse arquivo. '
                'confere se é o extrato em OFX do seu banco.'
            : null;
      });
    } catch (e) {
      setState(() {
        _lendo = false;
        _erro = 'não consegui ler esse arquivo. '
            'ele precisa ser o extrato em OFX do seu banco.';
      });
    }
  }

  Future<void> _aplicar() async {
    final itens = _achados;
    if (itens == null || itens.isEmpty) return;

    setState(() => _aplicando = true);

    // O parser usa o FITID do banco como id, então reimportar o mesmo
    // extrato atualiza em vez de duplicar. Duplicar gasto num app de
    // dívida é mentir o número pra mais.
    for (final l in itens) {
      await widget.lancamentos.salvar(l);
    }

    if (!mounted) return;
    widget.aoAplicar?.call(itens.length);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final achados = _achados;

    return Scaffold(
      backgroundColor: Cores.creme,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TopoDeTela(titulo: 'importar extrato'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    Medidas.margem, 8, Medidas.margem, Medidas.rodape),
                children: [
                  Text(
                    'o arquivo é lido aqui dentro do celular. '
                    'a gente não pede senha do banco e nada sai daqui.',
                    style: Tipo.corpo.copyWith(color: Cores.apoio),
                  ),
                  const SizedBox(height: 18),

                  if (achados == null) ...[
                    _Passo(
                      numero: '1',
                      titulo: 'pegue o extrato no app do seu banco',
                      apoio: 'procure por "exportar extrato" e escolha OFX. '
                          'quase todo banco tem.',
                    ),
                    const SizedBox(height: 10),
                    _Passo(
                      numero: '2',
                      titulo: 'escolha o arquivo aqui',
                      apoio: 'a gente lê e mostra o que achou.',
                    ),
                    const SizedBox(height: 10),
                    _Passo(
                      numero: '3',
                      titulo: 'confira antes de aplicar',
                      apoio: 'nada muda no seu mês até você mandar aplicar.',
                    ),
                    const SizedBox(height: 22),
                    BotaoPrincipal(
                      rotulo: _lendo ? 'lendo...' : 'escolher arquivo',
                      aoTocar: _lendo ? null : _escolher,
                    ),
                  ] else ...[
                    Text(
                      achados.length == 1
                          ? 'A GENTE ACHOU 1 COISA'
                          : 'A GENTE ACHOU ${achados.length} COISAS',
                      style: Tipo.rotulo.copyWith(color: Cores.apoio),
                    ),
                    if (_arquivo != null) ...[
                      const SizedBox(height: 4),
                      Text(_arquivo!, style: Tipo.apoio),
                    ],
                    const SizedBox(height: 12),
                    for (final l in achados.take(50)) ...[
                      _LinhaAchada(lancamento: l),
                      const SizedBox(height: 8),
                    ],
                    if (achados.length > 50) ...[
                      Text(
                        'e mais ${achados.length - 50}.',
                        style: Tipo.apoio,
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Cores.barroClaro,
                        borderRadius:
                            BorderRadius.circular(Medidas.raioEscolha),
                        border: Border.all(color: Cores.borda, width: 1.5),
                      ),
                      child: Text(
                        'nada muda no seu mês até você aplicar.',
                        style: Tipo.corpoMiudo.copyWith(color: Cores.barro),
                      ),
                    ),
                    const SizedBox(height: 18),
                    BotaoPrincipal(
                      rotulo: _aplicando
                          ? 'aplicando...'
                          : achados.length == 1
                              ? 'aplicar 1'
                              : 'aplicar as ${achados.length}',
                      aoTocar: _aplicando ? null : _aplicar,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: _aplicando
                            ? null
                            : () => setState(() {
                                  _achados = null;
                                  _arquivo = null;
                                }),
                        child: Text(
                          'deixar como está',
                          style: Tipo.corpoForte.copyWith(color: Cores.apoio),
                        ),
                      ),
                    ),
                  ],

                  if (_erro != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBEAE3),
                        borderRadius:
                            BorderRadius.circular(Medidas.raioEscolha),
                      ),
                      child: Text(
                        _erro!,
                        style: Tipo.corpoMiudo
                            .copyWith(color: const Color(0xFF8E3F20)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Passo extends StatelessWidget {
  const _Passo({
    required this.numero,
    required this.titulo,
    required this.apoio,
  });

  final String numero;
  final String titulo;
  final String apoio;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(Medidas.raioLinha),
        boxShadow: Medidas.sombraCartao,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Cores.bege,
              shape: BoxShape.circle,
            ),
            child: Text(numero, style: Tipo.chip),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: Tipo.corpoForte),
                const SizedBox(height: 2),
                Text(apoio, style: Tipo.apoio),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaAchada extends StatelessWidget {
  const _LinhaAchada({required this.lancamento});

  final LancamentoRegistro lancamento;

  @override
  Widget build(BuildContext context) {
    final entrada = lancamento.ehEntrada;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(Medidas.raioLinha),
        boxShadow: Medidas.sombraCartao,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lancamento.descricao,
                  style: Tipo.corpoForte,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'dia ${lancamento.data.day}',
                  style: Tipo.apoio,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${entrada ? '+' : '-'}${dinheiro(lancamento.valor)}',
            style: Tipo.valor.copyWith(
              fontSize: 15,
              color: entrada ? Cores.verde : Cores.tinta,
            ),
          ),
        ],
      ),
    );
  }
}
