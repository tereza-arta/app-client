FROM nginx

USER 0

RUN rm -rf /etc/nginx/conf.d/default.conf &&\
    rm -rf /usr/share/nginx/html/index.html

COPY index.html /usr/share/nginx/html/

COPY custom-nginx/test.conf /etc/nginx/conf.d/

EXPOSE 80

CMD ["bash", "-c", "nginx -g 'daemon off;' && /etc/init.d/nginx start"]
