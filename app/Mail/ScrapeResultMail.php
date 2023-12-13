<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class ScrapeResultMail extends Mailable
{
    use Queueable, SerializesModels;

    public $data;
    private mixed $title;

    public function __construct($data)
    {
        $this->data = $data;
        $this->title = $data['title'];
    }

    public function build()
    {
        return $this->view('emails.scrape_result')
            ->with('data', $this->data);
    }

}

