import 'package:flutter/material.dart';

import '../../design/cores.dart';
import '../../design/medidas.dart';
import '../../design/tipografia.dart';
import '../../models/divida.dart';
import '../../models/perfil_financeiro.dart';
import '../../services/diario_service.dart';
import '../../widgets/campos.dart';
import '../../widgets/moeda.dart';

/// A #17 "O número": o RESULTADO das perguntas iniciais.
///
/// Sem ela o app caía seco no Início assim que a última pergunta era
/// respondida — a pessoa responde seis coisas e não recebe nada de volta.
/// Palavras do Gabriel: *"dps q eu respondo todas as perguntas tem q ter
/// uma tela de RESULTADO pra n ser muito seco"*.
///
/// **Não é onboarding.** O onboarding (#32) vem depois, e ensina a usar.
class ResultadoPage extends StatelessWidget {
  const ResultadoPage({
    super.key,
    required this.perfil,
    required this.dividas,
    required this.aoVerMeuMes,
    required this.aoRevisar,
  });

  final PerfilFinanceiro? perfil;
  final List<Divida> dividas;
  final VoidCallback aoVerMeuMes;
  final VoidCallback aoRevisar;

  @override
  Widget build(BuildContext context) {
    final r = const DiarioService().calcular(perfil: perfil, dividas: dividas);
    final abertas = dividas.where((d) => !d.estaQuitada).toList();
    final devendo = abertas.fold<double>(0, (s, d) => s + d.saldoAtual);

    return Scaffold(
      backgroundColor: Cores.tealEscuro,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                _rotulo(r),
                style: Tipo.rotulo.copyWith(
                  fontSize: 11,
                  letterSpacing: 11 * 0.12,
                  color: Cores.branco,
                ),
              ),
              const SizedBox(height: 22),

              // O número em Outfit 76, como o design pede. Encolhe para
              // caber em tela estreita em vez de estourar.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  r.fecha ? dinheiro(r.diario) : dinheiro(r.faltaPorMes),
                  style: const TextStyle(
                    fontFamily: Tipo.outfit,
                    fontSize: 76,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    letterSpacing: -76 * 0.04,
                    color: Cores.branco,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 290),
                child: Text(
                  _frase(r),
                  style: const TextStyle(
                    fontFamily: Tipo.figtree,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: Cores.branco,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              _Resumo(
                devendo: devendo,
                quantas: abertas.length,
                entra: perfil?.rendaMensal ?? 0,
                veioDeExtrato: perfil?.veioDeExtrato ?? false,
              ),
              const SizedBox(height: 22),

              // O joão só aparece quando a conta fecha. Bicho fofo sobre
              // má notícia é deboche — é regra do design, não gosto.
              if (r.fecha)
                SizedBox(
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Image.asset('assets/images/joao-voando.png',
                          height: 104,
                          errorBuilder: (_, _, _) => const SizedBox.shrink()),
                      const SizedBox(width: 8),
                      Image.asset('assets/images/casa-1.png',
                          height: 52,
                          errorBuilder: (_, _, _) => const SizedBox.shrink()),
                    ],
                  ),
                )
              else
                const SizedBox(height: 24),

              const SizedBox(height: 12),
              BotaoSobreAcento(
                rotulo: 'ver meu mês',
                aoTocar: aoVerMeuMes,
              ),
              const SizedBox(height: 12),
              Center(
                child: Semantics(
                  button: true,
                  child: GestureDetector(
                    onTap: aoRevisar,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      constraints:
                          const BoxConstraints(minHeight: Medidas.alvoMinimo),
                      alignment: Alignment.center,
                      child: const Text(
                        'revisar minhas respostas',
                        style: TextStyle(
                          fontFamily: Tipo.figtree,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Cores.branco,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// O rótulo muda com a verdade: prometer "pra quitar até janeiro" para
  /// quem não fecha a conta seria mentir na primeira tela.
  String _rotulo(ResultadoDiario r) {
    if (!r.fecha) return 'A CONTA NÃO FECHA';
    final quando = r.quitacaoLabel;
    return quando == null ? 'SEU DIÁRIO' : 'PRA QUITAR ATÉ ${quando.toUpperCase()}';
  }

  String _frase(ResultadoDiario r) {
    if (!r.fecha) {
      return 'é quanto falta por mês pra conta fechar. '
          'dá pra mexer nisso, e a gente vai junto.';
    }
    return r.temDividas
        ? 'é o que dá pra gastar por dia, todo dia, '
            'até a última parcela cair.'
        : 'é o que dá pra gastar por dia, todo dia, sem apertar.';
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({
    required this.devendo,
    required this.quantas,
    required this.entra,
    required this.veioDeExtrato,
  });

  final double devendo;
  final int quantas;
  final double entra;
  final bool veioDeExtrato;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0x29000000),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontFamily: Tipo.figtree,
                fontSize: 14.5,
                height: 1.5,
                color: Cores.branco,
              ),
              children: [
                if (devendo > 0) ...[
                  const TextSpan(text: 'você deve '),
                  TextSpan(
                    text: dinheiro(devendo),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: quantas == 1 ? ' em 1 dívida' : ' em $quantas dívidas',
                  ),
                  const TextSpan(text: ', e entra '),
                ] else
                  const TextSpan(text: 'entra '),
                TextSpan(
                  text: dinheiro(entra),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' por mês.'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // A honestidade é o produto: dizer que o número é chute é o
            // que faz a pessoa confiar quando ele mudar depois.
            veioDeExtrato
                ? 'esse número veio do seu extrato.'
                : 'tudo isso foi chute seu. quando a gente ler seu extrato, '
                    'o número se ajusta.',
            style: const TextStyle(
              fontFamily: Tipo.figtree,
              fontSize: 13.5,
              height: 1.5,
              color: Color(0xFFDBF3F0),
            ),
          ),
        ],
      ),
    );
  }
}
