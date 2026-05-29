# 1. Gunakan base image PHP dengan Apache
FROM php:8.1-apache

# 2. Set folder kerja di dalam container
WORKDIR /app

# 3. Install library sistem yang dibutuhkan OSPOS & PHP Extensions
# Tanda \ di akhir baris artinya perintahnya masih berlanjut ke bawah
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# 4. Install ekstensi PHP yang diwajibkan CodeIgniter 4
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
    intl \
    gd \
    zip \
    mysqli \
    pdo_mysql \
    mbstring \
    bcmath

# 5. Aktifkan fitur rewrite Apache (agar link website tidak error)
RUN a2enmod rewrite

# 6. Install Composer (alat untuk download library PHP)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 7. Copy file library dulu (agar build lebih cepat)
COPY composer.json composer.lock ./

# 8. Jalankan install library (Step yang tadi error)
RUN composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs

# 9. Copy seluruh kode aplikasi dari laptop/github ke container
COPY . .

# 10. Beri izin akses folder agar web bisa nulis log & upload gambar
RUN chown -R www-data:www-data /app/writable /app/public/uploads

# 11. Buka port 80
EXPOSE 80
