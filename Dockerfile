# ===============================
# Etapa 1: Build do Laravel (backend)
# ===============================
FROM php:8.3-fpm AS backend

WORKDIR /var/www/html

# Instalar dependências do sistema e extensões PHP
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libjpeg-dev libfreetype6-dev oniguruma-dev \
    && docker-php-ext-install pdo_mysql mbstring gd

# Copiar código do Laravel
COPY ./api /var/www/html

# Instalar dependências do Laravel
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-dev --optimize-autoloader

# ===============================
# Etapa 2: Build do Angular (frontend)
# ===============================
FROM node:20 AS frontend

WORKDIR /app

# Copiar e buildar o site Angular
COPY ./site ./site
WORKDIR /app/site
RUN npm install && npm run build --configuration production

# Copiar e buildar o admin Angular
COPY ../admin ./admin
WORKDIR /app/admin
RUN npm install && npm run build --configuration production

# ===============================
# Etapa 3: Combinar tudo com Nginx e PHP-FPM
# ===============================
FROM nginx:1.25

# Copiar configuração do Nginx
COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Copiar builds do Angular (site e admin)
COPY --from=frontend /app/site/dist /var/www/html/site
COPY --from=frontend /app/admin/dist /var/www/html/admin

# Copiar aplicação Laravel e PHP-FPM
COPY --from=backend /var/www/html /var/www/html

# Instalar supervisord para gerir PHP + Nginx juntos
RUN apt-get update && apt-get install -y supervisor && mkdir -p /var/log/supervisor

# Criar configuração do supervisord
RUN echo "[supervisord]\nnodaemon=true\n" > /etc/supervisor.conf && \
    echo "[program:php-fpm]\ncommand=php-fpm\nautostart=true\nautorestart=true\n" >> /etc/supervisor.conf && \
    echo "[program:nginx]\ncommand=nginx -g 'daemon off;'\nautostart=true\nautorestart=true\n" >> /etc/supervisor.conf

EXPOSE 80
CMD ["supervisord", "-c", "/etc/supervisor.conf"]
