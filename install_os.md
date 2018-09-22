* Mount Apline Linux [iso](https://alpinelinux.org/downloads) (for virtual machines there is a smaller virtual iso)
* Login as root
* Run setup-alpine (install the system into a [disk](https://wiki.alpinelinux.org/wiki/Install_to_disk))
* Reboot
* Login as root with a password
* Update OS to the latest version - [tutorial](https://wiki.alpinelinux.org/wiki/Upgrading_Alpine#Upgrading_to_latest_release)
* After reboot check the latest version: cat /etc/alpine-release
* 
* Login as root with a password
* Add ssh by following [this](https://wiki.alpinelinux.org/wiki/Setting_up_a_ssh-server) tutorial
* Add a new user: adduser <username\>
* Log off root from the main console  
* Login via SSH (putty app for windows) as the new user    
* 
* Login as root (run su)
* Add git: apk add git
* Logoff as root (run exit)
* 
* Download the installation script: git clone https://github.com/xhafan/hosting-server-installation.git
* Change the working directory to hosting-server-installation: cd hosting-server-installation
* 
* Login as root (run su)
* Execute the server installation script: ./install_server.sh
* Logoff as root (run exit)
* 
* Execute the blog installation script: ./install_xhafanblog.sh
* 
* Locally, on your working machine, clone xhafan's blog: git clone https://github.com/xhafan/blog.git
* Go to the root of the cloned blog repository on your working machine, and add the server as a remote so the blog can be git pushed into the server: git remote add <remote name\> ssh://<user name\>@<server name\>/home/<user name\>/hosting-server-installation/xhafanblog.git (example: git remote add blog ssh://username@192.168.0.185/home/username/hosting-server-installation/xhafanblog.git) 
* Push the blog into the server: git push <remote name\> (example: git push blog)
* 
* Back on the server, login as root (run su)
* Copy docker-compose.yml.production to docker-compose.yml
* On the server, start hosting the blog by starting jekyll and nginx: docker-compose up
* TODO: make sure docker/blog/nginx is loaded after server restart