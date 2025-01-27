#ARG PASS

FROM nginx

USER 0

RUN rm -rf /etc/nginx/conf.d/default.conf &&\
    rm -rf /usr/share/nginx/html/index.html
#    mkdir /etc/nginx/certs

RUN apt update -y &&\
    apt install certbot -y &&\
    apt install python3-certbot-nginx -y

RUN printf 'an3146073@gmail.com\nY\nY\n2\n' | certbot --nginx

#RUN openssl req -x509 -newkey rsa:2048 -days 30 -nodes -passout pass:$PASS \
#    -keyout /etc/nginx/certs/ssl.key -out /etc/nginx/certs/ssl.crt \
#    -subj "/C=AM/ST=Shirak/L=City/O=Organization/OU=Unit/CN=example.com"

COPY index.html /usr/share/nginx/html/

COPY custom-nginx/test.conf /etc/nginx/conf.d/

EXPOSE 80

CMD ["bash", "-c", "nginx -g 'daemon off;' && /etc/init.d/nginx start"]

