<?php

use App\Http\Controllers\Admin\UserController;
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

Route::redirect('/landingpage', '/');

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
    return Inertia::render('Settings/Categories');
})->middleware(['auth', 'verified'])->name('settings.categories');

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

Route::get('/cartoes/{account}', [CreditCardPageController::class, 'show'])
    ->middleware(['auth', 'verified'])
    ->name('credit-cards.show');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/exports/transactions', [ExportController::class, 'transactions'])->name('exports.transactions');
    Route::post('/accounts', [AccountController::class, 'store'])->name('accounts.store');
    Route::post('/categories', [CategoryController::class, 'store'])->name('categories.store');

    Route::post('/api/contas', [AccountController::class, 'store'])->name('api.contas.store');
    Route::patch('/api/contas/{account}', [AccountController::class, 'update'])->name('api.contas.update');
    Route::delete('/api/contas/{account}', [AccountController::class, 'destroy'])->name('api.contas.destroy');

    Route::get('/api/cartoes', [CreditCardController::class, 'index'])->name('api.cartoes.index');
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
    Route::post('/api/transactions/{transaction}/tags', [TransactionTagsController::class, 'sync'])->name('api.transactions.tags.sync');
    Route::get('/api/user/profile', [UserApiController::class, 'profile'])->name('api.user.profile');
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
    Route::get('/admin', [UserController::class, 'index'])->name('admin.users.index');
    Route::patch('/admin/users/{user}/password', [UserController::class, 'updatePassword'])->name('admin.users.password');
});

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__.'/auth.php';
