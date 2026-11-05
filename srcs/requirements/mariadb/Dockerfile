FROM debian:bookworm

# The package creates a default database: remove it so our script starts clean.
RUN apt-get update && apt-get install -y mariadb-server \
    && rm -rf /var/lib/mysql/* \
    && mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

COPY tools/setup.sh /setup.sh

EXPOSE 3306

ENTRYPOINT ["sh", "/setup.sh"]
