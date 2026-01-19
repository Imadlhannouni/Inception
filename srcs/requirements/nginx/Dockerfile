FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y nginx openssl && \
    mkdir -p /etc/nginx/ssl /var/run/nginx && \
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=MA/ST=Rabat/L=Rabat/O=42/OU=42/CN=ilhannou.42.fr" && \
    chmod 755 /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/sites-enabled/default

CMD [ "nginx", "-g", "daemon off;" ]
