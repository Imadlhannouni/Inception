FROM debian:bookworm

RUN apt-get update -y && \
    apt-get upgrade -y && apt-get install -y wget && \
    apt-get install -y php8.2 php-fpm php-mysql mariadb-client && \
    mkdir -p /var/www/wordpress && \
    chown -R www-data:www-data /var/www/wordpress && \
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/auto_config.sh /usr/local/bin/auto_config.sh
RUN chmod +x /usr/local/bin/auto_config.sh

WORKDIR /var/www/wordpress

ENTRYPOINT ["/usr/local/bin/auto_config.sh"]

CMD ["php-fpm8.2", "-F"]