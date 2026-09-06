<?php

namespace App\Services\Patrimonio;

/**
 * Ativos que o usuário mantém à mão: caixinha, CDB, Tesouro, e também ações e
 * FIIs — enquanto não houver orçamento para uma API de cotação da B3 (o BRAPI
 * custa ~R$100/mês e sem token nem retorna FII).
 */
class ManualPriceProvider implements PriceProvider
{
    public function precoAtual(string $ticker, ?float $ultimoPrecoConhecido): ?float
    {
        return $ultimoPrecoConhecido;
    }

    public function fonte(): string
    {
        return 'manual';
    }
}
