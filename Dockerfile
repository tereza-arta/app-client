FROM nginx:alpine

WORKDIR /front

COPY index.html ./
