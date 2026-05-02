#!/bin/bash
set -e

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

curl -LO "https://github.com/opencart/opencart/releases/download/${VERSION}/opencart-${VERSION}.zip"

# Unzip to a temporary location
unzip -q "opencart-${VERSION}.zip" -d /tmp/oc_source

# Find the upload directory (handles the nested parent folder automatically)
UPLOAD_DIR=$(find /tmp/oc_source -type d -name "upload" | head -n 1)

if [ -z "$UPLOAD_DIR" ]; then
    echo "❌ Error: Could not find 'upload' directory in ZIP."
    exit 1
fi

# Move files to web root
cp -r "$UPLOAD_DIR/." /var/www/html/
echo "📂 Files moved to /var/www/html/"

# Ensure admin directory exists before touching config
mkdir -p /var/www/html/admin

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