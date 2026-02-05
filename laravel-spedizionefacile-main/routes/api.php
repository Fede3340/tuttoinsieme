<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

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




