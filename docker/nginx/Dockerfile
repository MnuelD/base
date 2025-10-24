# Etapa 1: Build Angulars
FROM node:20 as build
WORKDIR /app

# Copiar e buildar o site Angular
COPY ./site ./site
WORKDIR /app/site
RUN npm install && npx ng build site --configuration production

# Copiar e buildar o admin Angular
COPY ./admin ./admin
WORKDIR /app/admin
RUN npm install && npx ng build admin --configuration production


# Etapa 2: Servir com Nginx
FROM nginx:1.25
COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Copiar ficheiros compilados para /var/www/html
COPY --from=build /app/site/dist/site /var/www/html/site
COPY --from=build /app/admin/dist/admin /var/www/html/admin

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]




