import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../models/divida.dart';
import '../../models/perfil_financeiro.dart';
import '../../repositories/divida_repository.dart';
import '../../repositories/perfil_repository.dart';

/// Uma dívida sendo digitada. Só vira registro se tiver nome.
class RascunhoDivida {
  RascunhoDivida();

  String nome = '';
  double? parcela;
  int? restantes;
  int? diaVencimento;

  bool get preenchida => nome.trim().isNotEmpty;
}

enum PassoOnboarding {
  divida(Cores.vermelho),
  renda(Cores.verde),
  diaRenda(Cores.tealEscuro),
  gasto(Cores.ambar),
  fixas(Cores.barro),
  extrato(Cores.verde);

  const PassoOnboarding(this.cor);

  /// Cada passo tem sua cor — a tela inteira, como no design.
  final Color cor;

  /// O âmbar é claro demais para texto branco.
  Color get sobre => this == PassoOnboarding.gasto ? Cores.tinta : Cores.branco;
}

/// Estado do onboarding.
///
/// Regra do produto: **tudo é pulável.** Quem pula tudo chega ao fim com um
/// número incompleto, não com o app travado. Pedir dado obrigatório antes
/// de mostrar valor é a maior fonte de abandono num app financeiro.
class OnboardingController extends ChangeNotifier {
  OnboardingController({
    required PerfilRepository perfis,
    required DividaRepository dividas,
  })  : _perfis = perfis,
        _dividas = dividas;

  final PerfilRepository _perfis;
  final DividaRepository _dividas;
  // ignore_for_file: prefer_initializing_formals

  int _indice = 0;
  bool _salvando = false;
  bool naoSeiQuantoDevo = false;

  double? rendaMensal;
  int? diaRenda;
  double? gastoDiario;
  double? contasFixas;

  final List<RascunhoDivida> rascunhos = [RascunhoDivida()];

  int get indice => _indice;
  bool get salvando => _salvando;
  PassoOnboarding get passo => PassoOnboarding.values[_indice];
  bool get ehUltimo => _indice == PassoOnboarding.values.length - 1;
  double get progresso => (_indice + 1) / PassoOnboarding.values.length;

  void adicionarDivida() {
    rascunhos.add(RascunhoDivida());
    notifyListeners();
  }

  void removerDivida(int i) {
    if (rascunhos.length <= 1) return;
    rascunhos.removeAt(i);
    notifyListeners();
  }

  void alternarNaoSei() {
    naoSeiQuantoDevo = !naoSeiQuantoDevo;
    notifyListeners();
  }

  void avancar() {
    if (ehUltimo) return;
    _indice++;
    notifyListeners();
  }

  void voltar() {
    if (_indice == 0) return;
    _indice--;
    notifyListeners();
  }

  /// Grava o que foi respondido. Campo pulado vira null, não zero:
  /// zero é uma resposta ("não tenho conta fixa"), null é "não respondeu".
  /// Confundir os dois faria o app calcular com dado inventado.
  Future<void> concluir() async {
    if (_salvando) return;
    _salvando = true;
    notifyListeners();

    try {
      await _perfis.salvar(PerfilFinanceiro(
        rendaMensal: rendaMensal,
        diaRenda: diaRenda,
        gastoDiarioEstimado: gastoDiario,
        contasFixasEstimadas: contasFixas,
      ));

      if (!naoSeiQuantoDevo) {
        for (final r in rascunhos.where((r) => r.preenchida)) {
          final restantes = r.restantes ?? 0;

          await _dividas.salvar(Divida(
            id: DateTime.now().microsecondsSinceEpoch.toString() + r.nome,
            nome: r.nome.trim(),
            // Saldo estimado pelo que falta pagar. É o que a pessoa sabe
            // responder: ela conhece a parcela, não o saldo devedor exato.
            saldoAtual: (r.parcela ?? 0) * restantes,
            valorParcela: r.parcela ?? 0,
            diaVencimento: r.diaVencimento ?? 1,
            parcelasRestantes: restantes,
            parcelasTotal: restantes,
          ));
        }
      }
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }
}
