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
    docker build -t certbox-no-pax -f Dockerfile.certbox-no-pax . # https://github.com/certbot/certbot/issues/5737#issuecomment-388020342
    LETSENCRYPT_EMAIL=ssl_certificate_email
    read -p "Enter SSL certificate email: " LETSENCRYPT_EMAIL
    docker run -it --rm \
      -p 80:80 \
      -v /docker-volumes/etc/letsencrypt:/etc/letsencrypt \
      -v /docker-volumes/var/lib/letsencrypt:/var/lib/letsencrypt \
      -v "/docker-volumes/var/log/letsencrypt:/var/log/letsencrypt" \
      certbox-no-pax \
      certonly \
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

mkdir -p /docker-volumes/data/letsencrypt # directory for Let's encrypt SSL certificate renewal process
(crontab -l ; echo "0 23 * * * docker run --rm -it --name certbot -v /docker-volumes/etc/letsencrypt:/etc/letsencrypt -v /docker-volumes/var/lib/letsencrypt:/var/lib/letsencrypt -v /docker-volumes/data/letsencrypt:/data/letsencrypt -v /docker-volumes/var/log/letsencrypt:/var/log/letsencrypt certbox-no-pax renew --webroot -w /data/letsencrypt --quiet && docker restart nginx") | sort - | uniq - | crontab - # trying to renew SSL certificate every day at 23h (https://www.humankode.com/ssl/how-to-set-up-free-ssl-certificates-from-lets-encrypt-using-docker-and-nginx)
