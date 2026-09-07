import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/divida.dart';

/// Cadastrar ou editar uma dívida.
///
/// Existe porque sem ela o app é via de mão única: a pessoa cadastra no
/// onboarding e nunca mais consegue corrigir. Dívida muda — renegocia,
/// antecipa, aparece outra.
class EditarDividaPage extends StatefulWidget {
  const EditarDividaPage({super.key, this.original});

  /// Null quando é cadastro novo.
  final Divida? original;

  static Future<Divida?> abrir(BuildContext context, {Divida? original}) =>
      Navigator.of(context).push<Divida>(MaterialPageRoute(
        builder: (_) => EditarDividaPage(original: original),
      ));

  @override
  State<EditarDividaPage> createState() => _EditarDividaPageState();
}

class _EditarDividaPageState extends State<EditarDividaPage> {
  late final TextEditingController _nome;
  late final TextEditingController _parcela;
  late final TextEditingController _restantes;
  late final TextEditingController _vencimento;

  String? _erro;

  bool get _ehNova => widget.original == null;

  @override
  void initState() {
    super.initState();
    final o = widget.original;
    _nome = TextEditingController(text: o?.nome ?? '');
    _parcela = TextEditingController(
        text: o == null ? '' : o.valorParcela.toStringAsFixed(2));
    _restantes =
        TextEditingController(text: o?.parcelasRestantes.toString() ?? '');
    _vencimento =
        TextEditingController(text: o?.diaVencimento.toString() ?? '');
  }

  @override
  void dispose() {
    _nome.dispose();
    _parcela.dispose();
    _restantes.dispose();
    _vencimento.dispose();
    super.dispose();
  }

  void _salvar() {
    final nome = _nome.text.trim();
    if (nome.isEmpty) {
      setState(() => _erro = 'Falta dizer de quem é a dívida.');
      return;
    }

    final dia = int.tryParse(_vencimento.text) ?? 1;
    if (dia < 1 || dia > 31) {
      setState(() => _erro = 'O dia do vencimento vai de 1 a 31.');
      return;
    }

    final parcela = double.tryParse(_parcela.text.replaceAll(',', '.')) ?? 0;
    final restantes = int.tryParse(_restantes.text) ?? 0;
    final o = widget.original;

    // Numa dívida existente o total não muda: ele é o histórico. Só o que
    // falta é editável — senão "7 de 10" viraria mentira.
    final total = o == null
        ? restantes
        : (restantes > o.parcelasTotal ? restantes : o.parcelasTotal);

    Navigator.of(context).pop(Divida(
      id: o?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      nome: nome,
      saldoAtual: parcela * restantes,
      valorParcela: parcela,
      diaVencimento: dia,
      parcelasRestantes: restantes,
      parcelasTotal: total,
      quitadaEm: restantes == 0 ? (o?.quitadaEm ?? DateTime.now()) : null,
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Cores.creme,
        appBar: AppBar(
          backgroundColor: Cores.creme,
          surfaceTintColor: Colors.transparent,
          title: Text(_ehNova ? 'Nova dívida' : 'Editar dívida',
              style: Tipo.subtitulo),
        ),
        body: ListView(
          padding: const EdgeInsets.all(Medidas.margem),
          children: [
            _Campo(
              controlador: _nome,
              rotulo: 'De quem é?',
              dica: 'Nubank, Itaú, crediário…',
            ),
            _Campo(
              controlador: _parcela,
              rotulo: 'Quanto é a parcela?',
              dica: '0,00',
              numerico: true,
              decimal: true,
            ),
            _Campo(
              controlador: _restantes,
              rotulo: 'Quantas faltam?',
              dica: '4',
              numerico: true,
            ),
            _Campo(
              controlador: _vencimento,
              rotulo: 'Vence que dia?',
              dica: '4',
              numerico: true,
            ),
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(top: Medidas.espaco),
                child: Text(_erro!,
                    style: Tipo.corpo.copyWith(color: Cores.vermelho)),
              ),
            const SizedBox(height: Medidas.espacoGrande),
            FilledButton(
              onPressed: _salvar,
              style: FilledButton.styleFrom(
                backgroundColor: Cores.tinta,
                foregroundColor: Cores.branco,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Medidas.raioPilula),
                ),
              ),
              child: Text('salvar', style: Tipo.corpoForte),
            ),
          ],
        ),
      );
}

class _Campo extends StatelessWidget {
  const _Campo({
    required this.controlador,
    required this.rotulo,
    required this.dica,
    this.numerico = false,
    this.decimal = false,
  });

  final TextEditingController controlador;
  final String rotulo;
  final String dica;
  final bool numerico;
  final bool decimal;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Medidas.espacoGrande),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rotulo, style: Tipo.corpoForte),
            const SizedBox(height: 8),
            TextField(
              controller: controlador,
              keyboardType: numerico
                  ? TextInputType.numberWithOptions(decimal: decimal)
                  : TextInputType.text,
              style: Tipo.corpo,
              decoration: InputDecoration(
                hintText: dica,
                hintStyle: Tipo.corpo.copyWith(color: Cores.apoio),
                filled: true,
                fillColor: Cores.branco,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Medidas.raioInterno),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      );
}
