FROM debian:bookworm

RUN apt-get update && apt-get install -y php8.2-fpm php8.2-cli php8.2-mysql curl \
    && curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp \
    && mkdir -p /run/php /var/www/html \
    && sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/setup.sh /setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["sh", "/setup.sh"]
