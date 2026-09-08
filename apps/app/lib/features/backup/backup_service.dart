import 'dart:convert';

import '../../models/divida.dart';
import '../../models/perfil_financeiro.dart';
import '../../repositories/divida_repository.dart';
import '../../repositories/perfil_repository.dart';

/// Erro ao ler um backup. A mensagem é para o usuário ler, não para log.
class BackupInvalido implements Exception {
  const BackupInvalido(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Backup por arquivo — exportar e trazer de volta.
///
/// É a alternativa a servidor: os dados ficam no celular, e o backup é um
/// arquivo que a pessoa guarda onde quiser. Menos infraestrutura, menos
/// superfície de ataque, e nenhum dado de dívida trafegando ou parado em
/// servidor nosso.
///
/// O arquivo sai em claro de propósito: é a pessoa quem decide onde
/// guardar, e um backup que ela não consegue abrir não é backup. Isso
/// precisa estar dito na tela — ver [avisoDeExportacao].
class BackupService {
  const BackupService(this._perfis, this._dividas);

  final PerfilRepository _perfis;
  final DividaRepository _dividas;

  /// Versão do formato. Existe desde o começo para que um backup antigo
  /// possa ser lido por uma versão futura do app.
  static const versaoFormato = 1;

  static const avisoDeExportacao =
      'O arquivo tem seus valores em texto legível. Guarde num lugar que '
      'só você acessa.';

  Future<String> exportar({DateTime? em}) async {
    final perfil = await _perfis.carregar();
    final todas = await _dividas.todas();

    return const JsonEncoder.withIndent('  ').convert({
      'versao': versaoFormato,
      'exportado_em': (em ?? DateTime.now()).toIso8601String(),
      'perfil': perfil == null
          ? null
          : {
              'renda_mensal': perfil.rendaMensal,
              'dia_renda': perfil.diaRenda,
              'gasto_diario': perfil.gastoDiarioEstimado,
              'contas_fixas': perfil.contasFixasEstimadas,
              'origem': perfil.origem.name,
            },
      'dividas': [
        for (final d in todas)
          {
            'id': d.id,
            'nome': d.nome,
            'saldo': d.saldoAtual,
            'parcela': d.valorParcela,
            'dia_vencimento': d.diaVencimento,
            'parcelas_restantes': d.parcelasRestantes,
            'parcelas_total': d.parcelasTotal,
            'quitada_em': d.quitadaEm?.toIso8601String(),
          },
      ],
    });
  }

  /// Lê um backup e substitui o que existe.
  ///
  /// Valida antes de gravar qualquer coisa: um arquivo corrompido não pode
  /// deixar o app com metade dos dados novos e metade dos antigos.
  Future<int> importar(String conteudo) async {
    final Map<String, dynamic> dados;

    try {
      final decodificado = jsonDecode(conteudo);
      if (decodificado is! Map<String, dynamic>) {
        throw const BackupInvalido('Esse arquivo não é um backup da Kitamo.');
      }
      dados = decodificado;
    } on FormatException {
      throw const BackupInvalido('Esse arquivo não é um backup da Kitamo.');
    }

    final versao = dados['versao'];
    if (versao is! int) {
      throw const BackupInvalido('Esse arquivo não é um backup da Kitamo.');
    }
    if (versao > versaoFormato) {
      throw const BackupInvalido(
        'Esse backup é de uma versão mais nova do app. Atualize para abrir.',
      );
    }

    final brutas = dados['dividas'];
    if (brutas is! List) {
      throw const BackupInvalido('O backup está incompleto.');
    }

    // Converte tudo primeiro. Se algo estiver corrompido, falha aqui —
    // antes de ter escrito qualquer coisa no banco.
    final dividas = brutas.map(_lerDivida).toList();
    final perfil = _lerPerfil(dados['perfil']);

    if (perfil != null) await _perfis.salvar(perfil);

    for (final d in await _dividas.todas()) {
      await _dividas.remover(d.id);
    }
    for (final d in dividas) {
      await _dividas.salvar(d);
    }

    return dividas.length;
  }

  Divida _lerDivida(dynamic bruta) {
    if (bruta is! Map) throw const BackupInvalido('O backup está corrompido.');

    final nome = bruta['nome'];
    if (nome is! String || nome.isEmpty) {
      throw const BackupInvalido('O backup tem uma dívida sem nome.');
    }

    return Divida(
      id: bruta['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      nome: nome,
      saldoAtual: _numero(bruta['saldo']),
      valorParcela: _numero(bruta['parcela']),
      diaVencimento: _inteiro(bruta['dia_vencimento'], padrao: 1).clamp(1, 31),
      parcelasRestantes: _inteiro(bruta['parcelas_restantes']),
      parcelasTotal: _inteiro(bruta['parcelas_total']),
      quitadaEm: _data(bruta['quitada_em']),
    );
  }

  PerfilFinanceiro? _lerPerfil(dynamic bruto) {
    if (bruto == null) return null;
    if (bruto is! Map) throw const BackupInvalido('O backup está corrompido.');

    return PerfilFinanceiro(
      rendaMensal: _numeroNulo(bruto['renda_mensal']),
      diaRenda: bruto['dia_renda'] is num
          ? (bruto['dia_renda'] as num).toInt().clamp(1, 31)
          : null,
      gastoDiarioEstimado: _numeroNulo(bruto['gasto_diario']),
      contasFixasEstimadas: _numeroNulo(bruto['contas_fixas']),
      origem: OrigemPerfil.values.firstWhere(
        (o) => o.name == bruto['origem'],
        orElse: () => OrigemPerfil.feeling,
      ),
    );
  }

  double _numero(dynamic v) => v is num ? v.toDouble() : 0;
  double? _numeroNulo(dynamic v) => v is num ? v.toDouble() : null;
  int _inteiro(dynamic v, {int padrao = 0}) => v is num ? v.toInt() : padrao;
  DateTime? _data(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}
