##### Деплой
Контейнер встановлюється в режимі демона. 
Порти 80 та 443 відкриваються у мережу сервера безпосередньо.

Опис використовуваних директорій:
1. `/var/www/letsencrypt` - Директорія тимчасових файлів Let'sEncrypt
2. `/etc/letsencrypt` - Директорія ssl-сертифікатів, створених certbot Let'sEncrypt
3. `/var/log/nginx` - Директорія логів
4. `/etc/nginx/sites-available` - Директорія Доступних конфігурацій сайтів
5. `/etc/nginx/sites-enabled` - Директорія Працюючих конфігурацій сайтів
6. `/etc/ssl/custom` - Директорія ssl-сертифікатів

Для одного контейнера на сервері необхідно:
- Директорію 2. /etc/letsencrypt необхідно змонтувати на сервер контейнера.  
- Директорію 3. /var/log/nginx необхідно змонтувати на сервер контейнера.

Якщо серверів декілька у кластері і контейнер встановлюється на кожен з них, то:
- Директорію 2. /etc/letsencrypt необхідно змонтувати у єдине загальнодоступне місце всіх серверів.
- Директорію 5. /etc/nginx/sites-enabled необхідно змонтувати у єдине загальнодоступне місце всіх серверів.
- Директорію 3. /var/log/nginx кожного контейнера необхідно змонтувати на кожен сервер індивідуально.

```yaml
services:
  proxy:
    container_name: proxy
    # build:
    #   dockerfile: /root/nginx-geoip2-alpine/Dockerfile.hetzner
    #   context: /root/nginx-geoip2-alpine
    #   args:
    #     - NGINX_VERSION=1.19.0
    image: registry.gitlab.com/olegnakone/nginx-geoip2-alpine:window-to-europe-1.19.0
    ports:
      - 80:80
      - 443:443
    volumes:
      - /root/nginx-sites-enabled:/etc/nginx/sites-enabled
      - /root/nginx-etc-letsencrypt:/etc/letsencrypt
      - /root/nginx-var-www-letsencrypt:/var/www/letsencrypt
    depends_on:
      - ts-soloveyko-media
      - dv-soloveyko-media
    restart: unless-stopped
```

##### Генерація вмісту файлу для модуля BasicAuth
https://httpd.apache.org/docs/current/misc/password_encryptions.html  
Режим: `bcrypt`  
Приклад з використанням утилти: `apache2-utils`:
```shell
$ htpasswd -nbB myName myPassword
myName:$2y$05$c4WoMPo3SXsafkva.HHa6uXQZWr7oboPiC2bT/r7q1BB8I2s0BRqC
```

##### Генерація сертифікатів Let'sEncrypt
```shell
certbot certonly \
--webroot --agree-tos \
--no-eff-email --email ext.nkn@gmail \
-w /var/www/letsencrypt \
-d cld.nkn.pp.ua

certbot certonly --webroot --agree-tos --no-eff-email --email ext.nkn@gmail.com -w /var/www/letsencrypt -d helig-olx-tracker.nkn.pp.ua
```
##### Simple Website Proxy Configuration
> ОБОВ'ЯЗКОВО ВІДРЕДАГУЙ НА СЕРВЕРІ
{.is-warning}

```apacheconf
upstream pacs-dev-dicom-hub-com {
    server 192.168.1.100:8082;
    server 192.168.1.101:8082;
}

map $http_upgrade $connection_upgrade {
     default Upgrade;
    close;
}

server {
    listen 80;
    server_name pacs-dev.dicom-hub.com;

    # access_log /var/log/nginx/pacs-dev.dicom-hub.com.access.log;
    # error_log /var/log/nginx/pacs-dev.dicom-hub.com.error.log;

    return 301 https://$host$request_uri;

    # include /etc/nginx/snippets/letsencrypt.conf;
}

server {
    listen 443 ssl http2;
    server_name  pacs-dev.dicom-hub.com;

    # access_log /var/log/nginx/pacs-dev.dicom-hub.com.access.log;
    # error_log /var/log/nginx/pacs-dev.dicom-hub.com.error.log;

    ssl_certificate /etc/letsencrypt/live/pacs-dev.dicom-hub.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pacs-dev.dicom-hub.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/pacs-dev.dicom-hub.com/fullchain.pem;
    include /etc/nginx/snippets/ssl.conf;

    client_max_body_size		64m;

    location / {
        proxy_pass            http://pacs-dev-dicom-hub-com;
        proxy_http_version    1.1;
        proxy_cache_bypass    $http_upgrade;
        proxy_set_header      Upgrade $http_upgrade;
        proxy_set_header      Connection keep-alive;
        proxy_set_header      Host $host;
        proxy_set_header      X-Forwarded-Proto $scheme;
        proxy_set_header      X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header      X-Real-IP $remote_addr;
    }

}
```

