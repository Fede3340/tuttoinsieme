<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;

class StripeConnectController extends Controller
{
   /*  public function connect() {
        $query = http_build_query([
            'client_id' => config('services.stripe.client_id'),
            'response_type' => 'code',
            'scope' => 'read_write',
            'redirect_uri' => url('/api/stripe/callback'),
        ]);

        return response()->json([
            'url' => 'https://connect.stripe.com/oauth/authorize?' . $query
        ]);
    }

    public function callback(Request $request) {
        $response = Http::asForm()->post('https://connect.stripe.com/oauth/token', [
            'client_secret' => config('services.stripe.secret'),
            'code' => $request->code,
            'grant_type' => 'authorization_code',
        ]);

        $stripeAccountId = $response['stripe_user_id'];

        $user = Auth::user();
        $user->stripe_account_id = $stripeAccountId;
        $user->save();

        return redirect(config('app.frontend_url') . '/account');
    } */

    /* public function createAccount() {
        $stripe = new StripeClient(config('services.stripe.secret'));

        $account = $stripe->accounts->create([
            'type' => 'express',           // tipo Express
            'country' => 'IT',             // paese
            'email' => 'test+' . uniqid() . '@example.com', // email fittizia
            'capabilities' => [
                'transfers' => ['requested' => true],      // abilita i trasferimenti
            ],
        ]);

        // Salviamo l'account ID dell'utente collegato
        $user = Auth::user();
        $user->stripe_account_id = $account->id;
        $user->save();
    } */
}
