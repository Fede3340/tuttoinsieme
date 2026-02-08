<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class SessionController extends Controller
{
    public function show()
    {
        return response()->json([
            'data' => [
                'shipment_details' => session()->get('shipment_details', []),
                'packages' => session()->get('packages', []),
                'services' => session()->get('services', null),
                'total_price' => session()->get('total_price', 0),
                'step' => session()->get('step', 1),
            ],
        ]);
    }

    public function firstStep(Request $request)
    {
        $validated = $request->validate([
            'shipment_details.origin_city' => ['required', 'string'],
            'shipment_details.origin_postal_code' => ['required', 'string'],
            'shipment_details.destination_city' => ['required', 'string'],
            'shipment_details.destination_postal_code' => ['required', 'string'],
            'shipment_details.date' => ['required', 'string'],
            'packages' => ['required', 'array', 'min:1'],
            'packages.*.package_type' => ['required', 'string'],
            'packages.*.quantity' => ['required', 'integer', 'min:1'],
            'packages.*.weight' => ['required'],
            'packages.*.first_size' => ['required'],
            'packages.*.second_size' => ['required'],
            'packages.*.third_size' => ['required'],
            'packages.*.single_price' => ['required', 'numeric', 'min:0'],
            'packages.*.weight_price' => ['nullable', 'numeric', 'min:0'],
            'packages.*.volume_price' => ['nullable', 'numeric', 'min:0'],
        ]);

        $shipmentDetails = $validated['shipment_details'];
        $packages = collect($validated['packages'])->map(function (array $package) {
            $package['single_price'] = (float) $package['single_price'];

            return $package;
        })->values()->all();

        $totalPrice = collect($packages)->sum(function (array $package) {
            return $package['single_price'];
        });

        session()->put('shipment_details', $shipmentDetails);
        session()->put('packages', $packages);
        session()->put('total_price', round($totalPrice, 2));
        session()->put('step', 2);

        return response()->json([
            'data' => [
                'shipment_details' => session()->get('shipment_details'),
                'packages' => session()->get('packages'),
                'services' => session()->get('services', null),
                'total_price' => session()->get('total_price'),
                'step' => session()->get('step'),
            ],
        ]);
    }
}

