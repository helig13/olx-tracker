FROM debian as composer

COPY . /var/www/html

WORKDIR /var/www/html

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update -qy && \
    apt-get install -qy \
    git \
    curl \
    cron \
    php8.2 \
    php8.2-mysql \
    php8.2-xml \
    php-xml \
    php-mbstring


RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer && \
    composer install --optimize-autoloader --no-dev


RUN echo "*/1 * * * * php artisan schedule:run" >> /etc/cron.d/app-sched


FROM node:18 as node

RUN mkdir /app

RUN mkdir -p  /app
WORKDIR /app

COPY . .

COPY --from=composer /var/www/html/vendor /app/vendor

RUN npm install && npm run build






FROM composer

WORKDIR /var/www/html

COPY --from=node /app/public /var/www/html/public/

RUN chown -R www-data:www-data /var/www/html/public

# ENTRYPOINT [ "php", "artisan", "serve", "--host", "0.0.0.0", "--port", "8000" ]
CMD cron && php artisan serve --host=0.0.0.0 --port=8000