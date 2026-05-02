#!/bin/bash
set -e

# We no longer need to download anything here!
DB_HOSTNAME=$2
DB_USERNAME=$3
DB_PASSWORD=$4
DB_PORT=$5
ADMIN_PASS=$6

# Ensure configs exist
mkdir -p /var/www/html/admin
touch /var/www/html/config.php /var/www/html/admin/config.php
chmod 777 /var/www/html/config.php /var/www/html/admin/config.php
chown -R www-data:www-data /var/www/html/

# Run the installer (takes ~3-5 seconds)
php /var/www/html/install/cli_install.php install \
    --db_hostname "$DB_HOSTNAME" --db_username "$DB_USERNAME" \
    --db_password "$DB_PASSWORD" --db_database "opencart" \
    --db_driver "mysqli" --db_port "$DB_PORT" \
    --username "admin" --password "$ADMIN_PASS" \
    --email "test@example.com" \
    --http_server "http://localhost:8080/"

rm -rf /var/www/html/install
apache2-foreground