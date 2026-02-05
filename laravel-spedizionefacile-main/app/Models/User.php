<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Models\User;
use App\Models\Order;
use App\Models\Package;
use App\Models\CartUser;
use App\Models\UserAddress;
use Illuminate\Support\Str;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    /* HasApiTokens, */

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'surname',
        'email',
        'telephone_number',
        'password',
        'role',
        'identifier',
        'email_verified_at',
        'stripe_account_id'
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'created_at',
        'email_verified_at',
        'updated_at',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /* protected static function booted()
    {
        static::creating(function ($user) {
            $user->identifier = (string) Str::uuid();
        });
    } */

    public function isAdmin(): bool {
        return $this->role === 'Admin';
    }

    public function addresses() {
        return $this->hasMany(UserAddress::class);
    }

    /* public function cart() {
        return $this->belongsToMany(Package::class, 'cart_user')
                    ->withPivot('quantity')
                    ->withTimestamps();
    } */

    /* public function cart() {
        return $this->hasMany(CartUser::class); // carrello dell'utente
    } */

    public function packages() {
        return $this->hasMany(Package::class);
    }

    public function orders() {
        return $this->hasMany(Order::class);
    }
    
    /* public function emailVerification() {
        return $this->hasOne(User::class);
    } */
}
