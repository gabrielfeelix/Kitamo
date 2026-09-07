import '../../models/divida.dart';
import '../../models/perfil_financeiro.dart';
import '../../repositories/divida_repository.dart';
import '../../services/diario_service.dart';
import 'quitacao_resultado.dart';

/// Marcar parcela como paga — o hábito do app.
///
/// Mede a data de quitação antes e depois porque antecipar precisa dar
/// retorno visível: "agora é dezembro, não janeiro" é o que faz a pessoa
/// querer antecipar de novo.
class QuitarService {
  const QuitarService(this._dividas);

  final DividaRepository _dividas;

  Future<QuitacaoResultado?> quitarParcela(
    String id, {
    PerfilFinanceiro? perfil,
    DateTime? em,
  }) async {
    final antes = await _dividas.emAberto();
    final quitacaoAntes = _previsao(antes, perfil);

    final atualizada = await _dividas.quitarParcela(id, em: em);
    if (atualizada == null) return null;

    final depois = await _dividas.emAberto();

    return QuitacaoResultado(
      divida: atualizada,
      quitacaoAntes: quitacaoAntes,
      quitacaoDepois: _previsao(depois, perfil),
    );
  }

  DateTime? _previsao(List<Divida> dividas, PerfilFinanceiro? perfil) =>
      const DiarioService()
          .calcular(perfil: perfil, dividas: dividas)
          .quitacaoEm;
}
