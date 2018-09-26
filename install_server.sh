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
