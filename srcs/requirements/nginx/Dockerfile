FROM debian:bookworm

RUN apt-get update && \
	apt-get install -y nginx openssl && \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/inception.key -out /etc/nginx/ssl/inception.crt -subj "/C=MA/ST=Rabat/L=Rabat/O=42/OU=42/CN=ilhannou.42.fr"


