FROM node:20 AS build

WORKDIR /app
COPY ./admin ./admin
COPY ./site ./site

RUN cd admin && npm install && npm run build
RUN cd site && npm install && npm run build

