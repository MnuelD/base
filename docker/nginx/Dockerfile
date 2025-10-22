# Etapa 1: Build Angulars
FROM node:20 as build
WORKDIR /app

# Copiar e buildar o site Angular
COPY ./site ./site
WORKDIR /app/site
RUN npm install && npm run build --configuration production

# Copiar e buildar o admin Angular
COPY ./admin ./admin
WORKDIR /app/admin
RUN npm install && npm run build --configuration production

# Etapa 2: Servir com Nginx
FROM nginx:1.25
COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Copiar os ficheiros compilados
COPY --from=build /app/site/dist /usr/share/nginx/html/site
COPY --from=build /app/admin/dist /usr/share/nginx/html/admin

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
