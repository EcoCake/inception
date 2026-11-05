FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl \
    && rm /etc/nginx/sites-enabled/default /var/www/html/*

COPY config/default /etc/nginx/conf.d/default.conf
COPY tools/setup.sh /setup.sh

EXPOSE 443

ENTRYPOINT ["sh", "/setup.sh"]
