<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Schedule::command('recorrencias:gerar-proximas')->dailyAt('02:05');
Schedule::command('backups:limpar-antigos')->weekly();

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');
Schedule::job(new \App\Jobs\ApplyRecurringTransactions())->dailyAt('02:00');
Schedule::job(new \App\Jobs\RecalculateAccountBalances())->hourly();
Schedule::job(new \App\Jobs\SyncGoalProgress())->dailyAt('02:30');
