FROM php:8.2-apache

# 1. Install required PHP extensions for OpenCart 4
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libzip-dev unzip libcurl4-openssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli zip curl

# 2. Enable Apache mod_rewrite
RUN a2enmod rewrite

# 3. Copy our setup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 4. Expose Apache port
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]