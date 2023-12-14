ARG NGINX_VERSION

FROM nginx:${NGINX_VERSION}-alpine

RUN apk update \
        && apk add \
            certbot \
            tzdata \
            logrotate \
    && cp /usr/share/zoneinfo/Europe/Kiev /etc/localtime \
    && echo "Europe/Kiev" > /etc/timezone \
    && apk del tzdata \
    && mkdir -p /var/www/letsencrypt/.well-known/acme-challenge

# Copying updated configuration file
COPY config/nginx.conf /etc/nginx/nginx.conf

# Copying files for Certbot
COPY config/snippets/ /etc/nginx/snippets/

# Copying sites-available
COPY config/sites-available/helig/ /etc/nginx/sites-enabled/

# Copying selfsigned certs
COPY ssl/ /etc/ssl/

# Copying Logrotate configurations
COPY config/logrotate-nginx /etc/logrotate.d/nginx
RUN chmod 644 /etc/logrotate.d/nginx

# Configuring weekly cert renewal command
RUN echo "0 3 * * 6 certbot renew && nginx -s reload" >> /etc/crontabs/root

EXPOSE 80
EXPOSE 443

STOPSIGNAL SIGTERM

# CMD ["nginx", "-g", "daemon off;"]
CMD crond -b && nginx -g 'daemon off;'

