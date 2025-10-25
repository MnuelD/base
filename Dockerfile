# ===============================
# Etapa 1: Backend Laravel
# ===============================
FROM php:8.3-fpm AS backend

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libjpeg-dev libfreetype6-dev libonig-dev \
    && docker-php-ext-install pdo_mysql mbstring gd

# Copiar e instalar dependências do Laravel
COPY ./api /var/www/html
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-dev --optimize-autoloader

# ===============================
# Etapa 2: Frontend Angular (site + admin)
# ===============================
FROM node:20 AS frontend

WORKDIR /app

# Build do site Angular
COPY ./site ./site
WORKDIR /app/site
RUN npm install && npm run build --configuration production

# Build do admin Angular
WORKDIR /app
COPY ./admin ./admin
WORKDIR /app/admin
RUN npm install && npm run build --configuration production

# ===============================
# Etapa 3: Nginx + PHP-FPM
# ===============================
FROM nginx:1.25

# Copiar configuração do Nginx
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

# Copiar builds do Angular
COPY --from=frontend /app/site/dist /var/www/html/site
COPY --from=frontend /app/admin/dist /var/www/html/admin

# Copiar backend Laravel
COPY --from=backend /var/www/html /var/www/html

# Instalar PHP-FPM e supervisord
RUN apt-get update && apt-get install -y php8.3-fpm supervisor && mkdir -p /var/log/supervisor

# Configuração do supervisord
RUN echo "[supervisord]\nnodaemon=true\n" > /etc/supervisor.conf && \
    echo "[program:php-fpm]\ncommand=php-fpm\nautostart=true\nautorestart=true\n" >> /etc/supervisor.conf && \
    echo "[program:nginx]\ncommand=nginx -g 'daemon off;'\nautostart=true\nautorestart=true\n" >> /etc/supervisor.conf

EXPOSE 80
CMD ["supervisord", "-c", "/etc/supervisor.conf"]
