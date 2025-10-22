FROM node:20 as build
WORKDIR /app
COPY ./site ./site
COPY ./admin ./admin
WORKDIR /app/site
RUN npm install && npm run build --configuration production
WORKDIR /app/admin
RUN npm install && npm run build --configuration production

FROM nginx:1.25
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/site/dist /usr/share/nginx/html/site
COPY --from=build /app/admin/dist /usr/share/nginx/html/admin
