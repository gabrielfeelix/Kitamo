import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/lancamento_registro.dart';

/// A folha do botão `+`. **Valor primeiro**, como no design: é o que a
/// pessoa tem na cabeça quando abre.
class LancarSheet extends StatefulWidget {
  const LancarSheet({super.key, required this.tipo});

  final TipoLancamento tipo;

  static Future<LancamentoRegistro?> abrir(
    BuildContext context,
    TipoLancamento tipo,
  ) =>
      showModalBottomSheet<LancamentoRegistro>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Cores.creme,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Medidas.raioCartao),
          ),
        ),
        builder: (_) => LancarSheet(tipo: tipo),
      );

  @override
  State<LancarSheet> createState() => _LancarSheetState();
}

class _LancarSheetState extends State<LancarSheet> {
  final _descricao = TextEditingController();
  double? _valor;

  bool get _valido => _valor != null && _valor! > 0 && _descricao.text.trim().isNotEmpty;

  @override
  void dispose() {
    _descricao.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_valido) return;

    Navigator.of(context).pop(LancamentoRegistro(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      descricao: _descricao.text.trim(),
      valor: _valor!,
      tipo: widget.tipo,
      data: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ehEntrada = widget.tipo == TipoLancamento.entrada;

    return Padding(
      padding: EdgeInsets.only(
        left: Medidas.margem,
        right: Medidas.margem,
        top: Medidas.margem,
        bottom: MediaQuery.of(context).viewInsets.bottom + Medidas.margem,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ehEntrada ? 'Recebi' : 'Gastei', style: Tipo.titulo),
          const SizedBox(height: Medidas.espacoGrande),

          TextField(
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: Tipo.numeroGigante.copyWith(fontSize: 40),
            decoration: InputDecoration(
              prefixText: r'R$ ',
              prefixStyle: Tipo.numeroMedio.copyWith(color: Cores.apoio),
              border: InputBorder.none,
              hintText: '0,00',
              hintStyle: Tipo.numeroGigante
                  .copyWith(fontSize: 40, color: Cores.bege),
            ),
            onChanged: (t) => setState(
              () => _valor = double.tryParse(t.replaceAll(',', '.')),
            ),
          ),

          TextField(
            controller: _descricao,
            style: Tipo.corpo,
            decoration: InputDecoration(
              hintText: ehEntrada ? 'de onde veio?' : 'com o quê?',
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
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: Medidas.espacoGrande),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _valido ? _salvar : null,
              style: FilledButton.styleFrom(
                backgroundColor: Cores.tinta,
                foregroundColor: Cores.branco,
                disabledBackgroundColor: Cores.bege,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Medidas.raioPilula),
                ),
              ),
              child: Text('salvar', style: Tipo.corpoForte),
            ),
          ),
        ],
      ),
    );
  }
}
