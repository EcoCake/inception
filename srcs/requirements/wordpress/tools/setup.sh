#!/bin/sh
set -e

URL="https://$DOMAIN_NAME"
[ "$HTTPS_PORT" = 443 ] || URL="$URL:$HTTPS_PORT"

alias wp="wp --allow-root --url=$URL"

[ -f wp-load.php ] || wp core download

[ -f wp-config.php ] || wp config create --skip-check \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$(cat /run/secrets/db_password)" \
    --dbhost=mariadb

if ! wp core is-installed; then
    wp core install --skip-email \
        --url="$URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$(cat /run/secrets/wp_admin_password)" \
        --admin_email="$WP_ADMIN_EMAIL"
    wp user create "$WP_USER" "$WP_USER_EMAIL" --role=author \
        --user_pass="$(cat /run/secrets/wp_user_password)"
    # Publish comments from logged-in users without waiting for moderation.
    wp option update comment_previously_approved 0
fi

# Done on every start, so the site keeps working if HTTPS_PORT changes.
wp option update home "$URL"
wp option update siteurl "$URL"

chown -R www-data:www-data /var/www/html

# exec replaces this script, so php-fpm becomes PID 1 and receives stop signals.
# -F keeps it in the foreground.
exec php-fpm8.2 -F
