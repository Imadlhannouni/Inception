FROM debian:bookworm

RUN apt-get update -y && \
    apt-get upgrade -y && apt-get install -y wget && \
    apt-get install -y php8.2 php-fpm php-mysql mariadb-client && \
    wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /var/www && \
	cd /var/www && tar -xzf wordpress-6.0-fr_FR.tar.gz && rm wordpress-6.0-fr_FR.tar.gz && \
    chown -R www-data:www-data /var/www/wordpress && \
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/auto_config.sh /usr/local/bin/auto_config.sh
RUN chmod +x /usr/local/bin/auto_config.sh

WORKDIR /var/www/wordpress

ENTRYPOINT ["/usr/local/bin/auto_config.sh"]

CMD ["php-fpm8.2", "-F"]