<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\File;
use Inertia\Inertia;
use Inertia\Response;

/**
 * A página de download do app.
 *
 * O APK não vive no Git: 66MB por versão incharia o repositório e deixaria
 * o rsync do deploy lento. Ele sobe direto pro servidor por SSH, então a
 * página lê o que existe em disco em vez de confiar num número escrito à
 * mão — versão errada na tela é o tipo de coisa que faz o testador
 * instalar o APK velho e reportar bug já corrigido.
 */
class BaixarController extends Controller
{
    /** Onde o APK é publicado, relativo a public/. */
    private const ARQUIVO = 'downloads/kitamo.apk';

    public function __invoke(): Response
    {
        $caminho = public_path(self::ARQUIVO);
        $existe = File::exists($caminho);

        return Inertia::render('Site/Baixar', [
            'apk' => $existe ? [
                'url' => '/' . self::ARQUIVO,
                // Em MB com uma casa: "28,5 MB" diz mais que "29869056".
                'tamanho' => $this->emMegas(File::size($caminho)),
                'atualizado' => File::lastModified($caminho),
            ] : null,
        ]);
    }

    private function emMegas(int $bytes): string
    {
        return number_format($bytes / 1048576, 1, ',', '.') . ' MB';
    }
}
