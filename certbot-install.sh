#!/bin/bash

apt update -y
apt install certbot -y
apt install python3-certbot-nginx -y
/usr/bin/certbot --nginx --non-interactive --agree-tos --email an3146073@gmail.com --domains dev.test.padcllc.com --staging
