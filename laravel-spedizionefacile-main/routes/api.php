<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\WalletController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::prefix('wallet')->group(function () {
    Route::get('/balance', [WalletController::class, 'balance']);
    Route::get('/movements', [WalletController::class, 'movements']);
    Route::post('/top-up', [WalletController::class, 'topUp']);
    Route::post('/payment', [WalletController::class, 'payment']);
    Route::post('/payment-confirmation', [WalletController::class, 'confirmPayment']);
});

/* Route::middleware(['auth:sanctum'])->get('/me', [MeController::class]);
 */

// Registrazione
/* Route::middleware('web')->post('/custom-register', [RegisterController::class, 'register']); */

// Login e Logout
/* Route::middleware(['guest'])->post('/login', [TokenAuthenticationController::class, 'store']);
Route::middleware(['auth:sanctum'])->post('/logout', [TokenAuthenticationController::class, 'destroy']); */

/* ================= Recupera password ================= */
/* Route::post('/forgot-password', [PasswordResetRequestController::class, 'sendEmail']);
Route::post('/update-password', [ChangePasswordController::class, 'passwordResetProcess']); */



