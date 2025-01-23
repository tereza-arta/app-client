#FROM nginx:alpine
#
#WORKDIR /front
#
#COPY index.html ./

FROM nginx:alpine

USER 0

WORKDIR /front

#RUN unlink /etc/nginx/sites-enabled/default

COPY ./nginx-setup/* .
