FROM php:8.3-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    nginx \
    supervisor

# Clear cache (no .build-deps needed)

# Install PHP extensions
RUN apk add --no-cache oniguruma-dev && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create symlinks for nginx
# php symlink already exists, skipped

WORKDIR /var/www

# Copy existing application
COPY . /var/www

# Create Laravel directories and set permissions
RUN mkdir -p bootstrap/cache storage/app/public storage/logs storage/framework/cache storage/framework/sessions storage/framework/views \
    && chmod -R 775 bootstrap/cache storage \
    && chown -R www-data:www-data bootstrap/cache storage

# Composer install
RUN composer install --no-dev --optimize-autoloader



CMD ["php-fpm"]

