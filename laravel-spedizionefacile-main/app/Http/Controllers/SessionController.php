<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class SessionController extends Controller
{
    public function firstStep(Request $request)
    {
        $validated = $request->validate([
            'shipment_details' => 'required|array',
            'shipment_details.origin_city' => 'required|string',
            'shipment_details.origin_postal_code' => 'required|string',
            'shipment_details.destination_city' => 'required|string',
            'shipment_details.destination_postal_code' => 'required|string',
            'shipment_details.date' => 'required|date',
            'packages' => 'required|array|min:1',
            'packages.*.package_type' => 'required|string|in:Pacco,Busta,Pallet,Valigia',
            'packages.*.weight' => 'nullable|numeric|min:0',
            'packages.*.first_size' => 'nullable|numeric|min:0',
            'packages.*.second_size' => 'nullable|numeric|min:0',
            'packages.*.third_size' => 'nullable|numeric|min:0',
            'packages.*.quantity' => 'nullable|integer|min:1',
        ]);

        // Salvo i dati nella sessione
        $request->session()->put('shipment_details', $validated['shipment_details']);
        $request->session()->put('packages', $validated['packages']);

        // Calcolo il prezzo totale
        $totalPrice = 0;
        foreach ($validated['packages'] as $package) {
            if (isset($package['single_price'])) {
                $totalPrice += $package['single_price'];
            }
        }

        // Se non c'è un prezzo singolo, calcolo basato su peso/volume
        if ($totalPrice === 0) {
            foreach ($validated['packages'] as $package) {
                $price = $this->calculatePrice($package);
                $totalPrice += $price * ($package['quantity'] ?? 1);
            }
        }

        $request->session()->put('total_price', $totalPrice);

        return response()->json([
            'message' => 'Preventivo calcolato',
            'total_price' => $totalPrice,
            'shipment_details' => $validated['shipment_details'],
            'packages' => $validated['packages'],
        ], 201);
    }

    private function calculatePrice($package)
    {
        $weight = isset($package['weight']) ? floatval($package['weight']) : 0;
        $volume = 0;

        // Calcolo volume
        if (isset($package['first_size']) && isset($package['second_size']) && isset($package['third_size'])) {
            $first = floatval($package['first_size']) / 100;
            $second = floatval($package['second_size']) / 100;
            $third = floatval($package['third_size']) / 100;
            $volume = $first * $second * $third;
        }

        $weightPrice = $this->getPriceByWeight($weight);
        $volumePrice = $this->getPriceByVolume($volume);

        return max($weightPrice, $volumePrice);
    }

    private function getPriceByWeight($weight)
    {
        if ($weight > 0 && $weight < 2) {
            return 9;
        } elseif ($weight >= 2 && $weight < 5) {
            return 12;
        } elseif ($weight >= 5 && $weight < 10) {
            return 18;
        } elseif ($weight >= 10 && $weight <= 25) {
            return 20;
        } else {
            return 20;
        }
    }

    private function getPriceByVolume($volume)
    {
        if ($volume > 0 && $volume < 0.008) {
            return 9;
        } elseif ($volume >= 0.008 && $volume < 0.02) {
            return 12;
        } elseif ($volume >= 0.02 && $volume < 0.04) {
            return 18;
        } elseif ($volume >= 0.04 && $volume <= 0.1) {
            return 20;
        } else {
            return 20;
        }
    }
}
