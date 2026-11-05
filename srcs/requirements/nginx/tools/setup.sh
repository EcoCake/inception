#!/bin/sh
set -e

# Created at start, not build, so the private key is never stored in the image.
[ -f /etc/ssl/certs/inception.crt ] || openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout /etc/ssl/private/inception.key \
    -out /etc/ssl/certs/inception.crt \
    -subj "/CN=$DOMAIN_NAME"

# exec replaces this script, so NGINX becomes PID 1 and receives stop signals.
exec nginx -g "daemon off;"
