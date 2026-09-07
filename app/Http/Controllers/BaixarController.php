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
                // A versão vai na URL para o navegador não reaproveitar um
                // APK antigo do cache. Sem isso o Gabriel baixou três
                // vezes e recebeu o arquivo velho, e o app "não mudava".
                'url' => '/' . self::ARQUIVO . '?v=' . File::lastModified($caminho),
                // Em MB com uma casa: "28,5 MB" diz mais que "29869056".
                'tamanho' => $this->emMegas(File::size($caminho)),
                'atualizado' => File::lastModified($caminho),
                'versao' => $this->versao(),
            ] : null,
        ]);
    }

    private function emMegas(int $bytes): string
    {
        return number_format($bytes / 1048576, 1, ',', '.') . ' MB';
    }

    /**
     * A versão publicada, escrita num arquivo ao lado do APK.
     *
     * Existe porque em 07/09/2026 o versionCode ficou travado em 1: o
     * Android ignora em silêncio a instalação de um APK com o mesmo
     * versionCode e mantém o app antigo, sem erro nenhum. Quem baixou
     * jurou que a versão nova era idêntica, e não tinha como conferir.
     * Agora dá pra comparar o que está no site com o que está em
     * Ajustes > Apps > Kitamo.
     */
    private function versao(): ?string
    {
        $arquivo = public_path('downloads/versao.txt');

        return File::exists($arquivo) ? trim(File::get($arquivo)) : null;
    }
}
