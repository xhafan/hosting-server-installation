#!/bin/sh
set -x

# install awall firewall 
apk add ip6tables
apk add -u awall
modprobe ip_tables
modprobe ip6_tables
cp awallpolicy.json /etc/awall/optional
awall enable awallpolicy
awall activate -f
rc-update add iptables
rc-update add ip6tables
rc-service iptables start
rc-service ip6tables start

# install and start docker
echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories
apk update
apk add docker
rc-update add docker boot
service docker start

# install docker-compose
apk add py-pip
pip install --upgrade pip
pip install docker-compose
