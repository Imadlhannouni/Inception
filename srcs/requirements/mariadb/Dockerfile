FROM debian:bookworm

RUN apt-get update -y && \
    apt-get install -y mariadb-server && \
    mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

COPY conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/maria.sh /usr/local/bin/maria.sh

RUN chmod +x /usr/local/bin/maria.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/maria.sh"]