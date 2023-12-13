<?php

namespace App\Console\Commands;

use App\Models\Price;
use Illuminate\Console\Command;
use App\Http\Controllers\SpiderController;
use Illuminate\Http\Request;

class CrawlWebsites extends Command
{
    protected $signature = 'crawl:websites';
    protected $description = 'Crawl websites for price updates';

    public function __construct()
    {
        parent::__construct();
    }

    public function handle()
    {
        $spiderController = new SpiderController();

        $urls = Price::distinct()->pluck('url');
        foreach ($urls as $url) {
            $spiderController->crawl(new Request(['url' => $url]));
        }
    }
}

