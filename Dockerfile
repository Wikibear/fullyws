FROM php:8.5-apache

# System-Pakete für PHP-Extensions
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libssl-dev \
    libicu-dev \
    libmagickwand-dev \
    libcurl4-openssl-dev \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# GD (mit JPEG + Freetype) + alle Standard Extensions parallel kompilieren
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    mysqli \
    pdo \
    pdo_mysql \
    intl \
    zip \
    bcmath \
    soap \
    xml \
    mbstring \
    exif \
    opcache

# PECL Extensions
RUN pecl install redis imagick \
    && docker-php-ext-enable redis imagick \
    && rm -rf /tmp/pear

# OPcache Konfiguration optimieren
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# PHP Konfiguration
RUN { \
    echo 'memory_limit=256M'; \
    echo 'upload_max_filesize=64M'; \
    echo 'post_max_size=64M'; \
    echo 'max_execution_time=300'; \
} > /usr/local/etc/php/conf.d/custom.ini

# Apache Module aktivieren
RUN a2enmod rewrite headers expires deflate actions

# Nicht-root User für bessere Security (optional, aber empfohlen)
RUN chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

CMD ["apache2-foreground"]

