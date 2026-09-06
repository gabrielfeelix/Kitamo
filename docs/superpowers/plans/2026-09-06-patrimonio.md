# Módulo de Patrimônio — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dar ao Kitamo a resposta para "quanto eu tenho guardado/investido", separando patrimônio (estoque) de fluxo de caixa (movimento).

**Architecture:** Três tabelas novas (`investments`, `investment_transactions`, `investment_prices`) independentes de `accounts`. O cálculo de rendimento vive numa classe de apoio pura (`App\Support\Patrimonio`), testável sem banco — igual ao `InvoiceCycle` existente. Cotação automática entra por trás de uma interface `PriceProvider`, com fallback manual sempre disponível.

**Tech Stack:** Laravel 12, PHP 8.3, Vue 3 + Inertia + TypeScript, Tailwind, PHPUnit.

**Spec:** `docs/superpowers/specs/2026-09-06-patrimonio-design.md`

## Global Constraints

- **Testes rodam sem banco.** O repo usa `PHPUnit\Framework\TestCase` puro (ver `tests/Unit/InvoiceCycleTest.php`), não `Tests\TestCase`. Lógica de cálculo fica em classes puras que recebem arrays/floats, não models.
- **Chaves primárias são `id()` (bigint auto-increment)**, seguindo `accounts`. A spec menciona ulid; a convenção do repo vence.
- **Toda escrita múltipla dentro de `DB::transaction`.** A auditoria anterior achou perda de dinheiro determinística por falta disso.
- **Decimais:** valores em `decimal(15,2)`, quantidades em `decimal(18,8)`.
- **Tag obrigatória:** aporte que gera transação de caixa usa a tag literal `aporte-investimento`.
- **Classes de ativo (valores literais):** `caixinha`, `cdb`, `tesouro`, `acao`, `fii`, `cripto`, `outro`.
- **Fontes de preço (valores literais):** `manual`, `binance`, `bcb`.
- **PHP do servidor é `/opt/alt/php83/usr/bin/php`**; local usa `php` normal.
- **Nunca usar `rsync --delete` em `public/build/`.**
- Textos de interface em português do Brasil.

---

### Task 1: Cálculo puro de patrimônio

Começa pela lógica porque ela é testável sem banco e todo o resto depende dela.

**Files:**
- Create: `app/Support/Patrimonio.php`
- Test: `tests/Unit/PatrimonioTest.php`

**Interfaces:**
- Consumes: nada
- Produces:
  - `Patrimonio::rendimento(float $valorAtual, array $movimentos): float`
  - `Patrimonio::totalAportado(array $movimentos): float`
  - `Patrimonio::rentabilidadePercentual(float $valorAtual, array $movimentos): float`
  - `$movimentos` é uma lista de `['kind' => 'aporte'|'resgate', 'amount' => float]`

- [ ] **Step 1: Write the failing test**

```php
<?php

namespace Tests\Unit;

use App\Support\Patrimonio;
use PHPUnit\Framework\TestCase;

class PatrimonioTest extends TestCase
{
    public function test_rendimento_e_valor_atual_menos_capital_investido(): void
    {
        $movimentos = [
            ['kind' => 'aporte', 'amount' => 1000.00],
            ['kind' => 'aporte', 'amount' => 500.00],
        ];

        // Aportou 1500, hoje vale 1600 => rendeu 100.
        $this->assertSame(100.0, Patrimonio::rendimento(1600.00, $movimentos));
    }

    public function test_resgate_reduz_o_capital_investido(): void
    {
        $movimentos = [
            ['kind' => 'aporte', 'amount' => 1000.00],
            ['kind' => 'resgate', 'amount' => 400.00],
        ];

        // Capital investido = 600. Vale 650 => rendeu 50.
        $this->assertSame(600.0, Patrimonio::totalAportado($movimentos));
        $this->assertSame(50.0, Patrimonio::rendimento(650.00, $movimentos));
    }

    public function test_rendimento_negativo_quando_a_posicao_perde_valor(): void
    {
        $movimentos = [['kind' => 'aporte', 'amount' => 1000.00]];

        // Prejuízo é informação legítima: não pode ser zerado nem virar módulo.
        $this->assertSame(-250.0, Patrimonio::rendimento(750.00, $movimentos));
    }

    public function test_posicao_sem_movimentos_nao_divide_por_zero(): void
    {
        $this->assertSame(0.0, Patrimonio::totalAportado([]));
        $this->assertSame(0.0, Patrimonio::rentabilidadePercentual(500.00, []));
    }

    public function test_rentabilidade_percentual_sobre_o_capital_investido(): void
    {
        $movimentos = [['kind' => 'aporte', 'amount' => 2000.00]];

        // 2000 -> 2200 = +10%
        $this->assertSame(10.0, Patrimonio::rentabilidadePercentual(2200.00, $movimentos));
    }

    public function test_capital_investido_negativo_nao_gera_percentual_absurdo(): void
    {
        // Resgatou mais do que aportou (lucro já realizado): percentual não faz
        // sentido matemático aqui, então é 0 em vez de um número enganoso.
        $movimentos = [
            ['kind' => 'aporte', 'amount' => 100.00],
            ['kind' => 'resgate', 'amount' => 300.00],
        ];

        $this->assertSame(0.0, Patrimonio::rentabilidadePercentual(50.00, $movimentos));
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `./vendor/bin/phpunit tests/Unit/PatrimonioTest.php`
Expected: FAIL — `Class "App\Support\Patrimonio" not found`

- [ ] **Step 3: Write minimal implementation**

```php
<?php

