# Menggunakan AS ospos sesuai permintaan cicd.yml
FROM php:8.1-apache AS ospos

# Set folder kerja
WORKDIR /app

# 1. Install library sistem
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

# 2. Install ekstensi PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
    intl \
    gd \
    zip \
    mysqli \
    pdo_mysql \
    mbstring \
    bcmath

# 3. Aktifkan rewrite Apache
RUN a2enmod rewrite

# 4. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. Copy file composer (Menggunakan wildcard * agar composer.lock opsional)
# Ini triknya: kalau composer.lock tidak ada, build tidak akan gagal
COPY composer.js[n] composer.loc[k] ./

# 6. Jalankan install library
RUN composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs

# 7. Copy seluruh kode aplikasi
COPY . .

# 8. Beri izin akses folder
RUN chown -R www-data:www-data /app/writable /app/public/uploads

# 9. Buka port 80
EXPOSE 80
