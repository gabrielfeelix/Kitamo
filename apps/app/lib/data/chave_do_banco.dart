import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda a chave do banco cifrado.
///
/// A chave vive no Keychain (iOS) / Keystore (Android), que usam o enclave
/// de hardware quando o aparelho tem. Nunca em arquivo, nunca no código:
/// todo APK é descompilável, então segredo em código é segredo público.
class ChaveDoBanco {
  ChaveDoBanco([FlutterSecureStorage? cofre])
      : _cofre = cofre ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _cofre;

  static const _chaveNoCofre = 'kitamo_db_key_v1';

  /// Devolve a chave, criando uma na primeira vez.
  ///
  /// Se ela sumir (o usuário limpou os dados do app), o banco antigo fica
  /// ilegível — e é isso mesmo que tem que acontecer. Dado cifrado sem
  /// chave é dado destruído, que é a garantia que a cifra oferece.
  Future<String> obter() async {
    final existente = await _cofre.read(key: _chaveNoCofre);
    if (existente != null && existente.isNotEmpty) return existente;

    final nova = _gerar();
    await _cofre.write(key: _chaveNoCofre, value: nova);
    return nova;
  }

  /// 32 bytes de `Random.secure()` — o gerador do sistema operacional.
  /// `Random()` comum é previsível e não serve para chave.
  String _gerar() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
    return base64UrlEncode(bytes);
  }

  Future<void> apagar() => _cofre.delete(key: _chaveNoCofre);
}
