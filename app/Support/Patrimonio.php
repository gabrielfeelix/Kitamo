<?php

namespace App\Support;

/**
 * Cálculo de patrimônio. Puro de propósito: recebe números, devolve números,
 * não toca banco nem models — assim os testes rodam sem migração, no mesmo
 * padrão de InvoiceCycle.
 *
 * Patrimônio é estoque (quanto eu tenho), não fluxo (quanto entrou e saiu).
 * Misturar os dois é a origem dos bugs clássicos do setor.
 */
class Patrimonio
{
    /**
     * Capital efetivamente investido: aportes menos resgates.
     *
     * @param array<int, array{kind: string, amount: float}> $movimentos
     */
    public static function totalAportado(array $movimentos): float
    {
        $total = 0.0;

        foreach ($movimentos as $movimento) {
            $valor = (float) ($movimento['amount'] ?? 0);
            $total += ($movimento['kind'] ?? '') === 'resgate' ? -$valor : $valor;
        }

        return round($total, 2);
    }

    /**
     * O que o mercado deu (ou tirou): valor atual menos o que foi aportado.
     * Pode ser negativo — prejuízo é informação, não erro.
     *
     * @param array<int, array{kind: string, amount: float}> $movimentos
     */
    public static function rendimento(float $valorAtual, array $movimentos): float
    {
        return round($valorAtual - self::totalAportado($movimentos), 2);
    }

    /**
     * Rendimento como percentual do capital investido. Devolve 0 quando o
     * capital investido não é positivo: dividir por zero (ou por número
     * negativo, quando já se resgatou mais do que se aportou) produziria um
     * percentual sem significado.
     *
     * @param array<int, array{kind: string, amount: float}> $movimentos
     */
    public static function rentabilidadePercentual(float $valorAtual, array $movimentos): float
    {
        $investido = self::totalAportado($movimentos);

        if ($investido <= 0) {
            return 0.0;
        }

        return round((self::rendimento($valorAtual, $movimentos) / $investido) * 100, 2);
    }

    /**
     * Patrimônio total: o que está em conta mais o que está investido.
     * Saldo negativo em conta reduz o total — é dívida de verdade.
     */
    public static function total(float $saldoEmContas, float $valorInvestido): float
    {
        return round($saldoEmContas + $valorInvestido, 2);
    }
}
