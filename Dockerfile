FROM nginx:alpine

WORKDIR /app

COPY ./index.html ./
