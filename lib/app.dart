import 'package:flutter/material.dart';

import 'design/cores.dart';
import 'design/tipografia.dart';
import 'features/backup/backup_service.dart';
import 'features/casca/casca.dart';
import 'features/onboarding/onboarding_controller.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/quitar/quitar_service.dart';
import 'features/quitar/quitei_essa_page.dart';
import 'features/seguranca/bloqueio_service.dart';
import 'repositories/lancamento_repository.dart';
import 'models/divida.dart';
import 'models/perfil_financeiro.dart';
import 'repositories/divida_repository.dart';
import 'repositories/perfil_repository.dart';

class KitamoApp extends StatelessWidget {
  const KitamoApp({
    super.key,
    required this.perfis,
    required this.dividas,
    required this.lancamentos,
  });

  final PerfilRepository perfis;
  final DividaRepository dividas;
  final LancamentoRepository lancamentos;

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
      home: Raiz(perfis: perfis, dividas: dividas, lancamentos: lancamentos),
    );
  }
}

/// Decide entre onboarding e início.
///
/// Sem perfil não há número, e a tela sem número não diz nada — então quem
/// nunca respondeu vai direto para o onboarding.
class Raiz extends StatefulWidget {
  const Raiz({
    super.key,
    required this.perfis,
    required this.dividas,
    required this.lancamentos,
  });

  final PerfilRepository perfis;
  final DividaRepository dividas;
  final LancamentoRepository lancamentos;

  @override
  State<Raiz> createState() => _RaizState();
}

class _RaizState extends State<Raiz> {
  bool? _precisaOnboarding;
  bool _destrancado = false;
  final _bloqueio = BloqueioService();

  @override
  void initState() {
    super.initState();
    _verificar();
  }

  Future<void> _verificar() async {
    // O bloqueio vem antes de qualquer dado aparecer na tela.
    final trancado = await _bloqueio.estaAtivo();
    final destrancado = !trancado || await _bloqueio.autenticar();

    final precisa = await widget.perfis.precisaOnboarding();

    if (mounted) {
      setState(() {
        _destrancado = destrancado;
        _precisaOnboarding = precisa;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final precisa = _precisaOnboarding;

    if (precisa == null) return const _Carregando();
    if (!_destrancado) return _Trancado(aoTentar: _verificar);

    if (precisa) {
      return OnboardingPage(
        controller: OnboardingController(
          perfis: widget.perfis,
          dividas: widget.dividas,
        ),
        aoConcluir: () => setState(() => _precisaOnboarding = false),
      );
    }

    return _CarregarInicio(
      perfis: widget.perfis,
      dividas: widget.dividas,
      lancamentos: widget.lancamentos,
    );
  }
}

class _CarregarInicio extends StatelessWidget {
  const _CarregarInicio({
    required this.perfis,
    required this.dividas,
    required this.lancamentos,
  });

  final PerfilRepository perfis;
  final DividaRepository dividas;
  final LancamentoRepository lancamentos;

  /// Marca a parcela como paga e leva para a tela de conquista.
  Future<void> _quitar(
    BuildContext context,
    Divida divida,
    PerfilFinanceiro? perfil,
  ) async {
    final navegador = Navigator.of(context);
    final resultado =
        await QuitarService(dividas).quitarParcela(divida.id, perfil: perfil);

    if (resultado == null) return;

    await navegador.push(MaterialPageRoute(
      builder: (_) => QuiteiEssaPage(resultado: resultado),
    ));
  }

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<List<Divida>>(
        stream: dividas.observarEmAberto(),
        builder: (context, snapDividas) => StreamBuilder<PerfilFinanceiro?>(
          stream: perfis.observar(),
          builder: (context, snapPerfil) {
            if (!snapDividas.hasData || snapPerfil.connectionState ==
                ConnectionState.waiting) {
              return const _Carregando();
            }

            return Casca(
              perfil: snapPerfil.data,
              dividas: snapDividas.data ?? const [],
              lancamentos: lancamentos,
              backup: BackupService(perfis, dividas),
              bloqueio: BloqueioService(),
              aoQuitar: (d) => _quitar(context, d, snapPerfil.data),
            );
          },
        ),
      );
}

/// Carregando com o verbo da marca — nunca um spinner nu.
class _Carregando extends StatelessWidget {
  const _Carregando();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Cores.creme,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/joao-avatar.png', height: 96),
              const SizedBox(height: 16),
              Text('somando as parcelas…', style: Tipo.corpo),
            ],
          ),
        ),
      );
}


/// Tela de app trancado. Sem dado nenhum visível.
class _Trancado extends StatelessWidget {
  const _Trancado({required this.aoTentar});

  final VoidCallback aoTentar;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Cores.creme,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/joao-avatar.png', height: 96),
              const SizedBox(height: 16),
              Text('a Kitamo está trancada', style: Tipo.corpo),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: aoTentar,
                style: FilledButton.styleFrom(
                  backgroundColor: Cores.tinta,
                  foregroundColor: Cores.branco,
                ),
                child: Text('desbloquear', style: Tipo.corpoForte),
              ),
            ],
          ),
        ),
      );
}
