FROM php:8.2-apache AS ospos

# 1. Install library dasar (Tanpa embel-embel dulu supaya cepat)
RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libzip-dev libonig-dev unzip git \
    && docker-php-ext-install intl gd zip mysqli pdo_mysql mbstring

# 2. Ambil Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Pindah ke folder standar Apache
WORKDIR /var/www/html

# 4. Copy SEMUA file dari repo
COPY . .

# 5. Aktifkan Rewrite & Setup Apache
RUN a2enmod rewrite
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# 6. Jalankan install SECARA SEDERHANA
# Jika ini gagal lagi, berarti di GitHub kamu memang TIDAK ADA file composer.json
RUN composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs

# 7. Beri izin folder
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
