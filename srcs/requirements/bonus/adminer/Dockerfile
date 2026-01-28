FROM debian:bookworm

RUN apt-get update && apt install -y php php-mysql wget \
    && wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
    && mv adminer-4.8.1.php /var/www/html/index.php

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]