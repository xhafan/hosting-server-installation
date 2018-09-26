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
ufw --force enable
rc-update add ufw

# install and start docker
apk add docker
rc-update add docker boot
mkdir /etc/docker && cp daemon.json /etc/docker # disable docker messing up iptables which breaks hosts firewall rules
service docker start

# install docker-compose
apk add py-pip
pip install --upgrade pip
pip install docker-compose

# create docker network for containers
docker network create --driver bridge --opt "com.docker.network.bridge.name"="br_docker" --subnet=172.16.0.0/16 xhafannet
               
# configure ufw firewall so docker containers can communicate (https://svenv.nl/unixandlinux/dockerufw/)
sed -i -e 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw
sed -i -e 's/*filter/*nat\n:POSTROUTING ACCEPT [0:0]\n-A POSTROUTING ! -o br_docker -s 172.16.0.0\/16 -j MASQUERADE\nCOMMIT\n*filter/g' /etc/ufw/before.rules
ufw reload