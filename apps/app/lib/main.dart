import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/banco.dart';
import 'repositories/divida_repository.dart';
import 'repositories/lancamento_repository.dart';
import 'repositories/perfil_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A data por extenso do cabeçalho ("quarta, 6 de setembro") depende
  // disto. Sem inicializar, DateFormat com locale pt_BR lança em runtime —
  // e runtime é o celular do Gabriel, não o teste.
  await initializeDateFormatting('pt_BR');

  final banco = await abrirBanco();

  runApp(KitamoApp(
    perfis: PerfilRepositoryDrift(banco),
    dividas: DividaRepositoryDrift(banco),
    lancamentos: LancamentoRepositoryDrift(banco),
  ));
}
