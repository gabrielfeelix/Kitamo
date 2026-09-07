import 'package:flutter/material.dart';

import 'app.dart';
import 'data/banco.dart';
import 'repositories/divida_repository.dart';
import 'repositories/perfil_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final banco = await abrirBanco();

  runApp(KitamoApp(
    perfis: PerfilRepositoryDrift(banco),
    dividas: DividaRepositoryDrift(banco),
  ));
}
