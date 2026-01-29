<?php

namespace App\Http\Controllers;

use App\Models\Transaction;
use Carbon\CarbonImmutable;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Symfony\Component\HttpFoundation\StreamedResponse;

class RelatoriosController extends Controller
{
    public function exportar(Request $request): StreamedResponse|Response
    {
        $user = $request->user();

        $data = $request->validate([
            'formato' => ['required', 'in:csv,excel,pdf'],
            'periodo_inicio' => ['required', 'date'],
            'periodo_fim' => ['required', 'date', 'after_or_equal:periodo_inicio'],
            'incluir_resumo' => ['nullable', 'boolean'],
            'incluir_graficos' => ['nullable', 'boolean'],
            'incluir_transacoes' => ['nullable', 'boolean'],
            'categorias' => ['nullable', 'array'],
            'categorias.*' => ['integer'],
            'contas' => ['nullable', 'array'],
            'contas.*' => ['integer'],
            'tipos' => ['nullable', 'array'],
            'tipos.*' => ['in:income,expense'],
            'status' => ['nullable', 'array'],
            'status.*' => ['in:pending,paid,received'],
        ]);

        $inicio = CarbonImmutable::parse($data['periodo_inicio'])->toDateString();
        $fim = CarbonImmutable::parse($data['periodo_fim'])->toDateString();
        $formato = $data['formato'];

        $includeSummary = (bool) ($data['incluir_resumo'] ?? true);
        $includeCharts = (bool) ($data['incluir_graficos'] ?? true);
        $includeTransactions = (bool) ($data['incluir_transacoes'] ?? true);

        $query = Transaction::query()
            ->with(['category', 'account'])
            ->where('user_id', $user->id)
            ->whereDate('transaction_date', '>=', $inicio)
            ->whereDate('transaction_date', '<=', $fim)
            ->orderBy('transaction_date')
            ->orderBy('id');

        if (!empty($data['categorias'])) {
            $query->whereIn('category_id', $data['categorias']);
        }

        if (!empty($data['contas'])) {
            $query->whereIn('account_id', $data['contas']);
        }

        if (!empty($data['tipos'])) {
            $query->whereIn('kind', $data['tipos']);
        }

        if (!empty($data['status'])) {
            $query->whereIn('status', $data['status']);
        }

        if ($formato === 'csv') {
            $filename = 'kitamo_relatorio_' . $inicio . '_a_' . $fim . '.csv';

            return response()->streamDownload(function () use ($query) {
                $out = fopen('php://output', 'w');

                fputcsv($out, [
                    'Data',
                    'Descrição',
                    'Categoria',
                    'Conta',
                    'Tipo',
                    'Valor',
                    'Moeda',
                    'Status',
                ]);

                $query->chunk(500, function ($rows) use ($out) {
                    foreach ($rows as $t) {
                        fputcsv($out, [
                            optional($t->transaction_date)->format('Y-m-d') ?? '',
                            $t->description,
                            $t->category?->name ?? '',
                            $t->account?->name ?? '',
                            $t->kind,
                            number_format((float) $t->amount, 2, '.', ''),
                            $t->moeda ?? 'BRL',
                            $t->status,
                        ]);
                    }
                });

                fclose($out);
            }, $filename, [
                'Content-Type' => 'text/csv; charset=UTF-8',
            ]);
        }

        $transactions = $query->get();
        $incomeTotal = (float) $transactions->where('kind', 'income')->sum('amount');
        $expenseTotal = (float) $transactions->where('kind', 'expense')->sum('amount');
        $netTotal = $incomeTotal - $expenseTotal;

        $expenseByCategory = $transactions
            ->where('kind', 'expense')
            ->groupBy(fn ($t) => (string) ($t->category?->name ?? 'Outros'))
            ->map(fn ($items) => (float) $items->sum('amount'))
            ->sortDesc()
            ->take(10);

        $expenseByDay = $transactions
            ->where('kind', 'expense')
            ->groupBy(fn ($t) => optional($t->transaction_date)->format('Y-m-d') ?? '')
            ->map(fn ($items) => (float) $items->sum('amount'))
            ->sortKeys();

        if ($formato === 'pdf') {
            $filename = 'kitamo_relatorio_' . $inicio . '_a_' . $fim . '.pdf';

            $pdf = Pdf::loadView('exports.report-pdf', [
                'inicio' => $inicio,
                'fim' => $fim,
                'includeSummary' => $includeSummary,
                'includeCharts' => $includeCharts,
                'includeTransactions' => $includeTransactions,
                'incomeTotal' => $incomeTotal,
                'expenseTotal' => $expenseTotal,
                'netTotal' => $netTotal,
                'expenseByCategory' => $expenseByCategory,
                'expenseByDay' => $expenseByDay,
                'transactions' => $transactions,
            ])->setPaper('a4');

            return response()->streamDownload(
                fn () => print($pdf->output()),
                $filename,
                ['Content-Type' => 'application/pdf']
            );
        }

        // Excel (.xlsx)
        $filename = 'kitamo_relatorio_' . $inicio . '_a_' . $fim . '.xlsx';
        $spreadsheet = new Spreadsheet();
        $sheetIndex = 0;

        $createSheet = function (string $title) use (&$spreadsheet, &$sheetIndex) {
            if ($sheetIndex === 0) {
                $sheet = $spreadsheet->getActiveSheet();
            } else {
                $sheet = $spreadsheet->createSheet();
            }
            $sheet->setTitle($title);
            $sheetIndex += 1;
            return $sheet;
        };

        if ($includeSummary || $includeCharts) {
            $sheet = $createSheet('Resumo');
            $sheet->setCellValue('A1', 'Relatório Kitamo');
            $sheet->setCellValue('A2', "Período: {$inicio} a {$fim}");
            $sheet->setCellValue('A4', 'Receitas');
            $sheet->setCellValue('B4', $incomeTotal);
            $sheet->setCellValue('A5', 'Despesas');
            $sheet->setCellValue('B5', $expenseTotal);
            $sheet->setCellValue('A6', 'Balanço');
            $sheet->setCellValue('B6', $netTotal);

            $row = 8;
            if ($includeCharts) {
                $sheet->setCellValue("A{$row}", 'Despesas por categoria');
                $row += 1;
                $sheet->setCellValue("A{$row}", 'Categoria');
                $sheet->setCellValue("B{$row}", 'Total');
                $row += 1;
                foreach ($expenseByCategory as $category => $total) {
                    $sheet->setCellValue("A{$row}", $category);
                    $sheet->setCellValue("B{$row}", $total);
                    $row += 1;
                }

                $row += 1;
                $sheet->setCellValue("A{$row}", 'Despesas por dia');
                $row += 1;
                $sheet->setCellValue("A{$row}", 'Data');
                $sheet->setCellValue("B{$row}", 'Total');
                $row += 1;
                foreach ($expenseByDay as $day => $total) {
                    if ($day === '') {
                        continue;
                    }
                    $sheet->setCellValue("A{$row}", $day);
                    $sheet->setCellValue("B{$row}", $total);
                    $row += 1;
                }
            }
        }

        if ($includeTransactions) {
            $sheet = $createSheet('Transações');
            $headers = ['Data', 'Descrição', 'Categoria', 'Conta', 'Tipo', 'Status', 'Valor', 'Moeda', 'Tags'];
            $col = 'A';
            foreach ($headers as $header) {
                $sheet->setCellValue($col . '1', $header);
                $col++;
            }

            $row = 2;
            foreach ($transactions as $t) {
                $sheet->setCellValue("A{$row}", optional($t->transaction_date)->format('Y-m-d') ?? '');
                $sheet->setCellValue("B{$row}", $t->description);
                $sheet->setCellValue("C{$row}", $t->category?->name ?? '');
                $sheet->setCellValue("D{$row}", $t->account?->name ?? '');
                $sheet->setCellValue("E{$row}", $t->kind);
                $sheet->setCellValue("F{$row}", $t->status);
                $sheet->setCellValue("G{$row}", (float) $t->amount);
                $sheet->setCellValue("H{$row}", $t->moeda ?? 'BRL');
                $sheet->setCellValue("I{$row}", is_array($t->tags) ? implode(',', $t->tags) : '');
                $row++;
            }
        }

        if ($sheetIndex === 0) {
            $sheet = $createSheet('Relatório');
            $sheet->setCellValue('A1', 'Nenhum dado selecionado para exportação.');
        }

        return response()->streamDownload(function () use ($spreadsheet) {
            $writer = new Xlsx($spreadsheet);
            $writer->save('php://output');
        }, $filename, [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ]);
    }
}
