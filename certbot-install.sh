#!/bin/bash

apt update -y
apt install certbot -y
apt install python3-certbot-nginx -y
certbot certonly --agree-tos --noninteractive --email your@email.com --webroot -d dev.test.padcllc.com -w /usr/share/nginx/html




name: Frontend workflow

on:
  push:
    branches: ["main"]

jobs:
  Image-build-push:
    runs-on: self-hosted

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Build and tag of docker image
        run: |
          docker build -t ${{ secrets.DOCKER_UNAME }}/app-client:${GITHUB_SHA::7} .

      - name: Test newly created build image
        run: docker run --rm -d --name front-cnt-0 -p 8084:80 ${{ secrets.DOCKER_UNAME }}/app-client:${GITHUB_SHA::7}

      - name: Push image to DockerHub
        if  : success()
        run : |
          docker stop front-cnt-0 || true
          docker rm front-cnt-0 || true
          docker login -u ${{ secrets.DOCKER_UNAME }} -p ${{ secrets.DOCKER_TOKEN }}
          docker push ${{ secrets.DOCKER_UNAME }}/app-client:${GITHUB_SHA::7}

  Change-image-tag-and-deploy:
    needs: Image-build-push
    runs-on: self-hosted

    steps:
      - name: Create docker container
        run: |
          if docker ps -a --format '{{.Names}}' | grep -q 'front-cnt'; then
            echo "Container with name 'front-cnt' already exists!"
            docker stop front-cnt || true
            docker rm front-cnt || true
            docker run --rm -d --name front-cnt --network host ${{ secrets.DOCKER_UNAME }}/app-client:${GITHUB_SHA::7}
          else
            docker run --rm -d --name front-cnt --network host ${{ secrets.DOCKER_UNAME }}/app-client:${GITHUB_SHA::7}
          fi

      - name: Generate Certbot certificate
        run: |
          docker exec front-cnt /bin/sh -c "ls -lt /custom-dir/"
          docker exec front-cnt /bin/sh -c "chmod +x /custom-dir/certbot-install.sh"
          docker exec front-cnt /bin/sh -c "ls -lt /custom-dir"
          #docker exec front-cnt /bin/sh -c "ls -lt"
          #docker exec front-cnt /bin/sh -c "bash certbot-install.sh"
          docker exec front-cnt /bin/sh -c "which certbot"
          docker exec front-cnt /bin/sh -c "bash /custom-dir/certbot-install.sh"

          #docker exec front-cnt /bin/sh -c "certbot certonly --non-interactive --agree-tos --no-eff-email --no-redirect --email 'an3146073@gmail.com' --cert-name whitelabel-proxy --domains "dev.test.padcllc.com""
          #docker exec front-cnt /bin/sh -c "/usr/bin/certbot --nginx --non-interactive --agree-tos --email an3146073@gmail.com --domains dev.test.padcllc.com --staging"
          #docker exec -u front-cnt /bin/sh -c "printf 'an3146073@gmail.com\nY\nY\n2\n' | /usr/bin/certbot --nginx"





FROM nginx

USER 0

RUN rm -rf /etc/nginx/conf.d/default.conf &&\
    rm -rf /usr/share/nginx/html/index.html

RUN apt update -y &&\
    apt install certbot -y &&\
    apt install python3-certbot-nginx -y &&\
    mkdir custom-dir

COPY index.html /usr/share/nginx/html/

COPY custom-nginx/test.conf /etc/nginx/conf.d/

COPY ./certbot-install.sh custom-dir/

EXPOSE 80

CMD ["bash", "-c", "nginx -g 'daemon off;' && /etc/init.d/nginx start"]	  
