import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitamo/data/banco.dart' show Banco;
import 'package:kitamo/features/avisos/avisos.dart';
import 'package:kitamo/features/avisos/avisos_page.dart';
import 'package:kitamo/features/backup/backup_service.dart';
import 'package:kitamo/features/conta/entrar_page.dart';
import 'package:kitamo/features/perfil/editar_perfil_page.dart';
import 'package:kitamo/features/perfil/perfil_page.dart';
import 'package:kitamo/features/seguranca/bloqueio_service.dart';
import 'package:kitamo/models/divida.dart';
import 'package:kitamo/models/perfil_financeiro.dart';
import 'package:kitamo/repositories/divida_repository.dart';
import 'package:kitamo/repositories/perfil_repository.dart';

/// As telas refeitas do Kitamo App.dc.html: Perfil (#16), Editar perfil
/// (#24), Notificações (#20) e a de entrar.
///
/// Estes testes existem porque overflow não quebra o build, quebra na mão
/// do Gabriel: um botão 12px fora da tela já deixou o app sem saída na
/// primeira tela, passando em todo teste de lógica. Por isso toda tela
/// nova é medida em 390x844 (a moldura do design), 360x640 e 320x568.
void main() {
  final nubank = Divida(
    id: '1',
    nome: 'Nubank',
    saldoAtual: 6136.24,
    valorParcela: 1534.06,
    diaVencimento: 4,
    parcelasRestantes: 3,
    parcelasTotal: 10,
  );

  const perfil = PerfilFinanceiro(
    nome: 'Gabriel',
    rendaMensal: 5000,
    diaRenda: 6,
    contasFixasEstimadas: 900,
    avatar: 'av-2',
    provedor: ProvedorDeLogin.google,
    email: 'gabriel@email.com',
  );

  const tamanhos = [
    Size(390, 844),
    Size(360, 640),
    Size(320, 568),
  ];

  /// Monta a tela num tamanho de aparelho e devolve o que ela lançou.
  Future<void> em(WidgetTester tester, Size tamanho, Widget tela) async {
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: tela));
    await tester.pumpAndSettle();
  }

  Banco bancoNovo() {
    final banco = Banco.memoria();
    addTearDown(banco.close);
    return banco;
  }

  Widget telaDePerfil({PerfilFinanceiro? p = perfil}) {
    final banco = bancoNovo();
    return PerfilPage(
      perfil: p,
      dividas: [nubank],
      backup: BackupService(
        PerfilRepositoryDrift(banco),
        DividaRepositoryDrift(banco),
      ),
      bloqueio: BloqueioService(),
      aoSalvarPerfil: (_) async {},
    );
  }

  group('perfil', () {
    for (final t in tamanhos) {
      testWidgets('cabe em ${t.width.toInt()}x${t.height.toInt()}',
          (tester) async {
        await em(tester, t, telaDePerfil());
        expect(tester.takeException(), equals(null));
      });
    }

    testWidgets('mostra o nome e o convite para editar', (tester) async {
      await em(tester, tamanhos.first, telaDePerfil());

      expect(find.text('Gabriel'), findsOneWidget);
      expect(find.text('editar nome e foto'), findsOneWidget);
      expect(find.text('entrou com Google'), findsOneWidget);
    });

    testWidgets('os grupos do design estão na tela', (tester) async {
      await em(tester, tamanhos.first, telaDePerfil());

      expect(find.text('O QUE A GENTE ACOMPANHA'), findsOneWidget);
      expect(find.text('AJUSTES'), findsOneWidget);
      expect(find.text('dívidas'), findsOneWidget);
      expect(find.text('contas conectadas'), findsOneWidget);
      expect(find.text('categorias'), findsOneWidget);
    });

    testWidgets('a casa conta as parcelas pagas', (tester) async {
      await em(tester, tamanhos.first, telaDePerfil());

      // 10 no total, 3 restantes: 7 pagas, como no design.
      expect(find.text('7 de 10 parcelas'), findsOneWidget);
      expect(find.text('SUA CASA'), findsOneWidget);
    });

    testWidgets('sem conta não promete servidor nenhum', (tester) async {
      await em(
        tester,
        tamanhos.first,
        telaDePerfil(p: const PerfilFinanceiro(nome: 'Gabriel')),
      );

      expect(find.text('sem conta, tudo neste aparelho'), findsOneWidget);
    });
  });

  group('editar perfil', () {
    Widget tela({void Function(PerfilFinanceiro)? aoSalvar}) =>
        EditarPerfilPage(
          perfil: perfil,
          aoSalvar: (p) async => aoSalvar?.call(p),
        );

    for (final t in tamanhos) {
      testWidgets('cabe em ${t.width.toInt()}x${t.height.toInt()}',
          (tester) async {
        await em(tester, t, tela());
        expect(tester.takeException(), equals(null));
      });
    }

    testWidgets('traz o acervo dos 8 passarinhos', (tester) async {
      await em(tester, tamanhos.first, tela());

      expect(find.text('O ACERVO DO JOÃO'), findsOneWidget);
      for (final a in PerfilFinanceiro.avatares) {
        expect(
          find.bySemanticsLabel('passarinho ${a.replaceAll('av-', '')}'),
          findsOneWidget,
        );
      }
    });

    testWidgets('salvar devolve o nome digitado', (tester) async {
      PerfilFinanceiro? salvo;
      await em(tester, tamanhos.first, tela(aoSalvar: (p) => salvo = p));

      await tester.enterText(find.byType(TextField), 'Gabi');
      await tester.tap(find.text('salvar'));
      await tester.pumpAndSettle();

      expect(salvo?.nome, 'Gabi');
    });

    testWidgets('escolher outro passarinho troca o avatar salvo',
        (tester) async {
      PerfilFinanceiro? salvo;
      await em(tester, tamanhos.first, tela(aoSalvar: (p) => salvo = p));

      await tester.tap(find.bySemanticsLabel('passarinho 5'));
      await tester.pump();
      await tester.tap(find.text('salvar'));
      await tester.pumpAndSettle();

      expect(salvo?.avatar, 'av-5');
    });

    testWidgets('nome em branco volta a ser nulo, não vira vírgula solta',
        (tester) async {
      PerfilFinanceiro? salvo;
      await em(tester, tamanhos.first, tela(aoSalvar: (p) => salvo = p));

      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('salvar'));
      await tester.pumpAndSettle();

      expect(salvo?.nome, equals(null));
    });
  });

  group('avisos', () {
    final lista = const Avisos().montar(
      perfil: perfil,
      dividas: [nubank],
      hoje: DateTime(2026, 9, 3),
    );

    for (final t in tamanhos) {
      testWidgets('cabe em ${t.width.toInt()}x${t.height.toInt()}',
          (tester) async {
        await em(tester, t, AvisosPage(avisos: lista));
        expect(tester.takeException(), equals(null));
      });
    }

    testWidgets('o título da tela é avisos, não notificações', (tester) async {
      await em(tester, tamanhos.first, AvisosPage(avisos: lista));

      expect(find.text('avisos'), findsOneWidget);
    });

    testWidgets('fecha a lista dizendo que está em dia', (tester) async {
      await em(tester, tamanhos.first, AvisosPage(avisos: lista));

      expect(find.text('SÓ ISSO. VOCÊ ESTÁ EM DIA.'), findsOneWidget);
    });

    testWidgets('sem aviso nenhum mostra o joão, não uma lista vazia',
        (tester) async {
      await em(tester, tamanhos.first, const AvisosPage(avisos: []));

      expect(find.text('nenhum aviso agora'), findsOneWidget);
      // Sem aviso não há o que marcar como lido.
      expect(find.text('marcar lidos'), findsNothing);
    });

    testWidgets('marcar lidos some depois de tocado', (tester) async {
      await em(tester, tamanhos.first, AvisosPage(avisos: lista));

      expect(find.text('marcar lidos'), findsOneWidget);
      await tester.tap(find.text('marcar lidos'));
      await tester.pumpAndSettle();

      expect(find.text('marcar lidos'), findsNothing);
    });

    testWidgets('o valor sai com ponto de milhar e centavo', (tester) async {
      await em(tester, tamanhos.first, AvisosPage(avisos: lista));

      // Regra do projeto: todo valor com centavo, e milhar com ponto.
      // O aviso formatava na mão e mostrava "R$ 1534,06" no aparelho.
      // O intl usa espaço fino entre o R$ e o número, então a busca é
      // pelo que importa: o milhar com ponto e os centavos.
      expect(find.textContaining('1.534,06'), findsOneWidget);
      expect(find.textContaining('1534'), findsNothing);
    });

    testWidgets('o botão do aviso chama de volta com o aviso certo',
        (tester) async {
      Aviso? tocado;
      await em(
        tester,
        tamanhos.first,
        AvisosPage(avisos: lista, aoTocarAcao: (a) => tocado = a),
      );

      await tester.tap(find.text('quitei essa').first);
      await tester.pumpAndSettle();

      expect(tocado?.tipo, TipoAviso.vencimento);
    });
  });

  group('entrar', () {
    for (final t in tamanhos) {
      testWidgets('cabe em ${t.width.toInt()}x${t.height.toInt()}',
          (tester) async {
        await em(tester, t, EntrarPage(aoEntrar: (_) {}));
        expect(tester.takeException(), equals(null));
      });
    }

    testWidgets('oferece os dois provedores e o caminho sem conta',
        (tester) async {
      await em(tester, tamanhos.first, EntrarPage(aoEntrar: (_) {}));

      expect(find.text('continuar com Google'), findsOneWidget);
      expect(find.text('continuar com Facebook'), findsOneWidget);
      expect(find.text('entrar sem conta'), findsOneWidget);
    });

    testWidgets('tocar no Google devolve o provedor', (tester) async {
      ProvedorDeLogin? escolhido;
      await em(
        tester,
        tamanhos.first,
        EntrarPage(aoEntrar: (p) => escolhido = p),
      );

      await tester.tap(find.text('continuar com Google'));
      await tester.pumpAndSettle();

      expect(escolhido, ProvedorDeLogin.google);
    });

    testWidgets('não pede senha em lugar nenhum', (tester) async {
      await em(tester, tamanhos.first, EntrarPage(aoEntrar: (_) {}));

      // Regra fechada do projeto: nunca pedir senha de banco, cartão ou
      // CPF. Uma tela de login é justamente onde isso escaparia.
      expect(find.byType(TextField), findsNothing);
      expect(find.textContaining('senha de banco'), findsOneWidget);
    });
  });
}
