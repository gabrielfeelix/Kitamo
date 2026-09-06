import 'package:flutter/material.dart';

import 'design/cores.dart';
import 'design/tipografia.dart';
import 'features/inicio/inicio_page.dart';
import 'models/divida.dart';
import 'models/perfil_financeiro.dart';

void main() => runApp(const KitamoApp());

class KitamoApp extends StatelessWidget {
  const KitamoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);

    return MaterialApp(
      title: 'Kitamo',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: Cores.creme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Cores.teal,
          primary: Cores.teal,
          surface: Cores.creme,
        ),
        textTheme: Tipo.tema(base.textTheme).apply(
          bodyColor: Cores.tinta,
          displayColor: Cores.tinta,
        ),
      ),
      home: InicioPage(perfil: _perfilExemplo, dividas: _dividasExemplo),
    );
  }
}

// Dados de exemplo enquanto a persistência não existe. São os números reais
// do Gabriel, que é o caso que o app precisa resolver primeiro.
const _perfilExemplo = PerfilFinanceiro(
  rendaMensal: 3650,
  diaRenda: 6,
  gastoDiarioEstimado: 40,
  contasFixasEstimadas: 914,
);

final _dividasExemplo = [
  Divida(
    id: '1',
    nome: 'Nubank',
    saldoAtual: 6136.24,
    valorParcela: 1534.06,
    diaVencimento: 4,
    parcelasRestantes: 4,
    parcelasTotal: 10,
  ),
];
