<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WalletMovement extends Model
{
    protected $fillable = [
        'type',
        'amount',
        'currency',
        'status',
        'idempotency_key',
        'reference',
        'description',
    ];
}
