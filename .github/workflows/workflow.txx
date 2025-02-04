name: Frontend workflow

on:
  push:
    branches: ["main"]

jobs:
  Image-build-push:
    runs-on: ubuntu-latest

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
          fi  
          docker run --rm -d --name front-cnt --network host ${{ secrets.DOCKER_UNAME }}/app-client:${GITHUB_SHA::7}
          docker exec front-cnt /bin/sh -c "bash /custom-dir/certbot-install.sh"
          docker exec front-cnt /bin/sh -c "/usr/bin/certbot --nginx --non-interactive --agree-tos --email an3146073@gmail.com --domains dev.test.padcllc.com --staging"
          #docker exec front-cnt /bin/sh -c "/usr/bin/certbot --nginx --non-interactive --agree-tos --email an3146073@gmail.com --domains dev.test.padcllc.com --staging"
          #docker exec front-cnt /bin/sh -c printf 'an3146073@gmail.com\nY\nY\n2\n' | sudo certbot --nginx
          #docker stop front-cnt-0
