<?php

use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\LogController;
use App\Http\Controllers\Admin\RolesController;
use App\Http\Controllers\Admin\PlanController;
use App\Http\Controllers\Admin\NotificationRuleController;
use App\Http\Controllers\Admin\UploadController;
use App\Http\Controllers\Admin\LeadsController;
use App\Http\Controllers\Admin\EmailCampaignController;
use App\Http\Controllers\Admin\NewsItemsController;
use App\Http\Controllers\AccountController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\ExportController;
use App\Http\Controllers\GoalController;
use App\Http\Controllers\GoalDepositController;
use App\Http\Controllers\DashboardApiController;
use App\Http\Controllers\TransferenciaController;
use App\Http\Controllers\TagController;
use App\Http\Controllers\TransactionTagsController;
use App\Http\Controllers\TransactionsApiController;
use App\Http\Controllers\UserApiController;
use App\Http\Controllers\BackupController;
use App\Http\Controllers\NotificationsController;
use App\Http\Controllers\NotificationPreferencesController;
use App\Http\Controllers\WidgetController;
use App\Http\Controllers\MoedasController;
use App\Http\Controllers\RelatoriosController;
use App\Http\Controllers\CreditCardController;
use App\Http\Controllers\CreditCardPageController;
use App\Http\Controllers\NewsletterController;
use App\Http\Controllers\NewsApiController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

if (app()->environment('local') && ! extension_loaded('pdo_mysql') && ! extension_loaded('pdo_sqlite')) {
    Route::get('/login', fn () => redirect()->route('dashboard'))->name('login');
    Route::post('/login', fn () => redirect()->route('dashboard'));
    Route::get('/register', fn () => redirect()->route('dashboard'))->name('register');
    Route::post('/register', fn () => redirect()->route('dashboard'));
    Route::post('/logout', fn () => redirect('/'))->name('logout');
}

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

// Fallback to refresh XSRF-TOKEN cookie (works even without Sanctum route).
Route::get('/csrf-cookie', fn () => response()->noContent())->name('csrf-cookie');

Route::redirect('/landingpage', '/');

// Landing page newsletter subscription (unauthenticated)
Route::post('/api/newsletter/subscribe', [NewsletterController::class, 'subscribe'])->name('api.newsletter.subscribe');

