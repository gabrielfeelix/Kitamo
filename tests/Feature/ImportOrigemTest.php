<?php

namespace Tests\Feature;

use App\Models\Account;
use App\Models\Transaction;
use App\Services\BankImportParser;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Cobre a identidade de origem dos lançamentos importados.
 *
 * O risco que estes testes guardam: reimportar um extrato não pode duplicar
 * nada, mas também não pode engolir duas compras legitimamente iguais no
 * mesmo dia — que era o que a deduplicação por conteúdo fazia.
 */
class ImportOrigemTest extends TestCase
{
    use RefreshDatabase;

    private function autenticar(string $email = 'origem@example.com'): string
    {
        return $this->postJson('/api/v1/auth/register', [
            'name' => 'Teste Origem',
            'email' => $email,
            'password' => 'senha123',
        ])->assertCreated()->json('token');
    }

    private function contaPadrao(string $token): int
    {
        return $this->withToken($token)
            ->getJson('/api/v1/accounts')
            ->assertOk()
            ->json('accounts.0.id');
    }

    public function test_parser_ofx_extrai_fitid_como_origem_id(): void
    {
        $ofx = <<<'OFX'
        <OFX><BANKMSGSRSV1><STMTTRNRS><STMTRS>
        <ORG>Banco Teste</ORG><ACCTID>12345</ACCTID>
        <STMTTRN><TRNTYPE>DEBIT<DTPOSTED>20260502120000<TRNAMT>-25.50
        <FITID>ABC-001<MEMO>Mercado</MEMO></STMTTRN>
        </STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>
        OFX;

        $resultado = (new BankImportParser())->parseOfx($ofx);

        $this->assertCount(1, $resultado['rows']);
        $this->assertSame('ABC-001', $resultado['rows'][0]['origem_id']);
        $this->assertSame('2026-05-02', $resultado['rows'][0]['transaction_date']);
        $this->assertSame('expense', $resultado['rows'][0]['kind']);
        $this->assertEqualsWithDelta(25.50, $resultado['rows'][0]['amount'], 0.001);
    }

    public function test_reimportar_ofx_com_mesmo_fitid_nao_duplica(): void
    {
        $token = $this->autenticar();
        $contaId = $this->contaPadrao($token);

        $payload = [
            'account_id' => $contaId,
            'origem' => 'ofx',
            'rows' => [[
                'transaction_date' => '2026-05-02',
                'description' => 'Mercado',
                'amount' => 25.50,
                'kind' => 'expense',
                'origem_id' => 'ABC-001',
            ]],
        ];

        $this->withToken($token)->postJson('/api/v1/import/commit', $payload)
            ->assertOk()->assertJson(['created' => 1, 'skipped' => 0]);

        $this->withToken($token)->postJson('/api/v1/import/commit', $payload)
            ->assertOk()->assertJson(['created' => 0, 'skipped' => 1]);

        $this->assertDatabaseCount('transactions', 1);
    }

    public function test_descricao_diferente_com_mesmo_fitid_ainda_e_duplicata(): void
    {
        $token = $this->autenticar();
        $contaId = $this->contaPadrao($token);

        $base = [
            'account_id' => $contaId,
            'origem' => 'ofx',
            'rows' => [[
                'transaction_date' => '2026-05-02',
                'description' => 'MERCADO LTDA',
                'amount' => 25.50,
                'kind' => 'expense',
                'origem_id' => 'ABC-001',
            ]],
        ];

        $this->withToken($token)->postJson('/api/v1/import/commit', $base)->assertOk();

        // O banco reemitiu o extrato com o texto normalizado. Mesmo FITID,
        // logo é o mesmo lançamento — a dedup por conteúdo erraria aqui.
        $renomeado = $base;
        $renomeado['rows'][0]['description'] = 'Mercado Ltda';

        $this->withToken($token)->postJson('/api/v1/import/commit', $renomeado)
            ->assertOk()->assertJson(['created' => 0, 'skipped' => 1]);

        $this->assertDatabaseCount('transactions', 1);
    }

    public function test_duas_compras_iguais_no_mesmo_dia_sem_id_sao_preservadas(): void
    {
        $token = $this->autenticar();
        $contaId = $this->contaPadrao($token);

        $linha = [
            'transaction_date' => '2026-05-02',
            'description' => 'Cafe',
            'amount' => 12.00,
            'kind' => 'expense',
            'origem_id' => null,
        ];

        $this->withToken($token)->postJson('/api/v1/import/commit', [
            'account_id' => $contaId,
            'origem' => 'csv',
            'rows' => [$linha, $linha],
        ])->assertOk()->assertJson(['created' => 2, 'skipped' => 0]);

        $this->assertDatabaseCount('transactions', 2);
    }

    public function test_reimportar_csv_identico_nao_duplica(): void
    {
        $token = $this->autenticar();
        $contaId = $this->contaPadrao($token);

        $payload = [
            'account_id' => $contaId,
            'origem' => 'csv',
            'rows' => [
                ['transaction_date' => '2026-05-02', 'description' => 'Cafe', 'amount' => 12.00, 'kind' => 'expense', 'origem_id' => null],
                ['transaction_date' => '2026-05-02', 'description' => 'Cafe', 'amount' => 12.00, 'kind' => 'expense', 'origem_id' => null],
            ],
        ];

        $this->withToken($token)->postJson('/api/v1/import/commit', $payload)
            ->assertOk()->assertJson(['created' => 2]);

        $this->withToken($token)->postJson('/api/v1/import/commit', $payload)
            ->assertOk()->assertJson(['created' => 0, 'skipped' => 2]);

        $this->assertDatabaseCount('transactions', 2);
    }

    public function test_importacao_em_cartao_fica_pendente_e_nao_soma_saldo_por_delta(): void
    {
        $token = $this->autenticar();

        $cartao = Account::create([
            'user_id' => \App\Models\User::first()->id,
            'name' => 'Cartao Teste',
            'type' => 'credit_card',
            'initial_balance' => 0,
            'current_balance' => 0,
            'credit_limit' => 5000,
            'closing_day' => 28,
            'due_day' => 4,
        ]);

        $this->withToken($token)->postJson('/api/v1/import/commit', [
            'account_id' => $cartao->id,
            'origem' => 'ofx',
            'rows' => [[
                'transaction_date' => '2026-05-02',
                'description' => 'Compra',
                'amount' => 100.00,
                'kind' => 'expense',
                'origem_id' => 'X-1',
            ]],
        ])->assertOk()->assertJson(['created' => 1]);

        // Compra de cartão em aberto compõe a fatura: precisa ser 'pending',
        // senão InvoiceCycle::outstandingDebt não a enxerga.
        $this->assertSame('pending', Transaction::first()->status);

        // E o saldo do cartão é derivado da dívida, não acumulado por delta.
        $this->assertEqualsWithDelta(100.00, (float) $cartao->fresh()->current_balance, 0.01);
    }
}
