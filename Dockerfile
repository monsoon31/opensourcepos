FROM php:8.2-apache AS ospos

RUN apt-get update && apt-get install -y libicu-dev libpng-dev libzip-dev unzip git \
    && docker-php-ext-install intl gd zip mysqli pdo_mysql

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

# STEP DIAGNOSTIK: Kita bongkar isi semua folder
RUN echo "--- ISI FOLDER /app ---" && ls -R /app

# Eksekusi dengan jalur yang paling mungkin
RUN if [ -f "opensourcepos/composer.json" ]; then \
        cd opensourcepos && composer install --no-dev --ignore-platform-reqs; \
    elif [ -f "composer.json" ]; then \
        composer install --no-dev --ignore-platform-reqs; \
    else \
        echo "FILE TIDAK ADA DI MANAPUN!" && exit 1; \
    fi

RUN a2enmod rewrite
RUN chown -R www-data:www-data /app
EXPOSE 80