namespace App\Support;

/**
 * Cálculo de patrimônio. Puro de propósito: recebe números, devolve números,
 * não toca banco nem models — assim os testes rodam sem migração, no mesmo
 * padrão de InvoiceCycle.
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
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `./vendor/bin/phpunit tests/Unit/PatrimonioTest.php`
Expected: PASS (6 tests)

- [ ] **Step 5: Commit**

```bash
git add app/Support/Patrimonio.php tests/Unit/PatrimonioTest.php
git commit -m "feat(patrimonio): calculo puro de aporte, rendimento e rentabilidade"
```

---

### Task 2: Migrations e models

**Files:**
- Create: `database/migrations/2026_09_06_000001_create_investments_table.php`
- Create: `database/migrations/2026_09_06_000002_create_investment_transactions_table.php`
- Create: `database/migrations/2026_09_06_000003_create_investment_prices_table.php`
- Create: `app/Models/Investment.php`
- Create: `app/Models/InvestmentTransaction.php`
- Create: `app/Models/InvestmentPrice.php`

**Interfaces:**
- Consumes: nada
- Produces:
  - `Investment` com `$fillable` incluindo `user_id, name, asset_class, institution, ticker, quantity, current_value, price_source, price_updated_at, is_archived, color, icon`; relações `user()`, `movimentos()`; scope `ativos()`
  - `InvestmentTransaction` com `$fillable` `investment_id, kind, amount, quantity, unit_price, occurred_on, transaction_id`; relações `investment()`, `transaction()`
  - `InvestmentPrice` com `$fillable` `ticker, source, price, quoted_on`

- [ ] **Step 1: Criar a migration de `investments`**

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('investments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('asset_class');
            $table->string('institution')->nullable();
            $table->string('ticker')->nullable();
            $table->decimal('quantity', 18, 8)->nullable();
            $table->decimal('current_value', 15, 2)->default(0);
            $table->string('price_source')->default('manual');
            $table->timestamp('price_updated_at')->nullable();
            $table->boolean('is_archived')->default(false);
            $table->string('color')->nullable();
            $table->string('icon')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'is_archived']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('investments');
    }
};
```

- [ ] **Step 2: Criar a migration de `investment_transactions`**

`transaction_id` é `nullOnDelete`: apagar a transação de caixa não pode apagar o histórico do aporte.

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('investment_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('investment_id')->constrained()->cascadeOnDelete();
            $table->string('kind');
            $table->decimal('amount', 15, 2);
            $table->decimal('quantity', 18, 8)->nullable();
            $table->decimal('unit_price', 18, 8)->nullable();
            $table->date('occurred_on');
            $table->foreignId('transaction_id')->nullable()->constrained()->nullOnDelete();
            $table->timestamps();

            $table->index(['investment_id', 'occurred_on']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('investment_transactions');
    }
};
```

- [ ] **Step 3: Criar a migration de `investment_prices`**

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('investment_prices', function (Blueprint $table) {
            $table->id();
            $table->string('ticker');
            $table->string('source');
            $table->decimal('price', 18, 8);
            $table->date('quoted_on');
            $table->timestamps();

            // Uma cotação por ticker por dia: é isto que evita repetir a
            // requisição a cada carregamento de página.
            $table->unique(['ticker', 'source', 'quoted_on']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('investment_prices');
    }
};
```

- [ ] **Step 4: Criar os três models**

`app/Models/Investment.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Investment extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'asset_class',
        'institution',
        'ticker',
        'quantity',
        'current_value',
        'price_source',
        'price_updated_at',
        'is_archived',
        'color',
        'icon',
    ];

    protected function casts(): array
    {
        return [
            'quantity' => 'decimal:8',
            'current_value' => 'decimal:2',
            'price_updated_at' => 'datetime',
            'is_archived' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function movimentos(): HasMany
    {
        return $this->hasMany(InvestmentTransaction::class);
    }

    public function scopeAtivos(Builder $query): Builder
    {
        return $query->where('is_archived', false);
    }
}
```

`app/Models/InvestmentTransaction.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InvestmentTransaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'investment_id',
        'kind',
        'amount',
        'quantity',
        'unit_price',
        'occurred_on',
        'transaction_id',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'quantity' => 'decimal:8',
            'unit_price' => 'decimal:8',
            'occurred_on' => 'date',
        ];
    }

    public function investment(): BelongsTo
    {
        return $this->belongsTo(Investment::class);
    }

    public function transaction(): BelongsTo
    {
        return $this->belongsTo(Transaction::class);
    }
}
```

`app/Models/InvestmentPrice.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InvestmentPrice extends Model
{
    use HasFactory;

    protected $fillable = [
        'ticker',
        'source',
        'price',
        'quoted_on',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:8',
            'quoted_on' => 'date',
        ];
    }
}
```

- [ ] **Step 5: Rodar as migrations localmente**

Run: `php artisan migrate`
Expected: as três migrations aplicadas sem erro.

- [ ] **Step 6: Confirmar que a suíte continua verde**

Run: `./vendor/bin/phpunit tests/Unit/`
Expected: PASS (todos os testes anteriores + Patrimonio)

- [ ] **Step 7: Commit**

```bash
git add database/migrations app/Models/Investment.php app/Models/InvestmentTransaction.php app/Models/InvestmentPrice.php
git commit -m "feat(patrimonio): tabelas e models de investimento"
```

---

### Task 3: PriceProvider com degradação segura

O ponto crítico: **falha de API nunca pode zerar uma posição.** Testado antes de existir integração real.

**Files:**
- Create: `app/Services/Patrimonio/PriceProvider.php`
- Create: `app/Services/Patrimonio/ManualPriceProvider.php`
- Create: `app/Services/Patrimonio/BinancePriceProvider.php`
- Test: `tests/Unit/PriceProviderTest.php`

**Interfaces:**
- Consumes: nada
- Produces:
  - `interface PriceProvider { public function precoAtual(string $ticker, ?float $ultimoPrecoConhecido): ?float; public function fonte(): string; }`
  - `ManualPriceProvider::fonte()` devolve `'manual'`; `precoAtual()` devolve sempre `$ultimoPrecoConhecido`
  - `BinancePriceProvider::__construct(callable $fetcher)` — o `$fetcher` recebe o ticker e devolve `?float`; injetá-lo é o que torna o teste possível sem rede

- [ ] **Step 1: Write the failing test**

```php
<?php

namespace Tests\Unit;

use App\Services\Patrimonio\BinancePriceProvider;
use App\Services\Patrimonio\ManualPriceProvider;
use PHPUnit\Framework\TestCase;

class PriceProviderTest extends TestCase
{
    public function test_manual_sempre_devolve_o_valor_informado_pelo_usuario(): void
    {
        $provider = new ManualPriceProvider();

        $this->assertSame('manual', $provider->fonte());
        $this->assertSame(1628.47, $provider->precoAtual('QUALQUER', 1628.47));
    }

    public function test_binance_devolve_o_preco_quando_a_api_responde(): void
    {
        $provider = new BinancePriceProvider(fn (string $ticker) => 79944.00);

        $this->assertSame(79944.00, $provider->precoAtual('BTC', null));
    }

    public function test_falha_da_api_preserva_o_ultimo_preco_conhecido(): void
    {
        // A garantia central do módulo: rede fora do ar não pode zerar posição.
        $provider = new BinancePriceProvider(function (string $ticker) {
            throw new \RuntimeException('connection refused');
        });

        $this->assertSame(75000.00, $provider->precoAtual('BTC', 75000.00));
    }

    public function test_api_devolvendo_nulo_tambem_preserva_o_ultimo_preco(): void
    {
        $provider = new BinancePriceProvider(fn (string $ticker) => null);

        $this->assertSame(75000.00, $provider->precoAtual('BTC', 75000.00));
    }

    public function test_preco_invalido_nao_contamina_a_posicao(): void
    {
        // Zero ou negativo vindo da API é dado corrompido, não preço.
        $provider = new BinancePriceProvider(fn (string $ticker) => 0.0);

        $this->assertSame(75000.00, $provider->precoAtual('BTC', 75000.00));
    }

    public function test_sem_preco_anterior_e_com_falha_devolve_nulo(): void
    {
        $provider = new BinancePriceProvider(fn (string $ticker) => null);

        $this->assertNull($provider->precoAtual('BTC', null));
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `./vendor/bin/phpunit tests/Unit/PriceProviderTest.php`
Expected: FAIL — `Interface "App\Services\Patrimonio\PriceProvider" not found`

- [ ] **Step 3: Write minimal implementation**

`app/Services/Patrimonio/PriceProvider.php`:

```php
<?php

namespace App\Services\Patrimonio;

interface PriceProvider
{
    /**
     * Preço atual do ativo. Recebe o último preço conhecido para poder
     * degradar com segurança: qualquer falha devolve esse valor em vez de
     * zerar a posição do usuário.
     */
    public function precoAtual(string $ticker, ?float $ultimoPrecoConhecido): ?float;

    public function fonte(): string;
}
```

`app/Services/Patrimonio/ManualPriceProvider.php`:

```php
<?php

