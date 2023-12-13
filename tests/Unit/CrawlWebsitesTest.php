<?php

namespace Tests\Unit;

use Tests\TestCase;
use Illuminate\Support\Facades\Artisan;

class CrawlWebsitesTest extends TestCase
{
    public function testCrawlWebsitesCommand()
    {
        $this->withoutMockingConsoleOutput();

        $exitCode = Artisan::call('crawl:websites');

        $this->assertEquals(0, $exitCode);
    }
}
