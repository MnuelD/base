# ==========================
# STAGE 1 - Build Angular apps
# ==========================
FROM node:18 AS builder

# Define diretório de trabalho
WORKDIR /app

# Copia e build do site
COPY ./site ./site
WORKDIR /app/site
RUN npm install && npm run build

# Copia e build do admin
WORKDIR /app
COPY ./admin ./admin
WORKDIR /app/admin
RUN npm install && npm run build

# ==========================
# STAGE 2 - Nginx
# ==========================
FROM nginx:alpine

# Copia ficheiro de configuração
COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Copia build do Angular site e admin
COPY --from=builder /app/site/dist /var/www/html/site
COPY --from=builder /app/admin/dist /var/www/html/admin

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
