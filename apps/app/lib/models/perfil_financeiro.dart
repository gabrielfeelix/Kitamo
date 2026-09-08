/// As respostas do onboarding.
///
/// [origem] diz se os números vieram de chute ou de extrato — muda a
/// confiança que o app pode ter neles.
enum OrigemPerfil { feeling, ofx }

/// Por onde a pessoa entrou.
///
/// **Não existe servidor.** O login social é só a tela, decisão do Gabriel
/// em 07/09/2026: as 10 pessoas do teste veem o fluxo, e o backend só vem
/// depois que valer a pena. Nada sai do aparelho.
enum ProvedorDeLogin {
  google('Google'),
  facebook('Facebook');

  const ProvedorDeLogin(this.nome);

  final String nome;
}

class PerfilFinanceiro {
  const PerfilFinanceiro({
    this.nome,
    this.rendaMensal,
    this.diaRenda,
    this.gastoDiarioEstimado,
    this.contasFixasEstimadas,
    this.origem = OrigemPerfil.feeling,
    this.avatar,
    this.provedor,
    this.email,
  });

  /// Como a pessoa quer ser chamada. O design abre o Início com
  /// "bom dia, Gabriel" — sem isso o cabeçalho fica sem dono.
  /// Nulo é aceito: aí o app só diz "bom dia".
  final String? nome;

  final double? rendaMensal;
  final int? diaRenda;
  final double? gastoDiarioEstimado;
  final double? contasFixasEstimadas;
  final OrigemPerfil origem;

  /// O passarinho escolhido: 'av-1' a 'av-8'. Ver [avatarOuPadrao].
  final String? avatar;

  /// Nulo quando a pessoa entrou sem conta.
  final ProvedorDeLogin? provedor;

  final String? email;

  bool get veioDeExtrato => origem == OrigemPerfil.ofx;

  /// O acervo do joão tem 8 passarinhos. Sem escolha, fica o primeiro.
  String get avatarOuPadrao => avatar ?? avatares.first;

  /// Os 8 arquivos de "O ACERVO DO JOÃO", na ordem em que o design os
  /// mostra na grade de 4 colunas.
  static const avatares = [
    'av-1',
    'av-2',
    'av-3',
    'av-4',
    'av-5',
    'av-6',
    'av-7',
    'av-8',
  ];

  /// O `??` de sempre não serve pra apagar: passar `nome: null` cairia no
  /// valor antigo. Quem quer limpar o nome usa [limparNome] — é o caso de
  /// quem esvazia o campo em "Editar perfil".
  PerfilFinanceiro copyWith({
    String? nome,
    double? rendaMensal,
    int? diaRenda,
    double? gastoDiarioEstimado,
    double? contasFixasEstimadas,
    OrigemPerfil? origem,
    String? avatar,
    ProvedorDeLogin? provedor,
    String? email,
    bool limparNome = false,
  }) =>
      PerfilFinanceiro(
        nome: limparNome ? null : (nome ?? this.nome),
        rendaMensal: rendaMensal ?? this.rendaMensal,
        diaRenda: diaRenda ?? this.diaRenda,
        gastoDiarioEstimado: gastoDiarioEstimado ?? this.gastoDiarioEstimado,
        contasFixasEstimadas:
            contasFixasEstimadas ?? this.contasFixasEstimadas,
        origem: origem ?? this.origem,
        avatar: avatar ?? this.avatar,
        provedor: provedor ?? this.provedor,
        email: email ?? this.email,
      );
}
