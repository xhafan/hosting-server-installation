#!/bin/sh
set -x

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

mkdir xhafanblog
mkdir xhafanblog.git && cd xhafanblog.git
git init --bare
cd ..

echo "#!/bin/sh" > xhafanblog.git/hooks/post-receive
echo "GIT_WORK_TREE=$(pwd)/xhafanblog git checkout -f" >> xhafanblog.git/hooks/post-receive

