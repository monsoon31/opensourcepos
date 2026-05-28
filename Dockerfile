FROM php:8.2-apache AS ospos
LABEL maintainer="jekkos"

# 1. Tambahkan unzip, git, dan curl agar composer bisa bekerja
RUN apt-get update && apt-get install -y --no-install-recommends \
    libicu-dev \
    libgd-dev \
    unzip \
    git \
    curl \
    && docker-php-ext-install mysqli bcmath intl gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && a2enmod rewrite

# 2. Ambil binary Composer dari image resmi
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN echo "date.timezone = \"\${PHP_TIMEZONE}\"" > /usr/local/etc/php/conf.d/timezone.ini

WORKDIR /app

# 3. Copy source code
COPY --chown=www-data:www-data . /app

# 4. JALANKAN COMPOSER INSTALL (Ini kunci agar folder /vendor tercipta)
RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN chmod 750 /app/writable/logs /app/writable/uploads /app/writable/cache /app/public/uploads /app/public/uploads/item_pics \
    && chmod 640 /app/writable/uploads/importCustomers.csv \
    && ln -s /app/*[^public] /var/www \
    && rm -rf /var/www/html \
    && ln -nsf /app/public /var/www/html

# Tahap Dev (tetap sama)
FROM ospos AS ospos_dev
ARG USERID
ARG GROUPID
RUN echo "Adding user uid $USERID with gid $GROUPID"
RUN ( addgroup --gid $GROUPID ospos || true ) && ( adduser --uid $USERID --gid $GROUPID ospos )
RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini
