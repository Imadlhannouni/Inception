FROM debian:bookworm

RUN apt-get update && apt-get install -y vsftpd

COPY conf/vsftpd.conf /etc/vsftpd.conf

CMD ["vsftpd"]