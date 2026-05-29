FROM php:8.2-apache AS ospos

# 1. Install System Dependencies & PHP Extensions
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install intl gd zip mysqli pdo_mysql mbstring bcmath

# 2. Ambil Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Set Working Directory ke standar Apache
WORKDIR /var/www/html

# 4. Copy SEMUA file dari root repo ke /var/www/html
COPY . .

# 5. Jalankan Composer Install (Langsung di root karena filenya ada di sini)
RUN composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs

# 6. Aktifkan Apache Rewrite
RUN a2enmod rewrite

# 7. Arahkan Document Root Apache ke folder public
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 8. Set Permissions (Sangat Penting untuk CI4)
RUN chown -R www-data:www-data /var/www/html/writable /var/www/html/public/uploads

EXPOSE 80
