#!/bin/sh
set -e

chown -R mysql:mysql /var/lib/mysql

# Only on the first start: afterwards the data already exists in the volume.
if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db

    mariadbd --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_root_password)';
CREATE DATABASE \`$MYSQL_DATABASE\`;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';
GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
EOF
fi

# exec replaces this script, so MariaDB becomes PID 1 and receives stop signals.
# --log-warnings=1 keeps the healthcheck's passwordless ping out of the logs.
exec mariadbd --user=mysql --bind-address=0.0.0.0 --port=3306 --log-warnings=1
