<?php

use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\AccountController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\GoalController;
use App\Http\Controllers\GoalDepositController;
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

Route::get('/dashboard', function () {
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::get('/analysis', function () {
    return Inertia::render('Analysis');
})->middleware(['auth', 'verified'])->name('analysis');

Route::get('/analysis/compare', function () {
    return Inertia::render('Analysis/Compare');
})->middleware(['auth', 'verified'])->name('analysis.compare');

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

Route::middleware(['auth', 'verified'])->group(function () {
    Route::post('/accounts', [AccountController::class, 'store'])->name('accounts.store');
    Route::post('/categories', [CategoryController::class, 'store'])->name('categories.store');

    Route::post('/transactions', [TransactionController::class, 'store'])->name('transactions.store');
    Route::patch('/transactions/{transaction}', [TransactionController::class, 'update'])->name('transactions.update');
    Route::delete('/transactions/{transaction}', [TransactionController::class, 'destroy'])->name('transactions.destroy');

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