Route::get('/dashboard', function () {
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::get('/analysis', function () {
    return Inertia::render('Analysis');
})->middleware(['auth', 'verified'])->name('analysis');

Route::get('/analysis/compare', function () {
    return Inertia::render('Analysis/Compare');
})->middleware(['auth', 'verified'])->name('analysis.compare');

Route::get('/notifications', function () {
    return Inertia::render('Notifications/Index');
})->middleware(['auth', 'verified'])->name('notifications.index');

Route::get('/goals', function () {
    return Inertia::render('Goals/Index');
})->middleware(['auth', 'verified'])->name('goals.index');

Route::get('/goals/create', function () {
    return Inertia::render('Goals/Create');
})->middleware(['auth', 'verified'])->name('goals.create');

Route::get('/goals/{goalId}', function (string $goalId) {
    return Inertia::render('Goals/Show', [
        'goalId' => $goalId,
    ]);
})->middleware(['auth', 'verified'])->name('goals.show');

Route::get('/goals/{goalId}/edit', function (string $goalId) {
    return Inertia::render('Goals/Edit', [
        'goalId' => $goalId,
    ]);
})->middleware(['auth', 'verified'])->name('goals.edit');

Route::get('/settings', function () {
    return Inertia::render('Settings');
})->middleware(['auth', 'verified'])->name('settings');

Route::get('/settings/notifications', function () {
    return Inertia::render('Settings/Notifications');
})->middleware(['auth', 'verified'])->name('settings.notifications');

Route::get('/settings/categories', function () {
    $user = request()->user();
    $categoryModels = \App\Models\Category::query()
        ->whereNull('user_id')
        ->orWhere('user_id', $user->id)
        ->orderBy('is_default', 'desc')
        ->orderBy('name')
        ->get();

    $normalize = static fn (string $name): string => (string) \Illuminate\Support\Str::of($name)->trim()->lower()->ascii()->replaceMatches('/\s+/', ' ');
    $grouped = $categoryModels->groupBy(fn (\App\Models\Category $c) => $normalize($c->name) . '|' . $c->type);

    $categories = $grouped
        ->map(function ($items) use ($user) {
            /** @var \Illuminate\Support\Collection<int, \App\Models\Category> $items */
            $userCategory = $items->firstWhere('user_id', $user->id);
            $defaultCategory = $items->firstWhere('user_id', null);
            $chosen = $userCategory ?? $defaultCategory ?? $items->first();

            $color = $chosen?->color ?: $defaultCategory?->color;
            $icon = $chosen?->icon ?: $defaultCategory?->icon;

            return [
                'id' => (string) $chosen->id,
                'name' => $chosen->name,
                'type' => $chosen->type,
                'color' => $color,
                'icon' => $icon,
                'is_default' => (bool) $chosen->is_default,
            ];
        })
        ->values()
        ->sortBy('name')
        ->values();

    return Inertia::render('Settings/Categories', [
        'userCategories' => $categories,
    ]);
})->middleware(['auth', 'verified'])->name('settings.categories');

Route::get('/settings/tags', function () {
    $user = request()->user();
    $tags = \App\Models\Tag::where('user_id', $user->id)
        ->orderBy('nome')
        ->get()
        ->map(fn ($tag) => [
            'id' => (string) $tag->id,
            'nome' => $tag->nome,
            'cor' => $tag->cor,
        ]);

    return Inertia::render('Settings/Tags', [
        'userTags' => $tags,
    ]);
})->middleware(['auth', 'verified'])->name('settings.tags');

Route::get('/settings/appearance', function () {
    return Inertia::render('Settings/Appearance');
})->middleware(['auth', 'verified'])->name('settings.appearance');

Route::get('/settings/security', function () {
    return Inertia::render('Settings/SecurityPrivacy');
})->middleware(['auth', 'verified'])->name('settings.security');

Route::get('/settings/backup', function () {
    return Inertia::render('Settings/Backup');
})->middleware(['auth', 'verified'])->name('settings.backup');

Route::get('/settings/support', function () {
    return Inertia::render('Settings/Support');
})->middleware(['auth', 'verified'])->name('settings.support');

Route::get('/settings/about', function () {
    return Inertia::render('Settings/About');
})->middleware(['auth', 'verified'])->name('settings.about');

Route::get('/settings/home-widgets', function () {
    return Inertia::render('Settings/HomeWidgets');
})->middleware(['auth', 'verified'])->name('settings.home-widgets');

Route::get('/accounts', function () {
    return Inertia::render('Accounts/Index');
})->middleware(['auth', 'verified'])->name('accounts.index');

Route::get('/accounts/overview', function () {
    return Inertia::render('Accounts/Overview');
})->middleware(['auth', 'verified'])->name('accounts.overview');

Route::get('/accounts/search', function () {
    return Inertia::render('Accounts/Search');
})->middleware(['auth', 'verified'])->name('accounts.search');

Route::get('/accounts/my/{accountKey}', function (string $accountKey) {
    return Inertia::render('Accounts/Show', [
        'accountKey' => $accountKey,
    ]);
})->middleware(['auth', 'verified'])->name('accounts.show');

Route::get('/accounts/nubank', function () {
    return Inertia::render('Accounts/Checking');
})->middleware(['auth', 'verified'])->name('accounts.checking');

Route::get('/accounts/nubank-card', function () {
    return Inertia::render('Accounts/CreditCard');
})->middleware(['auth', 'verified'])->name('accounts.card');

Route::get('/meus-cartoes', function () {
    return Inertia::render('CreditCards/MyCards');
})->middleware(['auth', 'verified'])->name('credit-cards.my-cards');

Route::get('/cartoes/{account}', [CreditCardPageController::class, 'show'])
    ->middleware(['auth', 'verified'])
    ->name('credit-cards.show');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/exports/transactions', [ExportController::class, 'transactions'])->name('exports.transactions');
    Route::post('/accounts', [AccountController::class, 'store'])->name('accounts.store');
    Route::post('/categories', [CategoryController::class, 'store'])->name('categories.store');

    Route::post('/api/categories', [CategoryController::class, 'store'])->name('api.categories.store');
    Route::patch('/api/categories/{category}', [CategoryController::class, 'update'])->name('api.categories.update');
    Route::delete('/api/categories/{category}', [CategoryController::class, 'destroy'])->name('api.categories.destroy');

    Route::post('/api/contas', [AccountController::class, 'store'])->name('api.contas.store');
    Route::patch('/api/contas/{account}', [AccountController::class, 'update'])->name('api.contas.update');
    Route::delete('/api/contas/{account}', [AccountController::class, 'destroy'])->name('api.contas.destroy');
    Route::get('/api/contas-by-month', [AccountController::class, 'getByMonth'])->name('api.contas.by-month');

    Route::get('/api/cartoes', [CreditCardController::class, 'index'])->name('api.cartoes.index');
    Route::get('/api/cartoes-by-month', [CreditCardController::class, 'getByMonth'])->name('api.cartoes.by-month');
    Route::post('/api/cartoes/{cartao}/pagar-fatura', [CreditCardController::class, 'payInvoice'])->name('api.cartoes.pay-invoice');
    Route::post('/api/cartoes', [CreditCardController::class, 'store'])->name('api.cartoes.store');
    Route::patch('/api/cartoes/{cartao}', [CreditCardController::class, 'update'])->name('api.cartoes.update');
    Route::delete('/api/cartoes/{cartao}', [CreditCardController::class, 'destroy'])->name('api.cartoes.destroy');

    Route::post('/transactions', [TransactionController::class, 'store'])->name('transactions.store');
    Route::patch('/transactions/{transaction}', [TransactionController::class, 'update'])->name('transactions.update');
    Route::delete('/transactions/{transaction}', [TransactionController::class, 'destroy'])->name('transactions.destroy');
    Route::patch('/api/transactions/{transaction}/toggle-pago', [TransactionController::class, 'togglePago'])->name('api.transactions.toggle-pago');
    Route::get('/api/dashboard/projecao', [DashboardApiController::class, 'projecao'])->name('api.dashboard.projecao');
    Route::get('/api/dashboard/insights', [DashboardApiController::class, 'insights'])->name('api.dashboard.insights');
    Route::post('/api/transferencias/preview', [TransferenciaController::class, 'preview'])->name('api.transferencias.preview');
    Route::post('/api/transferencias', [TransferenciaController::class, 'executar'])->name('api.transferencias.executar');
    Route::get('/api/transactions', [TransactionsApiController::class, 'index'])->name('api.transactions.index');
    Route::post('/api/tags', [TagController::class, 'store'])->name('api.tags.store');
    Route::patch('/api/tags/{tag}', [TagController::class, 'update'])->name('api.tags.update');
    Route::delete('/api/tags/{tag}', [TagController::class, 'destroy'])->name('api.tags.destroy');
    Route::post('/api/transactions/{transaction}/tags', [TransactionTagsController::class, 'sync'])->name('api.transactions.tags.sync');
    Route::get('/api/user/profile', [UserApiController::class, 'profile'])->name('api.user.profile');
    Route::post('/api/user/onboarding', [UserApiController::class, 'markOnboardingDone'])->name('api.user.onboarding.post');
    Route::patch('/api/user/onboarding', [UserApiController::class, 'markOnboardingDone'])->name('api.user.onboarding');
    Route::patch('/api/user/theme', [UserApiController::class, 'updateTheme'])->name('api.user.theme');
    Route::post('/api/backup/create', [BackupController::class, 'create'])->name('api.backup.create');
    Route::get('/api/backup/download/{filename}', [BackupController::class, 'download'])->name('api.backup.download');
    Route::get('/api/backup/list', [BackupController::class, 'list'])->name('api.backup.list');
    Route::post('/api/backup/restore', [BackupController::class, 'restore'])->name('api.backup.restore');
    Route::get('/api/backup/status', [BackupController::class, 'status'])->name('api.backup.status');

    Route::get('/api/notifications', [NotificationsController::class, 'index'])->name('api.notifications.index');
    Route::patch('/api/notifications/{notification}/marcar-lida', [NotificationsController::class, 'marcarLida'])->name('api.notifications.read');
    Route::post('/api/notifications/marcar-todas-lidas', [NotificationsController::class, 'marcarTodasLidas'])->name('api.notifications.read-all');
    Route::delete('/api/notifications/{notification}', [NotificationsController::class, 'destroy'])->name('api.notifications.delete');
    Route::delete('/api/notifications/limpar-lidas', [NotificationsController::class, 'limparLidas'])->name('api.notifications.clear-read');
	    Route::get('/api/notifications/count-unread', [NotificationsController::class, 'countUnread'])->name('api.notifications.count-unread');
	    Route::get('/api/news', [NewsApiController::class, 'index'])->name('api.news.index');
	    Route::post('/api/news/{newsItem}/reaction', [NewsApiController::class, 'react'])->name('api.news.react');

    Route::patch('/api/user/notification-preferences', [NotificationPreferencesController::class, 'update'])->name('api.user.notification-preferences');
    Route::get('/api/widget/data', [WidgetController::class, 'data'])->name('api.widget.data');
    Route::get('/api/moedas', [MoedasController::class, 'index'])->name('api.moedas.index');
    Route::post('/api/moedas/converter', [MoedasController::class, 'converter'])->name('api.moedas.converter');
    Route::post('/api/relatorios/exportar', [RelatoriosController::class, 'exportar'])->name('api.relatorios.exportar');

    Route::post('/goals', [GoalController::class, 'store'])->name('goals.store');
    Route::patch('/goals/{goal}', [GoalController::class, 'update'])->name('goals.update');
    Route::delete('/goals/{goal}', [GoalController::class, 'destroy'])->name('goals.destroy');
    Route::post('/goals/{goal}/deposits', [GoalDepositController::class, 'store'])->name('goals.deposits.store');
});

	Route::middleware(['auth', 'verified', 'admin'])->group(function () {
	    Route::get('/admin', fn () => redirect()->route('admin.users.index'))->name('admin.index');
	    Route::get('/admin/users', [UserController::class, 'index'])->name('admin.users.index');
	    Route::post('/admin/users', [UserController::class, 'store'])->name('admin.users.store');
	    Route::patch('/admin/users/{user}', [UserController::class, 'update'])->name('admin.users.update');
	    Route::patch('/admin/users/{user}/password', [UserController::class, 'updatePassword'])->name('admin.users.password');
	    Route::delete('/admin/users/{user}', [UserController::class, 'destroy'])->name('admin.users.destroy');
	
	    Route::get('/admin/roles', [RolesController::class, 'index'])->name('admin.roles.index');
	    Route::patch('/admin/roles/{role}', [RolesController::class, 'update'])->name('admin.roles.update');
	    Route::get('/admin/logs', [LogController::class, 'index'])->name('admin.logs.index');
	    Route::get('/admin/logs/export', [LogController::class, 'export'])->name('admin.logs.export');
	    Route::get('/admin/plans', [PlanController::class, 'index'])->name('admin.plans.index');
	    Route::post('/admin/plans', [PlanController::class, 'store'])->name('admin.plans.store');
	    Route::patch('/admin/plans/{plan}', [PlanController::class, 'update'])->name('admin.plans.update');
	    Route::delete('/admin/plans/{plan}', [PlanController::class, 'destroy'])->name('admin.plans.destroy');

	    Route::get('/admin/notifications', [NotificationRuleController::class, 'index'])->name('admin.notifications.index');
	    Route::post('/admin/notifications', [NotificationRuleController::class, 'store'])->name('admin.notifications.store');
	    Route::patch('/admin/notifications/{rule}', [NotificationRuleController::class, 'update'])->name('admin.notifications.update');
	    Route::delete('/admin/notifications/{rule}', [NotificationRuleController::class, 'destroy'])->name('admin.notifications.destroy');
	    Route::post('/admin/notifications/{rule}/test', [NotificationRuleController::class, 'test'])->name('admin.notifications.test');

	    Route::post('/admin/uploads/images', [UploadController::class, 'image'])->name('admin.uploads.images');
	    Route::get('/admin/emails', [EmailCampaignController::class, 'index'])->name('admin.emails.index');
	    Route::post('/admin/emails', [EmailCampaignController::class, 'store'])->name('admin.emails.store');
	    Route::patch('/admin/emails/{campaign}', [EmailCampaignController::class, 'update'])->name('admin.emails.update');
	    Route::delete('/admin/emails/{campaign}', [EmailCampaignController::class, 'destroy'])->name('admin.emails.destroy');
	    Route::post('/admin/emails/{campaign}/send', [EmailCampaignController::class, 'sendNow'])->name('admin.emails.send');

	    Route::get('/admin/leads', [LeadsController::class, 'index'])->name('admin.leads.index');
	    Route::post('/admin/leads', [LeadsController::class, 'store'])->name('admin.leads.store');
	    Route::patch('/admin/leads/{lead}', [LeadsController::class, 'update'])->name('admin.leads.update');
	    Route::delete('/admin/leads/{lead}', [LeadsController::class, 'destroy'])->name('admin.leads.destroy');

	    Route::get('/admin/news', [NewsItemsController::class, 'index'])->name('admin.news.index');
	    Route::post('/admin/news', [NewsItemsController::class, 'store'])->name('admin.news.store');
	    Route::patch('/admin/news/{newsItem}', [NewsItemsController::class, 'update'])->name('admin.news.update');
	    Route::delete('/admin/news/{newsItem}', [NewsItemsController::class, 'destroy'])->name('admin.news.destroy');
	});

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__.'/auth.php';
