* Mount Apline Linux iso (https://alpinelinux.org/downloads, for virtual machines there is a virtual iso)
* Login as root
* Run setup-alpine
* Reboot
* Login as root with a password
* Add ssh by following https://wiki.alpinelinux.org/wiki/Setting\_up\_a\_ssh-server
* Add a new user: adduser <username\>
* Log off root from the main console  
* Login via SSH (putty app for windows) as the new user
* Login as root (run su)
* Add git: apk add git
* Download the installation script: git clone https://github.com/xhafan/hosting-server-installation.git
* Change the working directory to hosting-server-installation: cd hosting-server-installation
* Add execute permission to the installation script: chmod +x install_server.sh
* Execute the installation script: ./install_server.sh
