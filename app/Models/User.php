<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'phone',
        'avatar_path',
        'password',
        'is_admin',
        'auth_provider',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $appends = [
        'avatar_url',
        'profile_photo_url',
        'is_google_auth',
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
            'is_admin' => 'boolean',
            'last_backup_at' => 'datetime',
            'onboarding_completed_at' => 'datetime',
        ];
    }

    public function getAvatarUrlAttribute(): ?string
    {
        if (! $this->avatar_path) {
            return null;
        }

        // Se é uma URL externa (Google Avatar), retorna diretamente
        if (str_starts_with($this->avatar_path, 'http://') || str_starts_with($this->avatar_path, 'https://')) {
            return $this->avatar_path;
        }

        // Caso contrário, gera URL de storage local
        return Storage::url($this->avatar_path);
    }

    public function getIsGoogleAuthAttribute(): bool
    {
        return $this->auth_provider === 'google';
    }

    public function getProfilePhotoUrlAttribute(): ?string
    {
        return $this->avatar_url;
    }

    public function accounts()
    {
        return $this->hasMany(Account::class);
    }

    public function categories()
    {
        return $this->hasMany(Category::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function goals()
    {
        return $this->hasMany(Goal::class);
    }

    protected static function booted(): void
    {
        static::created(function (self $user) {
            $defaults = [
                ['nome' => 'Essencial', 'cor' => '#0F172A'],
                ['nome' => 'Urgente', 'cor' => '#EF4444'],
            ];

            foreach ($defaults as $tag) {
                Tag::firstOrCreate(
                    ['user_id' => $user->id, 'nome' => $tag['nome']],
                    ['id' => (string) Str::uuid(), 'cor' => $tag['cor']]
                );
            }
        });
    }
}
