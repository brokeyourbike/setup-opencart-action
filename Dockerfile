FROM php:8.2-apache

# 1. Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libzip-dev unzip libcurl4-openssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli zip curl

RUN a2enmod rewrite

# 2. Accept the version as a build argument
ARG OC_VERSION

# 3. Pre-download and extract at BUILD time
RUN curl -LO "https://github.com/opencart/opencart/releases/download/${OC_VERSION}/opencart-${OC_VERSION}.zip" \
    && unzip -q "opencart-${OC_VERSION}.zip" -d /tmp/oc_source \
    && UPLOAD_DIR=$(find /tmp/oc_source -type d -name "upload" | head -n 1) \
    && cp -r "$UPLOAD_DIR/." /var/www/html/ \
    && rm -rf /tmp/oc_source "opencart-${OC_VERSION}.zip"

# 4. Prepare for runtime
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]