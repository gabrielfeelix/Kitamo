import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A voz da Kitamo, do design system: "minúscula nos títulos de tela,
/// segunda pessoa, número primeiro, frase curta depois. **Sem travessão,
/// sem emoji, sem culpa.**"
///
/// Estes testes leem o código-fonte porque a regra vale pra toda string que
/// chega na tela, não pra uma tela específica. O travessão já tinha entrado
/// duas vezes sem ninguém notar.
void main() {
  final fontes = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart'));

  /// Só o que a pessoa lê. Ficam de fora: comentário, doc, e mensagem de
  /// @Deprecated — essa é recado pra quem programa, não texto de tela.
  Iterable<String> textosDe(File f) sync* {
    for (final linha in f.readAsLinesSync()) {
      final limpa = linha.trim();
      if (limpa.startsWith('//')) continue;
      if (limpa.startsWith('@Deprecated')) continue;
      for (final m in RegExp(r"'([^']{4,})'").allMatches(limpa)) {
        yield m.group(1)!;
      }
    }
  }

  test('sem travessão: a Kitamo usa vírgula ou ponto', () {
    final achados = <String>[];
    for (final f in fontes) {
      for (final t in textosDe(f)) {
        if (t.contains('—') || t.contains('–')) {
          achados.add('${f.path}: "$t"');
        }
      }
    }

    expect(achados, isEmpty,
        reason: 'travessão é proibido pelo design system:\n'
            '${achados.join('\n')}');
  });

  test('sem emoji: nem em conquista', () {
    // Faixas de emoji comuns. Não cobre tudo, cobre o que se digita sem
    // querer: 🎉 ✅ 😀 e companhia.
    final emoji = RegExp(
      r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}]',
      unicode: true,
    );

    final achados = <String>[];
    for (final f in fontes) {
      for (final t in textosDe(f)) {
        if (emoji.hasMatch(t)) achados.add('${f.path}: "$t"');
      }
    }

    expect(achados, isEmpty,
        reason: 'o design system proíbe emoji:\n${achados.join('\n')}');
  });
}