namespace App\Services\Patrimonio;

/**
 * Ativos que o usuário mantém à mão: caixinha, CDB, Tesouro, ações e FIIs
 * (enquanto não houver orçamento para uma API de cotação da B3).
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
```

`app/Services/Patrimonio/BinancePriceProvider.php`:

```php
<?php

namespace App\Services\Patrimonio;

use Throwable;

/**
 * Cotação de cripto pela API pública da Binance (data-api.binance.vision):
 * sem chave, sem cadastro e sem cláusula de uso pessoal — por isso é a única
 * fonte automática de renda variável legítima para um SaaS pago.
 *
 * O fetcher é injetado para manter o teste fora da rede.
 */
class BinancePriceProvider implements PriceProvider
{
    /** @var callable(string): ?float */
    private $fetcher;

    public function __construct(?callable $fetcher = null)
    {
        $this->fetcher = $fetcher ?? fn (string $ticker) => $this->buscarNaBinance($ticker);
    }

    public function precoAtual(string $ticker, ?float $ultimoPrecoConhecido): ?float
    {
        try {
            $preco = ($this->fetcher)($ticker);
        } catch (Throwable) {
            // Rede fora, DNS quebrado, rate limit: mantém o que já se sabia.
            return $ultimoPrecoConhecido;
        }

        if ($preco === null || $preco <= 0) {
            return $ultimoPrecoConhecido;
        }

        return (float) $preco;
    }

