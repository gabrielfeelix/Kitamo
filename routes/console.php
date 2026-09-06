<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Schedule::command('recorrencias:gerar-proximas')->dailyAt('02:05');
Schedule::command('backups:limpar-antigos')->weekly();
Schedule::job(new \App\Jobs\VerificarVencimentos())->dailyAt('08:00');
Schedule::job(new \App\Jobs\VerificarSaldoNegativo())->dailyAt('09:00');
Schedule::job(new \App\Jobs\EnviarResumoSemanal())->weeklyOn(1, '08:00');
Schedule::job(new \App\Jobs\ExpirarNotificacoes())->dailyAt('23:00');
Schedule::command('cambio:atualizar --base=BRL')->dailyAt('06:00');

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');
Schedule::job(new \App\Jobs\ApplyRecurringTransactions())->dailyAt('02:00');
Schedule::job(new \App\Jobs\RecalculateAccountBalances())->hourly();
Schedule::job(new \App\Jobs\SyncGoalProgress())->dailyAt('02:30');
Schedule::job(new \App\Jobs\RefreshInvestmentPrices())->dailyAt("06:30");
Schedule::job(new \App\Jobs\AnalisarPatrimonio())->monthlyOn(1, "07:00");
