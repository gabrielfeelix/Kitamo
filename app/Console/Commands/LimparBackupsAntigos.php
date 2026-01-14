<?php

namespace App\Console\Commands;

use App\Models\Backup;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;

class LimparBackupsAntigos extends Command
{
    protected $signature = 'backups:limpar-antigos {--days=90 : Apaga backups com mais de N dias}';

    protected $description = 'Remove backups antigos do storage e do banco.';

    public function handle(): int
    {
        $days = max(1, (int) $this->option('days'));
        $limit = now()->subDays($days);

        $backups = Backup::query()
            ->where('created_at', '<', $limit)
            ->get();

        $deleted = 0;

        foreach ($backups as $backup) {
            $path = "backups/{$backup->user_id}/{$backup->filename}";
            if (Storage::exists($path)) {
                Storage::delete($path);
            }

            $backup->delete();
            $deleted++;
        }

        $this->info("Backups antigos limpos: {$deleted}");

        return self::SUCCESS;
    }
}

