<?php

namespace Tests\Unit;

use App\Http\Controllers\SpiderController;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Request;
use Tests\TestCase;

class SpiderControllerTest extends TestCase
{
    /**
     * A basic feature test example.
     */
    use RefreshDatabase;

    public function testSubscribe()
    {
        $request = Request::create('/subscribe', 'POST', [
            'url' => 'https://www.olx.ua/d/uk/obyavlenie/montor-18-5-lg-19en33s-b-IDRPpj4.html?bs=olx_pro_listing',
            'email' => 'test@example.com'
        ]);

        $controller = new SpiderController();
        $response = $controller->subscribe($request);

        $this->assertEquals(302, $response->getStatusCode());
        $this->assertDatabaseHas('subscriptions', [
            'url' => 'https://www.olx.ua/d/uk/obyavlenie/montor-18-5-lg-19en33s-b-IDRPpj4.html?bs=olx_pro_listing',
            'user_email' => 'test@example.com'
        ]);
    }
}
