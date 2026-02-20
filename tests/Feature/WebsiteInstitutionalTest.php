<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WebsiteInstitutionalTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->withoutVite();
    }

    public function test_public_website_pages_render_successfully(): void
    {
        $urls = [
            '/',
            '/produto',
            '/funcionalidades',
            '/seguranca',
            '/precos',
            '/recursos',
            '/empresa',
            '/contato',
            '/privacidade',
            '/termos',
        ];

        foreach ($urls as $url) {
            $this->get($url)->assertOk();
        }
    }

    public function test_contact_endpoint_stores_valid_submission(): void
    {
        $response = $this->postJson('/api/site/contact', [
            'name' => 'Maria Pessoa',
            'email' => 'maria@example.com',
            'objective' => 'duvida-produto',
            'message' => 'Gostaria de entender melhor como funciona a projeção.',
            'source' => 'test-suite',
            'company' => '',
        ]);

        $response->assertOk()->assertJson(['ok' => true]);

        $this->assertDatabaseHas('website_inquiries', [
            'email' => 'maria@example.com',
            'objective' => 'duvida-produto',
            'source' => 'test-suite',
        ]);
    }

    public function test_contact_endpoint_rejects_invalid_payload(): void
    {
        $response = $this->postJson('/api/site/contact', [
            'name' => '',
            'email' => 'nao-e-email',
            'objective' => '',
            'message' => '',
        ]);

        $response->assertStatus(422);
    }

    public function test_contact_endpoint_honeypot_does_not_store_inquiry(): void
    {
        $response = $this->postJson('/api/site/contact', [
            'name' => 'Bot Example',
            'email' => 'bot@example.com',
            'objective' => 'duvida-planos',
            'message' => 'Mensagem automatizada',
            'company' => 'filled',
        ]);

        $response->assertStatus(202)->assertJson(['ok' => true]);

        $this->assertDatabaseMissing('website_inquiries', [
            'email' => 'bot@example.com',
        ]);
    }

    public function test_newsletter_subscription_still_works(): void
    {
        $response = $this->postJson('/api/newsletter/subscribe', [
            'name' => 'Lead Pessoa',
            'email' => 'lead@example.com',
            'source' => 'test-newsletter',
        ]);

        $response->assertOk()->assertJson(['ok' => true]);

        $this->assertDatabaseHas('newsletter_leads', [
            'email' => 'lead@example.com',
            'source' => 'test-newsletter',
        ]);
    }
}
