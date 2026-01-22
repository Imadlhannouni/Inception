FROM debian:bookworm

RUN apt-get update -y && \
    apt-get install -y nginx openssl && \
    mkdir -p /etc/nginx/ssl /var/run/nginx && \
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=MA/ST=Rabat/L=Rabat/O=42/OU=42/CN=ilhannou.42.fr" && \
    rm -rf /var/lib/apt/lists/*

COPY conf/inception.conf /etc/nginx/sites-enabled/default

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
