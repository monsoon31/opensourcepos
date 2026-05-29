FROM php:8.2-apache AS ospos

# 1. Install Dependencies (Lengkap)
RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libzip-dev libonig-dev libjpeg62-turbo-dev \
    libfreetype6-dev unzip git \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install intl gd zip mysqli pdo_mysql mbstring bcmath

# 2. Setup Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /app

# 3. COPY KHUSUS (Kita ambil langsung foldernya)
# Kita asumsikan struktur di GitHub adalah opensourcepos/composer.json
COPY . .

# 4. TRICK: Jika folder opensourcepos ada, kita pindah ke sana. 
# Jika tidak ada, kita tetap di root.
RUN if [ -d "opensourcepos" ]; then \
        cd opensourcepos && composer install --no-dev --ignore-platform-reqs; \
    else \
        composer install --no-dev --ignore-platform-reqs; \
    fi

# 5. Apache & Permissions
RUN a2enmod rewrite && \
    CONF="/etc/apache2/sites-available/000-default.conf" && \
    if [ -d "/app/opensourcepos/public" ]; then \
        sed -i 's!/var/www/html!/app/opensourcepos/public!g' $CONF; \
    else \
        sed -i 's!/var/www/html!/app/public!g' $CONF; \
    fi

RUN chown -R www-data:www-data /app
EXPOSE 80
