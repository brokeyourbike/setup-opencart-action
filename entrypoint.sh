#!/bin/bash

# 1. OS & Version Guards
if [[ "$(uname -s)" != "Linux" ]]; then
  echo "❌ Error: Linux only." && exit 1
fi

VERSION=$1
DB_HOSTNAME=$2
DB_USERNAME=$3
DB_PASSWORD=$4
DB_PORT=$5
ADMIN_PASS=$6

if [[ ! $VERSION =~ ^4\. ]]; then
  echo "❌ Error: Only OpenCart 4 is supported (Received: $VERSION)." && exit 1
fi

echo "📦 Preparing OpenCart $VERSION..."

# Download and Extract
curl -LO "https://github.com/opencart/opencart/releases/download/${VERSION}/opencart-${VERSION}.zip"
unzip -q "opencart-${VERSION}.zip" -d /tmp/oc
mv /tmp/oc/upload/* /var/www/html/

# Config & Permissions
touch /var/www/html/config.php /var/www/html/admin/config.php
chmod 777 /var/www/html/config.php /var/www/html/admin/config.php
chown -R www-data:www-data /var/www/html/

# 2. CLI Installation with all DB Params
echo "🚀 Running Installer (Host: $DB_HOSTNAME, Port: $DB_PORT)..."
php /var/www/html/install/cli_install.php install \
    --db_hostname "$DB_HOSTNAME" \
    --db_username "$DB_USERNAME" \
    --db_password "$DB_PASSWORD" \
    --db_database "opencart" \
    --db_driver "mysqli" \
    --db_port "$DB_PORT" \
    --username "admin" \
    --password "$ADMIN_PASS" \
    --email "test@example.com" \
    --http_server "http://localhost:8080/"

rm -rf /var/www/html/install

echo "✅ OpenCart 4 Setup Complete!"
apache2-foreground