import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Bloqueio do app por biometria.
///
/// Ver que você deve R$ 6 mil não pode estar a um deslize de distância se
/// alguém pega o celular. É **opcional** porque obrigatório trava quem tem
/// aparelho sem biometria — e trancar alguém fora dos próprios dados é pior
/// que o risco que se quer evitar.
class BloqueioService {
  BloqueioService({LocalAuthentication? auth, FlutterSecureStorage? cofre})
      : _auth = auth ?? LocalAuthentication(),
        _cofre = cofre ?? const FlutterSecureStorage();

  final LocalAuthentication _auth;
  final FlutterSecureStorage _cofre;

  static const _chave = 'kitamo_bloqueio_ativo';

  /// A preferência fica no cofre, não em preferências comuns: em
  /// armazenamento simples, quem tem acesso ao aparelho desliga o bloqueio
  /// editando um arquivo.
  Future<bool> estaAtivo() async =>
      (await _cofre.read(key: _chave)) == 'sim';

  Future<bool> disponivel() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Só liga se a pessoa autenticar na hora. Ligar sem provar deixaria o
  /// app trancado para o próprio dono, caso a biometria não funcione.
  Future<bool> ativar() async {
    if (!await disponivel()) return false;

    final ok = await autenticar(motivo: 'Confirme para ativar o bloqueio');
    if (ok) await _cofre.write(key: _chave, value: 'sim');
    return ok;
  }

  Future<void> desativar() => _cofre.delete(key: _chave);

  Future<bool> autenticar({
    String motivo = 'Desbloqueie para ver suas dívidas',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: motivo,
        // Deixa o PIN/padrão do aparelho servir também: exigir só
        // biometria exclui quem não cadastrou digital.
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException {
      // Sem biometria configurada, sem hardware, ou cancelado.
      return false;
    }
  }
}
