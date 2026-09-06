<?php

namespace App\Jobs;

use App\Models\Investment;
use App\Models\InvestmentPrice;
use App\Services\Patrimonio\BcbPriceProvider;
use App\Services\Patrimonio\BinancePriceProvider;
use App\Services\Patrimonio\PriceProvider;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Carbon;

/**
 * Atualiza as posições que pedem cotação automática.
 *
 * Regra que não pode ser quebrada: quando a cotação não vem, o job não escreve
 * nada. A posição mantém o último valor e o `price_updated_at` antigo — é
 * assim que a tela consegue mostrar "atualizado há 3 dias" em vez de exibir
 * um número errado com cara de novo.
 */
class RefreshInvestmentPrices implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function handle(): void
    {
        // O CDI é buscado sempre, independente de haver posição sincronizada:
        // ele é o benchmark de toda a carteira, inclusive das manuais.
        $this->atualizarCdi();

        $providers = [
            'binance' => new BinancePriceProvider(),
        ];

        Investment::query()
            ->ativos()
            ->whereIn('price_source', array_keys($providers))
            ->whereNotNull('ticker')
            ->chunkById(100, function ($investments) use ($providers) {
                foreach ($investments as $investment) {
                    $provider = $providers[$investment->price_source] ?? null;

                    if ($provider instanceof PriceProvider) {
                        $this->atualizar($investment, $provider);
                    }
                }
            });
    }

    private function atualizar(Investment $investment, PriceProvider $provider): void
    {
        $ticker = (string) $investment->ticker;
        $ultimo = $this->ultimoPrecoConhecido($ticker, $provider->fonte());

        $preco = $provider->precoAtual($ticker, $ultimo);

        // Sem preço novo, ou preço idêntico ao que já se tinha: nada a fazer.
        // Reescrever `price_updated_at` aqui faria um dado velho parecer fresco.
        if ($preco === null || ($ultimo !== null && abs($preco - $ultimo) < 0.00000001)) {
            return;
        }

        InvestmentPrice::updateOrCreate(
            [
                'ticker' => $ticker,
                'source' => $provider->fonte(),
                'quoted_on' => Carbon::today()->toDateString(),
            ],
            ['price' => $preco],
        );

        // Só recalcula o valor da posição quando há quantidade: sem ela o
        // preço unitário não diz quanto a posição vale.
        $quantidade = $investment->quantity !== null ? (float) $investment->quantity : null;

        if ($quantidade !== null && $quantidade > 0) {
            $investment->current_value = round($quantidade * $preco, 2);
        }

        $investment->price_updated_at = now();
        $investment->save();
    }

    /**
     * Guarda a taxa CDI do dia. Sem ela a tela simplesmente não mostra a
     * comparação — nunca mostra um benchmark chutado.
     */
    private function atualizarCdi(): void
    {
        $serie = BcbPriceProvider::SERIE_CDI;
        $ultimo = $this->ultimoPrecoConhecido($serie, 'bcb');

        $taxa = (new BcbPriceProvider())->precoAtual($serie, $ultimo);

        if ($taxa === null || $taxa <= 0) {
            return;
        }

        InvestmentPrice::updateOrCreate(
            [
                'ticker' => $serie,
                'source' => 'bcb',
                'quoted_on' => Carbon::today()->toDateString(),
            ],
            ['price' => $taxa],
        );
    }

    private function ultimoPrecoConhecido(string $ticker, string $fonte): ?float
    {
        $registro = InvestmentPrice::query()
            ->where('ticker', $ticker)
            ->where('source', $fonte)
            ->orderByDesc('quoted_on')
            ->first();

        return $registro ? (float) $registro->price : null;
    }
}
