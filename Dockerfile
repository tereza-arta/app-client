FROM nginx:alpine

WORKDIR /front-app

COPY ./index.html ./
