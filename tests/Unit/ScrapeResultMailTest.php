<?php

namespace Tests\Unit;


use App\Mail\ScrapeResultMail;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

class ScrapeResultMailTest extends TestCase
{
    public function testScrapeResultMailContent()
    {
        Mail::fake();

        Mail::send(new ScrapeResultMail(['title' => 'Test Title', 'price' => '100']));

        Mail::assertSent(ScrapeResultMail::class, function ($mail) {
            return $mail->data['title'] === 'Test Title' && $mail->data['price'] === '100';
        });
    }
}
