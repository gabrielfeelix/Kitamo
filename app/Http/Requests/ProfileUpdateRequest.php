<?php

namespace App\Http\Requests;

use App\Models\User;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ProfileUpdateRequest extends FormRequest
{
    private function isLocalWithoutDatabaseDriver(): bool
    {
        return app()->environment('local') && ! extension_loaded('pdo_mysql') && ! extension_loaded('pdo_sqlite');
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => [
                'required',
                'string',
                'lowercase',
                'email',
                'max:255',
                ...($this->isLocalWithoutDatabaseDriver() ? [] : [Rule::unique(User::class)->ignore($this->user()->id)]),
            ],
            'phone' => ['nullable', 'string', 'max:30'],
        ];
    }
}
