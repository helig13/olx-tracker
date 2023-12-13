<h1>OLX tracker</h1>
Used to track price changes on OLX.ua

Stack: Laravel, MySQL, PHP, HTML, CSS, PHPUnit, Composer, <a href= 'https://github.com/FriendsOfPHP/Goutte'> Goutte</a>, <a href= 'https://mailtrap.io/'>Mailtrap</a>, Cron
<h3>User Interaction:</h3>

 Users submit a URL (from "olx.ua") and their email via a web form.

<h3>Server Processing:</h3>

Validates the submitted data. 
Checks for existing subscriptions and creates a new one if necessary.
Triggers the web crawler for the submitted URL.

<h3>Web Crawling:</h3>

Scrapes data such as product title and price from the URL.

<h3>Database Management:</h3>

Stores subscription details in the subscriptions table.
Records scraped data, particularly prices, ensuring unique URL entries.

<h3>Email Notifications:</h3>

Sends an initial confirmation email upon successful subscription.
Notifies subscribers of price changes, based on periodic checks of subscribed URLs.

<h1>Installation</h1>

<h3>Clone the Repository</h3>

    git clone https://github.com/helig13/olx-tracker.git

    cd olx-tracker

<h3>Install PHP Dependencies</h3>


    composer install

<h3>Environment Configuration</h3>

Copy the .env.example file to create a .env file and edit the .env file and set your application and database settings.


    cp .env.example .env



<h3>Generate Application Key</h3>



    php artisan key:generate

<h3>Database Migration and Seeding</h3>

Run migrations to set up your database schema:


    php artisan migrate


<h3>Running the Project</h3>

Start the Laravel development server:


    php artisan serve

Access the application at http://localhost:8000 or the URL provided in the terminal.

<h3>Running Scheduled Tasks</h3>

The scheduler needs to be triggered by a cron job on your server. Add the following cron entry on your server:

    cron

    cd /path-to-your-project && php artisan schedule:run >> /dev/null 2>&1

Replace /path-to-your-project with the actual path to your Laravel project.

This cron job will call Laravel's scheduler every minute, which in turn will execute your scheduled tasks based on their defined schedules in app/Console/Kernel.php.

<h3>Testing</h3>
 To run PHPUnit tests:


    php artisan test



Additional Information
Add any project-specific setup instructions, links to further documentation, or other relevant information.


<h1>Diagram:</h1>

<img src="./public/diagram.png">
