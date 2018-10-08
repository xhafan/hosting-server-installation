#!/bin/sh
set -x

# update packages list
echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories
echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
apk update

# install ufw firewall 
apk add ip6tables ufw@testing

# configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw limit SSH
ufw allow in 80/tcp
ufw allow in 443/tcp
rc-update add ufw

# configure ufw firewall when used with docker (https://github.com/moby/moby/issues/4737#issuecomment-419705925)
sed -i -e 's/# End required lines/:DOCKER-USER - [0:0]\n:ufw-user-input - [0:0]\n# End required lines/g' /etc/ufw/after.rules
sed -i -e 's/# don'"'"'t delete the '"'"'COMMIT'"'"'/-A DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\n-A DOCKER-USER -m conntrack --ctstate INVALID -j DROP\n-A DOCKER-USER -i eth0 -j ufw-user-input\n-A DOCKER-USER -i eth0 -j DROP\n\n# don'"'"'t delete the '"'"'COMMIT'"'"'/g' /etc/ufw/after.rules

ufw --force enable

# install and start docker
apk add docker
rc-update add docker boot
service docker start

# install docker-compose
apk add py-pip
pip install --upgrade pip
pip install docker-compose

# create data directory for postgresql DB
mkdir postgres-data

# SSL certificate
apk add openssl
mkdir dh-param

USE_LETSENCRYPT=false
DOMAIN=domain-name

read -p "Use let's encrypt [true/false]: " USE_LETSENCRYPT
read -p "Enter domain: " DOMAIN


if [ "${USE_LETSENCRYPT}" == "true" ]
then 
    LETSENCRYPT_EMAIL=ssl_certificate_email
    read -p "Enter SSL certificate email: " LETSENCRYPT_EMAIL
    docker run -it --rm \
      -v /docker-volumes/etc/letsencrypt:/etc/letsencrypt \
      -v /docker-volumes/var/lib/letsencrypt:/var/lib/letsencrypt \
      -v "/docker-volumes/var/log/letsencrypt:/var/log/letsencrypt" \
      certbot/certbot \
      certonly --webroot \
      --email ${LETSENCRYPT_EMAIL} --agree-tos --no-eff-email \
      -d ${DOMAIN}
else
    mkdir -p /docker-volumes/etc/letsencrypt/live/${DOMAIN}
    openssl req -x509 -newkey rsa:4096 -nodes \
      -keyout /docker-volumes/etc/letsencrypt/live/${DOMAIN}/privkey.pem \
      -out /docker-volumes/etc/letsencrypt/live/${DOMAIN}/fullchain.pem \
      -days 3650 -subj "/CN=${DOMAIN}"
fi

openssl dhparam -out ./dh-param/dhparam-2048.pem 2048
cp nginx.conf.example nginx.conf
sed -i -e "s/DOMAIN_NAME/${DOMAIN}/g" nginx.conf
