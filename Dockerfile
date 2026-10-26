FROM php:8.3-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
        libfreetype6-dev libjpeg62-turbo-dev libpng-dev libzip-dev libicu-dev libonig-dev libxml2-dev unzip git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" bcmath gd intl pdo_mysql zip exif mbstring xml \
    && a2enmod rewrite headers \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN { \
        echo 'memory_limit=512M'; \
        echo 'upload_max_filesize=64M'; \
        echo 'post_max_size=64M'; \
        echo 'max_execution_time=300'; \
    } > /usr/local/etc/php/conf.d/akaunting.ini \
    && sed -ri 's!AllowOverride None!AllowOverride All!g' /etc/apache2/apache2.conf

WORKDIR /var/www/html

COPY docker/entrypoint.sh /usr/local/bin/akaunting-entrypoint
RUN sed -i 's/\r$//' /usr/local/bin/akaunting-entrypoint && chmod +x /usr/local/bin/akaunting-entrypoint

ENTRYPOINT ["akaunting-entrypoint"]
CMD ["apache2-foreground"]