    public function fonte(): string
    {
        return 'binance';
    }

    private function buscarNaBinance(string $ticker): ?float
    {
        $symbol = strtoupper($ticker) . 'USDT';
        $url = 'https://data-api.binance.vision/api/v3/ticker/price?symbol=' . urlencode($symbol);

        $response = @file_get_contents($url, false, stream_context_create([
            'http' => ['timeout' => 5, 'ignore_errors' => true],
        ]));

        if ($response === false) {
            return null;
        }

        $payload = json_decode($response, true);

        return isset($payload['price']) ? (float) $payload['price'] : null;
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `./vendor/bin/phpunit tests/Unit/PriceProviderTest.php`
Expected: PASS (6 tests)

- [ ] **Step 5: Commit**

```bash
git add app/Services/Patrimonio tests/Unit/PriceProviderTest.php
git commit -m "feat(patrimonio): PriceProvider com degradacao segura em falha de API"
```

---

### Task 4: Controller de investimentos

**Files:**
- Create: `app/Http/Controllers/InvestmentController.php`
- Modify: `routes/web.php` (adicionar as rotas junto das demais rotas `api.*`, por volta da linha 258)
- Modify: `app/Support/KitamoBootstrap.php` (adicionar o serializer `investment()` e incluir `investments` no payload de `forUser`)

**Interfaces:**
- Consumes: `Investment`, `InvestmentTransaction` (Task 2); `Patrimonio` (Task 1)
- Produces:
  - Rotas nomeadas: `api.investments.store`, `api.investments.update`, `api.investments.destroy`, `api.investments.aporte`
  - `KitamoBootstrap::investment(Investment $i): array` devolvendo
    `['id' => string, 'name' => string, 'assetClass' => string, 'institution' => ?string, 'ticker' => ?string, 'currentValue' => float, 'totalAportado' => float, 'rendimento' => float, 'rentabilidade' => float, 'priceSource' => string, 'priceUpdatedAt' => ?string, 'color' => ?string, 'icon' => ?string]`
  - Payload JSON de todas as rotas: `{'investment' => array}` (mesmo formato de `{'entry' => ...}` já usado por `TransactionController`)

- [ ] **Step 1: Adicionar o serializer ao KitamoBootstrap**

Adicionar o método junto dos outros serializers (depois de `account()`, por volta da linha 300). Note que `rendimento` e `rentabilidade` são derivados na leitura — nunca persistidos, para não dessincronizar.

```php
    public function investment(Investment $investment): array
    {
        $movimentos = $investment->movimentos
            ->map(fn (InvestmentTransaction $m) => [
                'kind' => $m->kind,
                'amount' => (float) $m->amount,
            ])
            ->all();

        $valorAtual = (float) $investment->current_value;

        return [
            'id' => (string) $investment->id,
            'name' => $investment->name,
            'assetClass' => $investment->asset_class,
            'institution' => $investment->institution,
            'ticker' => $investment->ticker,
            'currentValue' => $valorAtual,
            'totalAportado' => Patrimonio::totalAportado($movimentos),
            'rendimento' => Patrimonio::rendimento($valorAtual, $movimentos),
            'rentabilidade' => Patrimonio::rentabilidadePercentual($valorAtual, $movimentos),
            'priceSource' => $investment->price_source,
            'priceUpdatedAt' => $investment->price_updated_at?->toISOString(),
            'color' => $investment->color,
            'icon' => $investment->icon,
        ];
    }
```

Adicionar no topo do arquivo os imports `use App\Models\Investment;`, `use App\Models\InvestmentTransaction;` e `use App\Support\Patrimonio;`.

Em `forUser()`, junto de `'goals' => ...` e `'accounts' => ...` (linhas 146-147), acrescentar:

```php
            'investments' => Investment::query()
                ->where('user_id', $user->id)
                ->ativos()
                ->with('movimentos')
                ->orderByDesc('current_value')
                ->get()
                ->map(fn (Investment $i) => $this->investment($i))
                ->values(),
```

- [ ] **Step 2: Criar o controller**

```php
<?php

namespace App\Http\Controllers;

use App\Models\Investment;
use App\Models\InvestmentTransaction;
use App\Models\Tag;
use App\Models\Transaction;
use App\Support\KitamoBootstrap;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class InvestmentController extends Controller
{
    private const CLASSES = ['caixinha', 'cdb', 'tesouro', 'acao', 'fii', 'cripto', 'outro'];
    private const FONTES = ['manual', 'binance', 'bcb'];

    /**
     * Sem esta tag o aporte apareceria como despesa nos relatórios, inventando
     * um gasto que na verdade é dinheiro que continua sendo do usuário — o
     * mesmo erro que a tag `quitacao-fatura` resolve para faturas.
     */
    public const TAG_APORTE = 'aporte-investimento';

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'asset_class' => ['required', Rule::in(self::CLASSES)],
            'institution' => ['nullable', 'string', 'max:120'],
            'ticker' => ['nullable', 'string', 'max:20'],
            'quantity' => ['nullable', 'numeric', 'min:0'],
            'current_value' => ['required', 'numeric', 'min:0'],
            'price_source' => ['nullable', Rule::in(self::FONTES)],
            'color' => ['nullable', 'string', 'max:20'],
            'icon' => ['nullable', 'string', 'max:40'],
        ]);

        $investment = Investment::create([
            ...$data,
            'user_id' => $request->user()->id,
            'price_source' => $data['price_source'] ?? 'manual',
            'price_updated_at' => now(),
        ]);

        return response()->json([
            'investment' => app(KitamoBootstrap::class)->investment($investment->load('movimentos')),
        ]);
    }

    public function update(Request $request, Investment $investment): JsonResponse
    {
        $this->autorizar($request, $investment);

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'asset_class' => ['sometimes', Rule::in(self::CLASSES)],
            'institution' => ['nullable', 'string', 'max:120'],
            'ticker' => ['nullable', 'string', 'max:20'],
            'quantity' => ['nullable', 'numeric', 'min:0'],
            'current_value' => ['sometimes', 'numeric', 'min:0'],
            'price_source' => ['sometimes', Rule::in(self::FONTES)],
            'color' => ['nullable', 'string', 'max:20'],
            'icon' => ['nullable', 'string', 'max:40'],
        ]);

        // Edição manual continua disponível mesmo em ativo sincronizado: é o
        // erro que faz usuários de concorrentes ficarem presos a dado errado.
        if (array_key_exists('current_value', $data)) {
            $data['price_updated_at'] = now();
        }

        $investment->update($data);

        return response()->json([
            'investment' => app(KitamoBootstrap::class)->investment($investment->fresh()->load('movimentos')),
        ]);
    }

    public function destroy(Request $request, Investment $investment): JsonResponse
    {
        $this->autorizar($request, $investment);

        // As Transaction de caixa já geradas não são apagadas: são fatos do
        // passado e apagá-las reescreveria o extrato do usuário.
        $investment->delete();

        return response()->json(['ok' => true]);
    }

    /**
     * Aporte ou resgate. Quando `afeta_caixa` vem marcado, cria também a
     * Transaction correspondente — as duas escritas numa transação só.
     */
    public function aporte(Request $request, Investment $investment): JsonResponse
    {
        $this->autorizar($request, $investment);

        $data = $request->validate([
            'kind' => ['required', Rule::in(['aporte', 'resgate'])],
            'amount' => ['required', 'numeric', 'gt:0'],
            'quantity' => ['nullable', 'numeric', 'min:0'],
            'unit_price' => ['nullable', 'numeric', 'min:0'],
            'occurred_on' => ['required', 'date'],
            'afeta_caixa' => ['nullable', 'boolean'],
            'account_id' => ['nullable', 'integer', 'exists:accounts,id'],
        ]);

        return DB::transaction(function () use ($request, $investment, $data) {
            $transactionId = null;

            if (($data['afeta_caixa'] ?? false) && !empty($data['account_id'])) {
                $transaction = Transaction::create([
                    'user_id' => $request->user()->id,
                    'account_id' => $data['account_id'],
                    'description' => ($data['kind'] === 'aporte' ? 'Aporte em ' : 'Resgate de ') . $investment->name,
                    'amount' => $data['amount'],
                    'kind' => $data['kind'] === 'aporte' ? 'expense' : 'income',
                    'status' => $data['kind'] === 'aporte' ? 'paid' : 'received',
                    'transaction_date' => $data['occurred_on'],
                    'data_pagamento' => $data['occurred_on'],
                ]);

                $this->marcarComTagDeAporte($transaction);
                $transactionId = $transaction->id;
            }

            InvestmentTransaction::create([
                'investment_id' => $investment->id,
                'kind' => $data['kind'],
                'amount' => $data['amount'],
                'quantity' => $data['quantity'] ?? null,
                'unit_price' => $data['unit_price'] ?? null,
                'occurred_on' => $data['occurred_on'],
                'transaction_id' => $transactionId,
            ]);

            // O aporte aumenta a posição; o resgate reduz.
            $delta = $data['kind'] === 'aporte' ? $data['amount'] : -$data['amount'];
            $investment->current_value = max(0, (float) $investment->current_value + $delta);
            $investment->save();

            return response()->json([
                'investment' => app(KitamoBootstrap::class)->investment($investment->fresh()->load('movimentos')),
            ]);
        });
    }

    private function marcarComTagDeAporte(Transaction $transaction): void
    {
        // Atenção aos nomes: o model Tag usa `nome`/`cor` (português) e a
        // relação em Transaction chama-se `tagsRelation()`, não `tags()`.
        $tag = Tag::firstOrCreate(
            ['user_id' => $transaction->user_id, 'nome' => self::TAG_APORTE],
            ['cor' => '#8B5CF6'],
        );

        $transaction->tagsRelation()->syncWithoutDetaching([$tag->id]);
    }

    private function autorizar(Request $request, Investment $investment): void
    {
        if ($investment->user_id !== $request->user()->id) {
            abort(404);
        }
    }
}
```

- [ ] **Step 3: Conferir os nomes de campo (já verificados, confirme que seguem assim)**

Run: `grep -n "fillable" -A 25 app/Models/Transaction.php && grep -n "function tagsRelation" -A 4 app/Models/Transaction.php && grep -n "fillable" -A 6 app/Models/Tag.php`

Esperado, conferido em 06/09/2026:
- `Transaction` tem `user_id, account_id, category_id, kind, status, amount, description, transaction_date, data_pagamento` — todos usados acima existem.
- A relação de tags chama-se **`tagsRelation()`**, não `tags()`.
- `Tag` usa **`nome`** e **`cor`**, não `name`/`color`.

Se algo divergir, ajuste o código para o que existe — não invente campos.

- [ ] **Step 4: Registrar as rotas**

Em `routes/web.php`, junto do bloco de rotas `api.*` (perto da linha 258):

```php
    Route::post('/api/investments', [InvestmentController::class, 'store'])->name('api.investments.store');
    Route::patch('/api/investments/{investment}', [InvestmentController::class, 'update'])->name('api.investments.update');
    Route::delete('/api/investments/{investment}', [InvestmentController::class, 'destroy'])->name('api.investments.destroy');
    Route::post('/api/investments/{investment}/aporte', [InvestmentController::class, 'aporte'])->name('api.investments.aporte');
```

Adicionar o import `use App\Http\Controllers\InvestmentController;` no topo do arquivo.

Adicionar também a rota da página:

```php
Route::get('/patrimonio', function () {
    return Inertia::render('Patrimonio/Index');
})->middleware(['auth', 'verified'])->name('patrimonio');
```

- [ ] **Step 5: Verificar que as rotas registram e a suíte passa**

Run: `php artisan route:list --name=investments && ./vendor/bin/phpunit tests/Unit/`
Expected: as 4 rotas listadas; todos os testes passando.

- [ ] **Step 6: Commit**

```bash
git add app/Http/Controllers/InvestmentController.php app/Support/KitamoBootstrap.php routes/web.php
git commit -m "feat(patrimonio): CRUD de investimentos e registro de aporte/resgate"
```

---

### Task 5: Excluir aportes dos relatórios de despesa

Sem isto o aporte é contado como gasto e o relatório mente. Mesma classe de bug que "fatura contada em dobro".

**Files:**
- Modify: o(s) arquivo(s) que já filtram a tag `transferencia` nos relatórios

**Interfaces:**
- Consumes: `InvestmentController::TAG_APORTE` (Task 4)
- Produces: relatórios que ignoram transações marcadas `aporte-investimento`

- [ ] **Step 1: Localizar todos os pontos que excluem `transferencia`**

Run: `grep -rn "transferencia" app/ --include=*.php | grep -i "tag\|whereDoesntHave\|exclu"`

Cada ponto que exclui `transferencia` de um total de despesa/receita precisa excluir `aporte-investimento` também. Liste os arquivos encontrados antes de editar.

- [ ] **Step 2: Aplicar a exclusão em cada ponto encontrado**

Siga exatamente o padrão que já existe no arquivo para `transferencia` — não introduza um mecanismo novo. Se o código usa um array de tags excluídas, acrescente a constante; se usa `whereDoesntHave`, acrescente a condição.

- [ ] **Step 3: Verificar**

Run: `./vendor/bin/phpunit tests/Unit/`
Expected: PASS.

Confira manualmente que um aporte com `afeta_caixa` não aparece no total de despesas do mês.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "fix(patrimonio): aporte nao conta como despesa nos relatorios"
```

---

### Task 6: Tela de patrimônio

**Files:**
- Create: `resources/js/Pages/Patrimonio/Index.vue`
- Modify: `resources/js/types/kitamo.ts` (tipo `Investment` e campo `investments` em `BootstrapData`)

**Interfaces:**
- Consumes: `bootstrap.investments` (Task 4)
- Produces: página em `/patrimonio`

- [ ] **Step 1: Adicionar o tipo TypeScript**

Em `resources/js/types/kitamo.ts`:

```ts
export type Investment = {
    id: string;
    name: string;
    assetClass: 'caixinha' | 'cdb' | 'tesouro' | 'acao' | 'fii' | 'cripto' | 'outro';
    institution: string | null;
    ticker: string | null;
    currentValue: number;
    totalAportado: number;
    rendimento: number;
    rentabilidade: number;
    priceSource: 'manual' | 'binance' | 'bcb';
    priceUpdatedAt: string | null;
    color: string | null;
    icon: string | null;
};
```

E acrescentar `investments: Investment[];` ao tipo `BootstrapData`.

- [ ] **Step 2: Criar a página**

Estrutura obrigatória, na ordem da spec:
1. **Patrimônio total** — número herói
2. **Aporte vs rendimento** — investido, valor atual e ganho isolado (o elemento mais útil da tela)
3. **Composição por classe** — barras proporcionais por `assetClass`
4. **Lista de posições** — cada uma com valor, rendimento e **"atualizado há X"**

Siga o padrão de shell das outras páginas (`Pages/Goals/Index.vue` como referência): `useIsMobile`, `MobileShell`/`DesktopShell`, `computed` sobre `page.props.bootstrap`.

Requisitos não negociáveis de UI:
- Rendimento negativo aparece em vermelho com sinal, **nunca** `Math.abs` (foi bug C5 da auditoria).
- Toda posição mostra a idade do preço. Para `priceSource === 'manual'` o rótulo é "editado por você"; para as demais, "atualizado há X".
- Estado vazio: convite explícito para cadastrar a primeira posição, não uma tela em branco.

- [ ] **Step 3: Verificar o build**

Run: `npm run build`
Expected: build sem erro de tipo.

- [ ] **Step 4: Commit**

```bash
git add resources/js/Pages/Patrimonio resources/js/types/kitamo.ts
git commit -m "feat(patrimonio): tela de patrimonio com aporte vs rendimento"
```

---

### Task 7: Modais de cadastro e aporte

**Files:**
- Create: `resources/js/Components/InvestmentModal.vue`
- Create: `resources/js/Components/AporteModal.vue`
- Modify: `resources/js/Pages/Patrimonio/Index.vue` (ligar os modais)

**Interfaces:**
- Consumes: rotas `api.investments.*` (Task 4)
- Produces: fluxo completo de cadastro/edição/aporte na tela

- [ ] **Step 1: Criar `InvestmentModal.vue`**

Campos: nome, classe de ativo (as 7 literais), instituição, ticker (só para `acao`/`fii`/`cripto`), valor atual, cor e ícone. Emite `save` com o payload que `api.investments.store` espera.

Use `requestJson` de `@/lib/kitamoApi`, como as demais telas.

- [ ] **Step 2: Criar `AporteModal.vue`**

Campos: tipo (`aporte`/`resgate`), valor, data, checkbox **"saiu da minha conta"** e, quando marcado, o seletor de conta.

O checkbox precisa de um texto explicando a consequência — algo como "registra também a saída no seu extrato". Sem isso o usuário não entende por que às vezes o saldo muda e às vezes não.

- [ ] **Step 3: Ligar na página com atualização otimista**

Ao salvar, atualizar a lista local com o `investment` devolvido pela resposta antes de qualquer `router.reload` — mesmo padrão adotado no toggle de transações. Nunca acessar `response.investment.id` sem checar que veio: foi exatamente o TypeError corrigido no commit `4d3251f`.

- [ ] **Step 4: Verificar o build**

Run: `npm run build`
Expected: sem erros.

- [ ] **Step 5: Commit**

```bash
git add resources/js/Components/InvestmentModal.vue resources/js/Components/AporteModal.vue resources/js/Pages/Patrimonio/Index.vue
git commit -m "feat(patrimonio): modais de cadastro e de aporte/resgate"
```

---

### Task 8: Card de patrimônio no Dashboard e navegação

**Files:**
- Modify: `resources/js/Pages/Dashboard.vue`
- Modify: os componentes de navegação (`Layouts/MobileShell.vue`, `Layouts/DesktopShell.vue`)

**Interfaces:**
- Consumes: `bootstrap.investments` (Task 4)
- Produces: entrada de navegação e card resumo

- [ ] **Step 1: Adicionar o card no Dashboard**

Card "Patrimônio total" mostrando saldo em contas + investimentos, com link para `/patrimonio`. Posicionar junto dos outros cards de resumo do topo.

- [ ] **Step 2: Adicionar o item de navegação**

Run: `grep -n "Metas\|goals" resources/js/Layouts/DesktopShell.vue resources/js/Layouts/MobileShell.vue`

Acrescentar "Patrimônio" seguindo exatamente o padrão do item "Metas" em cada shell.

- [ ] **Step 3: Verificar o build**

Run: `npm run build`
Expected: sem erros.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat(patrimonio): card no dashboard e item de navegacao"
```

---

### Task 9: Job diário de cotação

**Files:**
- Create: `app/Jobs/RefreshInvestmentPrices.php`
- Modify: `routes/console.php` (agendamento diário)

**Interfaces:**
- Consumes: `BinancePriceProvider` (Task 3), `Investment`, `InvestmentPrice` (Task 2)
- Produces: job agendado que atualiza posições `binance`

- [ ] **Step 1: Criar o job**

Para cada `Investment` ativo com `price_source === 'binance'` e `ticker` preenchido:
1. Ler o último `InvestmentPrice` do ticker como preço conhecido
2. Chamar `BinancePriceProvider::precoAtual($ticker, $ultimoPreco)`
3. Se o preço voltou e há `quantity`, atualizar `current_value = quantity * preco` e `price_updated_at = now()`
4. Gravar em `investment_prices` (respeitando o índice único `ticker+source+quoted_on` — use `updateOrCreate`)
5. Se o preço não voltou, **não escrever nada** e deixar `price_updated_at` antigo, para que a tela mostre a defasagem

- [ ] **Step 2: Agendar**

Em `routes/console.php`:

```php
Schedule::job(new \App\Jobs\RefreshInvestmentPrices())->dailyAt('06:00');
```

- [ ] **Step 3: Testar manualmente**

Run: `php artisan tinker --execute="dispatch_sync(new App\Jobs\RefreshInvestmentPrices()); echo 'ok';"`

Atenção: o Hostinger corta em 500 conexões MySQL/hora. Agrupe verificações num único `tinker --execute`.

- [ ] **Step 4: Commit**

```bash
git add app/Jobs/RefreshInvestmentPrices.php routes/console.php
git commit -m "feat(patrimonio): job diario de cotacao de cripto"
```

---

### Task 10: Cadastrar a caixinha do Mercado Pago e fazer deploy

Fecha o buraco concreto que motivou o módulo.

**Files:** nenhum (dados + deploy)

- [ ] **Step 1: Rodar as migrations no servidor**

```bash
cd /home/gabfelix/dev/kitamo-repo
rsync -az database/migrations/ hostinger-kitamo:/home/u626119115/domains/kitamo.com.br/public_html/database/migrations/
ssh hostinger-kitamo 'cd /home/u626119115/domains/kitamo.com.br/public_html && /opt/alt/php83/usr/bin/php artisan migrate --force'
```

- [ ] **Step 2: Subir backend e frontend**

```bash
npm run build
rsync -az public/build/ hostinger-kitamo:/home/u626119115/domains/kitamo.com.br/public_html/public/build/
rsync -az app/ hostinger-kitamo:/home/u626119115/domains/kitamo.com.br/public_html/app/
rsync -az routes/ hostinger-kitamo:/home/u626119115/domains/kitamo.com.br/public_html/routes/
ssh hostinger-kitamo 'cd /home/u626119115/domains/kitamo.com.br/public_html && /opt/alt/php83/usr/bin/php artisan optimize:clear'
```

Nunca use `--delete` em `public/build/`.

- [ ] **Step 3: Cadastrar a caixinha pela interface**

Pela tela `/patrimonio`, cadastrar: nome "Caixinha Mercado Pago", classe `caixinha`, instituição "Mercado Pago", valor R$ 1.628,47, fonte `manual`.

Fazer pela interface (e não por SQL) valida o fluxo real de ponta a ponta.

- [ ] **Step 4: Conferir o patrimônio total**

Confirmar na home que o card soma saldo das contas + R$ 1.628,47, e que o valor **não** aparece como receita nem despesa no mês.

---

## Notas de execução

- Rodar `./vendor/bin/phpunit tests/Unit/` depois de cada tarefa.
- A suíte atual tem 10 testes / 1.712 asserções. Nenhuma tarefa pode reduzir isso.
- O CI do GitHub Actions não entrega o frontend de forma confiável — use o deploy manual da Task 10.
