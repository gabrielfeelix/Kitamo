<?php

namespace App\Services\Patrimonio;

interface PriceProvider
{
    /**
     * Preço atual do ativo. Recebe o último preço conhecido para poder
     * degradar com segurança: qualquer falha devolve esse valor em vez de
     * zerar a posição do usuário.
     *
     * A reclamação nº1 do setor é sync silenciosamente errado. Aqui a regra é
     * explícita: na dúvida, mantém o que já se sabia.
     */
    public function precoAtual(string $ticker, ?float $ultimoPrecoConhecido): ?float;

    public function fonte(): string;
}
