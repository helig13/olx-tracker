<?php

namespace App\Http\Controllers;

use App\Models\Price;
use App\Models\Subscription;
use App\Notifications\CrawlResultNotification;
use App\Notifications\SubscriptionConfirmationNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Notification;
use RoachPHP\Roach;
use Goutte\Client;


class SpiderController extends Controller
{

    public function subscribe(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'url' => [
                'required',
                'url',
                function ($attribute, $value, $fail) {
                    if (!str_contains(parse_url($value, PHP_URL_HOST), 'olx.ua')) {
                        $fail('The ' . $attribute . ' must be a valid URL from the olx.ua domain.');
                    }
                },
            ],
        ]);

        $url = $request->input('url');
        $userEmail = $request->input('email');

        // initial crawling
        $initialData = $this->crawl(new Request(['url' => $url]));

        // to check if the url already exists in the prices table
        $price = Price::updateOrCreate(
            ['url' => $url],
            ['price' => $initialData['price']]
        );

          // to check if the user already subscribed to the url
        if (!Subscription::where('user_email', $userEmail)->where('url', $url)->exists()) {
            Subscription::create([
                'user_email' => $userEmail,
                'url' => $url
            ]);

            // confirmation email
            Notification::route('mail', $userEmail)
                ->notify(new SubscriptionConfirmationNotification());
        } else {
            return redirect()->back()->with('message', 'You already subscribed to this url');
        }

        return redirect()->back()->with('message', 'You subscribed successfully, please check your email for confirmation');
    }

    public function crawl(Request $request)
    {

        // Goutte client
        $client = new Client();
        $crawler = $client->request('GET', $request->input('url'));

        // name and price
        $title = $crawler->filter('.css-1juynto')->text();
        $price = $crawler->filter('.css-12vqlj3')->text();
        $data = [
            'title' => $title,
            'price' => $price,
        ];

        // to check if the url already exists in the prices table
        $existingPrice = Price::where('url', $request->input('url'))->first();

        if ($existingPrice && $existingPrice->price !== $price) {
            $existingPrice->update(['price' => $price, 'checked_at' => now()]);

            // to get all subscribers to the url
            $subscribers = Subscription::where('url', $request->input('url'))->get();

            foreach ($subscribers as $subscriber) {
                Notification::route('mail', $subscriber->user_email)
                    ->notify(new CrawlResultNotification($data));
            }
        }
        return $data;
    }

    public function index(Request $request)
    {
        return view('tracker');
    }


}
