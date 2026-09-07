import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../models/divida.dart';
import '../../models/perfil_financeiro.dart';
import '../../repositories/divida_repository.dart';
import '../../repositories/perfil_repository.dart';

/// As faixas da pergunta "quanto você deve hoje?", do design.
/// Existem porque muita gente endividada não sabe o número exato — e
/// travar a primeira tela num campo obrigatório é perder a pessoa ali.
enum FaixaDeDivida {
  ate5mil('até R\$ 5 mil', 2500),
  entre10e15('entre R\$ 10 e R\$ 15 mil', 12500),
  maisDe20('mais de R\$ 20 mil', 25000),
  naoSei('não sei, quero descobrir', null);

  const FaixaDeDivida(this.rotulo, this.meio);

  final String rotulo;

  /// O meio da faixa, que vira o chute inicial. null em "não sei".
  final double? meio;
}

/// Uma dívida sendo digitada. Só vira registro se tiver nome.
class RascunhoDivida {
  RascunhoDivida();

  String nome = '';
  double? parcela;
  int? restantes;
  int? diaVencimento;

  bool get preenchida => nome.trim().isNotEmpty;
}

/// "UMA PERGUNTA POR TELA · CADA UMA NA SUA COR".
///
/// As cores, as ilustrações e os textos são os do Kitamo App.dc.html,
/// telas 02 a 07. Não invente pergunta nova nem troque a cor: a sequência
/// de cores é o que dá ritmo ao onboarding.
enum PassoOnboarding {
  /// A primeira, e de propósito a mais fácil.
  ///
  /// O Início abre com "bom dia, Gabriel" e o app nunca perguntava o
  /// nome — dava bom dia para alguém que ele não conhecia. Começar por
  /// aqui também aquece: responder o próprio nome é mais fácil que
  /// encarar "quanto você deve".
  nome(
    cor: Color(0xFF0C7468),
    ilustracao: 'joao.png',
    pergunta: 'como a gente te chama?',
    apoio: 'só pra deixar seu, nada sai daqui do celular.',
  ),
  divida(
    cor: Color(0xFF0B5F59),
    ilustracao: 'ob-divida.png',
    pergunta: 'qual o total das suas dívidas?',
    apoio: 'cartão, empréstimo, crediário. tudo somado. '
        'pode ser chute: a gente ajusta depois com o extrato.',
  ),
  renda(
    cor: Color(0xFF3F7A3D),
    ilustracao: 'ob-entrada.png',
    pergunta: 'quanto você recebe por mês?',
    apoio: 'salário, bico, pensão, aluguel que você recebe. tudo que entra.',
  ),
  diaRenda(
    cor: Color(0xFF6B58B0),
    ilustracao: 'ob-calendario.png',
    pergunta: 'qual o dia do seu pagamento?',
    apoio: 'o dia do mês em que o salário cai na sua conta.',
  ),
  gasto(
    cor: Color(0xFFE8A33D),
    ilustracao: 'ob-mercado.png',
    pergunta: 'qual o seu gasto por mês?',
    apoio: 'mercado, padaria, iFood, transporte. vai no feeling: '
        'a gente confere no extrato depois.',
  ),
  fixas(
    cor: Color(0xFFA34A24),
    ilustracao: 'ob-fixas.png',
    pergunta: 'quanto somam suas contas fixas?',
    apoio: 'aluguel, luz, água, internet, assinatura. '
        'o que sai todo mês no mesmo dia.',
  ),
  extrato(
    cor: Color(0xFF9E4522),
    ilustracao: 'ob-extrato.png',
    pergunta: 'quer conferir com o seu extrato?',
    apoio: 'o arquivo do seu banco, lido aqui dentro do celular. '
        'a gente não pede senha e nada sai daqui.',
  );

  const PassoOnboarding({
    required this.cor,
    required this.ilustracao,
    required this.pergunta,
    required this.apoio,
  });

  /// Cada passo tem sua cor — a tela inteira, como no design.
  final Color cor;
  final String ilustracao;
  final String pergunta;
  final String apoio;

  /// O âmbar é claro demais para texto branco.
  Color get sobre => this == PassoOnboarding.gasto ? Cores.tinta : Cores.branco;

  /// Texto de apoio sobre o acento: quase branco, mas não branco puro.
  Color get sobreFraco =>
      this == PassoOnboarding.gasto ? const Color(0xFF3F2E0F) : const Color(0xFFE6F7F4);
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

  /// O dia em que o dinheiro entra.
  ///
  /// Tem setter de verdade porque a tela precisa se redesenhar na hora do
  /// toque: como campo solto, tocar no dia gravava o valor e não pintava
  /// nada, e a pessoa achava que o botão não funcionava. Foi o Gabriel que
  /// pegou, em 07/09/2026.
  int? get diaRenda => _diaRenda;
  set diaRenda(int? v) {
    if (_diaRenda == v) return;
    _diaRenda = v;
    notifyListeners();
  }

