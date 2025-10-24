FROM php:8.3-fpm

WORKDIR /var/www

RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libjpeg-dev libfreetype6-dev libonig-dev \
    && docker-php-ext-install pdo_mysql mbstring gd

COPY ./api /var/www
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

CMD ["php-fpm"]
EXPOSE 9000
