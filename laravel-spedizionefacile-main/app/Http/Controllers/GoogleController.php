<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Support\Str;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Laravel\Socialite\Facades\Socialite;

class GoogleController extends Controller
{
    // Reindirizza a Google
    public function redirectToGoogle() {
        return Socialite::driver('google')->stateless()->with(['prompt' => 'select_account consent'])->redirect();
    }

    // Callback da Google
    public function handleGoogleCallback() {
        $googleUser = Socialite::driver('google')->stateless()->user();

        // Trova o crea l’utente
        $user = User::updateOrCreate(
            ['email' => $googleUser->email],
            [
                'name' => $googleUser->user['given_name'],
                'surname' => $googleUser->user['family_name'],
                'telephone_number' => '0',
                'role' => 'Cliente',
                'password' => bcrypt(Str::random(16))
            ]
        );

        Auth::login($user);

        // Genera token Sanctum
        /* $token = $user->createToken('google-login')->plainTextToken; */

        return redirect(config('app.frontend_url') . '/account');

        // Reindirizza al frontend con token
        /* return redirect('http://localhost:3000/auth/callback')
            ->cookie(
                'auth_token',       // nome cookie
                $token,             // valore token
                60*24,              // durata in minuti (qui 1 giorno)
                '/',                // path
                'localhost',               // domain
                false,               // secure
                true                // HttpOnly
            ); */
    }
}