  int? _diaRenda;

  /// Quanto a pessoa deve no total. É a pergunta 02 do design: um número
  /// grande, "pode ser chute". O cadastro detalhado de cada dívida vem
  /// depois, no Perfil — pedir isso na primeira tela é o que fazia a
  /// pessoa desistir.
  double? totalDevido;

  /// A faixa escolhida, quando ela prefere não digitar um número.
  FaixaDeDivida? faixa;
  double? gastoDiario;
  double? contasFixas;

  /// Como a pessoa quer ser chamada.
  ///
  /// O Início abre com "bom dia, Gabriel", e até 07/09 o app **nunca
  /// perguntava** — só dava pra editar no Perfil, depois. Dar bom dia com
  /// um nome que ninguém informou é o app fingindo que conhece a pessoa.
  String? get nome => _nome;
  set nome(String? v) {
    if (_nome == v) return;
    _nome = v;
    notifyListeners();
  }

  String? _nome;

  /// Em quantas vezes a dívida está dividida. **Null é "não sei"**, e é
  /// resposta legítima.
  ///
  /// Até 07/09 o app inventava 12 parcelas para quem só informou o total,
  /// e a tela mostrava "0 de 12" numa dívida de 4 meses — palpite com cara
  /// de fato conferido. Sem esta resposta, o app não mostra contagem
  /// nenhuma.
  int? get parcelasDoTotal => _parcelasDoTotal;
  set parcelasDoTotal(int? v) {
    if (_parcelasDoTotal == v) return;
    _parcelasDoTotal = v;
    notifyListeners();
  }

  int? _parcelasDoTotal;

  /// Por onde a pessoa entrou, quando ela veio pelo "já tenho conta".
  /// Null é o caminho normal: sem conta, tudo no aparelho.
  ProvedorDeLogin? provedor;
  String? email;

  final List<RascunhoDivida> rascunhos = [RascunhoDivida()];

  int get indice => _indice;
  bool get salvando => _salvando;
  PassoOnboarding get passo => PassoOnboarding.values[_indice];
  bool get ehUltimo => _indice == PassoOnboarding.values.length - 1;
  double get progresso => (_indice + 1) / PassoOnboarding.values.length;

  /// Guarda o login social escolhido, para gravar junto com o perfil no
  /// fim do onboarding. **Não há servidor** — isto é só o que a tela do
  /// perfil mostra depois.
  void entrouCom(ProvedorDeLogin p, {String? email}) {
    provedor = p;
    this.email = email;
    notifyListeners();
  }

  void adicionarDivida() {
    rascunhos.add(RascunhoDivida());
    notifyListeners();
  }

  void removerDivida(int i) {
    if (rascunhos.length <= 1) return;
    rascunhos.removeAt(i);
    notifyListeners();
  }

  /// Escolher uma faixa preenche o total pelo meio dela. "não sei" deixa
  /// o total em aberto: é resposta válida, não campo vazio.
  void escolherFaixa(FaixaDeDivida f) {
    faixa = f;
    totalDevido = f.meio;
    notifyListeners();
  }

  void digitarTotal(double? v) {
    totalDevido = v;
    // Digitar um número desmarca a faixa: quem digitou sabe o valor.
    faixa = null;
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
        nome: (nome?.trim().isEmpty ?? true) ? null : nome!.trim(),
        rendaMensal: rendaMensal,
        diaRenda: diaRenda,
        gastoDiarioEstimado: gastoDiario,
        contasFixasEstimadas: contasFixas,
        provedor: provedor,
        email: email,
      ));

      // Quem respondeu só o total ganha uma dívida única, sem nome de
      // banco: o número dela é o que faz a conta fechar na tela de Início.
      final semDetalhe = !rascunhos.any((r) => r.preenchida);
      if (!naoSeiQuantoDevo && semDetalhe && (totalDevido ?? 0) > 0) {
        // **Não inventa parcela.** Até 07/09 isto espalhava o total em 12
        // meses e a tela mostrava "0 de 12" numa dívida de 4 — palpite com
        // cara de fato. Quando ela não sabe em quantas vezes, o app grava
        // zero parcelas e a tela não mostra contagem nenhuma: campo vazio
        // é melhor que número falso.
        final vezes = parcelasDoTotal ?? 0;

        await _dividas.salvar(Divida(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          nome: 'o que eu devo',
          saldoAtual: totalDevido!,
          valorParcela: vezes > 0 ? totalDevido! / vezes : 0,
          diaVencimento: 1,
          parcelasRestantes: vezes,
          parcelasTotal: vezes,
        ));
      }

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
