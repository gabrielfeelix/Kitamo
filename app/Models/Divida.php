<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Uma dívida a quitar. Ver spec §6 e docs/DESIGN-KITAMO.md.
 *
 * A fatura de cartão em aberto é uma dívida como as outras, com
 * account_id apontando para o cartão.
 */
class Divida extends Model
{
    use HasFactory;

    protected $table = 'dividas';

    protected $fillable = [
        'user_id',
        'account_id',
        'nome',
        'saldo_atual',
        'valor_parcela',
        'dia_vencimento',
        'parcelas_restantes',
        'parcelas_total',
        'taxa_juros',
        'quitada_em',
    ];

    protected function casts(): array
    {
        return [
            'saldo_atual' => 'decimal:2',
            'valor_parcela' => 'decimal:2',
            'taxa_juros' => 'decimal:4',
            'quitada_em' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /** O cartão, quando a dívida é uma fatura. */
    public function account(): BelongsTo
    {
        return $this->belongsTo(Account::class);
    }

    public function scopeEmAberto(Builder $query): Builder
    {
        return $query->whereNull('quitada_em');
    }

    public function scopeQuitadas(Builder $query): Builder
    {
        return $query->whereNotNull('quitada_em');
    }

    public function estaQuitada(): bool
    {
        return $this->quitada_em !== null;
    }

    public function ehFaturaDeCartao(): bool
    {
        return $this->account_id !== null;
    }

    /** Quantas parcelas já foram pagas. "7 de 10" do spec §3.4. */
    public function parcelasPagas(): int
    {
        return max(0, $this->parcelas_total - $this->parcelas_restantes);
    }

    /**
     * Data prevista da última parcela. É o que define a data de quitação
     * mostrada no onboarding ("pra quitar até janeiro").
     *
     * Retorna null quando não há parcelas restantes — dívida sem
     * cronograma não tem data prevista.
     */
    public function previsaoQuitacao(?\DateTimeInterface $apartirDe = null): ?\Carbon\CarbonImmutable
    {
        if ($this->parcelas_restantes < 1) {
            return null;
        }

        $base = \Carbon\CarbonImmutable::instance(
            $apartirDe ? \Carbon\CarbonImmutable::instance($apartirDe) : \Carbon\CarbonImmutable::now()
        )->startOfDay();

        // A primeira parcela restante cai no próximo dia_vencimento;
        // se o dia deste mês já passou, começa no mês seguinte.
        $primeira = $this->vencimentoNoMes($base->year, $base->month);

        if ($primeira->lt($base)) {
            $proximo = $base->addMonthNoOverflow();
            $primeira = $this->vencimentoNoMes($proximo->year, $proximo->month);
        }

        $ultima = $primeira->addMonthsNoOverflow($this->parcelas_restantes - 1);

        return $this->vencimentoNoMes($ultima->year, $ultima->month);
    }

    /**
     * O vencimento dentro de um mês, respeitando meses curtos: dia 31 em
     * fevereiro vira o dia 28 (ou 29). Sem isso, dia_vencimento 31 estoura
     * a data em 7 meses do ano.
     */
    public function vencimentoNoMes(int $ano, int $mes): \Carbon\CarbonImmutable
    {
        $primeiroDia = \Carbon\CarbonImmutable::create($ano, $mes, 1)->startOfDay();

        return $primeiroDia->setDay(
            min($this->dia_vencimento, $primeiroDia->daysInMonth)
        );
    }
}
