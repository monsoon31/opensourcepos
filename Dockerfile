FROM php:8.2-apache AS ospos

WORKDIR /app

# 1. Install dependencies (pakai cache yang sudah ada)
RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libzip-dev libonig-dev unzip git \
    && docker-php-ext-install intl gd zip mysqli pdo_mysql mbstring

# 2. Ambil Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Copy SEMUA file dari GitHub Runner ke Container
COPY . .

# 4. STEP KRUSIAL: Lihat struktur folder sebenarnya
# Kita cari di mana letak composer.json
RUN echo "--- CEK ROOT FOLDER ---" && ls -F
RUN echo "--- CEK SEMUA SUBFOLDER (Mencari composer.json) ---" && find . -name "composer.json"

# 5. Jalankan install menggunakan hasil pencarian 'find'
# Perintah ini akan otomatis masuk ke folder mana pun yang ada composer.json nya
RUN TARGET_DIR=$(find . -name "composer.json" -exec dirname {} \;) && \
    echo "Ditemukan composer.json di: $TARGET_DIR" && \
    cd "$TARGET_DIR" && \
    composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs

# 6. Setup Apache (Kita buat dinamis)
RUN TARGET_DIR=$(find . -name "composer.json" -exec dirname {} \;) && \
    PUBLIC_DIR="$WORKDIR/$TARGET_DIR/public" && \
    sed -ri -e "s!/var/www/html!$PUBLIC_DIR!g" /etc/apache2/sites-available/*.conf && \
    sed -ri -e "s!/var/www/!$PUBLIC_DIR!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN a2enmod rewrite
EXPOSE 80
