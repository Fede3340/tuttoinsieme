<?php

namespace App\Http\Controllers;

use App\Models\WalletMovement;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class WalletController extends Controller
{
    public function balance(): JsonResponse
    {
        $credits = WalletMovement::query()
            ->where('status', 'confirmed')
            ->where('type', 'credit')
            ->sum('amount');

        $debits = WalletMovement::query()
            ->where('status', 'confirmed')
            ->where('type', 'debit')
            ->sum('amount');

        return response()->json([
            'balance' => $credits - $debits,
            'currency' => 'EUR',
        ]);
    }

    public function movements(): JsonResponse
    {
        $movements = WalletMovement::query()
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'data' => $movements,
        ]);
    }

    public function topUp(Request $request): JsonResponse
    {
        $data = $request->validate([
            'amount' => ['required', 'numeric', 'min:0.01'],
            'currency' => ['nullable', 'string', 'size:3'],
            'idempotency_key' => ['required', 'string', 'max:64'],
            'description' => ['nullable', 'string', 'max:255'],
        ]);

        $movement = DB::transaction(function () use ($data) {
            $existing = WalletMovement::where('idempotency_key', $data['idempotency_key'])->first();

            if ($existing) {
                return $existing;
            }

            return WalletMovement::create([
                'type' => 'credit',
                'amount' => $data['amount'],
                'currency' => $data['currency'] ?? 'EUR',
                'status' => 'confirmed',
                'idempotency_key' => $data['idempotency_key'],
                'description' => $data['description'] ?? 'Ricarica portafoglio',
            ]);
        });

        return response()->json([
            'data' => $movement,
        ], 201);
    }

    public function payment(Request $request): JsonResponse
    {
        $data = $request->validate([
            'amount' => ['required', 'numeric', 'min:0.01'],
            'currency' => ['nullable', 'string', 'size:3'],
            'idempotency_key' => ['required', 'string', 'max:64'],
            'reference' => ['required', 'string', 'max:64'],
            'description' => ['nullable', 'string', 'max:255'],
        ]);

        $movement = DB::transaction(function () use ($data) {
            $existing = WalletMovement::where('idempotency_key', $data['idempotency_key'])->first();

            if ($existing) {
                return $existing;
            }

            return WalletMovement::create([
                'type' => 'debit',
                'amount' => $data['amount'],
                'currency' => $data['currency'] ?? 'EUR',
                'status' => 'pending',
                'idempotency_key' => $data['idempotency_key'],
                'reference' => $data['reference'],
                'description' => $data['description'] ?? 'Pagamento in attesa di conferma',
            ]);
        });

        return response()->json([
            'data' => $movement,
        ], 201);
    }

    public function confirmPayment(Request $request): JsonResponse
    {
        $data = $request->validate([
            'reference' => ['required', 'string', 'max:64'],
            'status' => ['nullable', 'in:confirmed,failed'],
        ]);

        $movement = WalletMovement::where('reference', $data['reference'])
            ->where('type', 'debit')
            ->first();

        if (! $movement) {
            return response()->json([
                'message' => 'Pagamento non trovato.',
            ], 404);
        }

        $status = $data['status'] ?? 'confirmed';

        if ($movement->status === $status) {
            return response()->json([
                'data' => $movement,
            ]);
        }

        if ($status === 'confirmed') {
            $credits = WalletMovement::query()
                ->where('status', 'confirmed')
                ->where('type', 'credit')
                ->sum('amount');

            $debits = WalletMovement::query()
                ->where('status', 'confirmed')
                ->where('type', 'debit')
                ->sum('amount');

            $available = $credits - $debits;

            if ($available < $movement->amount) {
                return response()->json([
                    'message' => 'Saldo insufficiente per confermare il pagamento.',
                ], 422);
            }
        }

        $movement->status = $status;
        $movement->save();

        return response()->json([
            'data' => $movement,
        ]);
    }
}
