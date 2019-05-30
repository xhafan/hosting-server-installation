1. Mount Apline Linux [iso](https://alpinelinux.org/downloads) (for virtual machines there is a smaller virtual iso)
2.  Login as root
3. Run setup-alpine (install the system into a [disk](https://wiki.alpinelinux.org/wiki/Install_to_disk))
4. Reboot
5. Login as root with a password
6. Update OS to the latest version - [tutorial](https://wiki.alpinelinux.org/wiki/Upgrading_Alpine#Upgrading_to_latest_release)
7. After reboot check the latest version: cat /etc/alpine-release
* 
8. Login as root with a password
9. Add ssh by following [this](https://wiki.alpinelinux.org/wiki/Setting_up_a_ssh-server) tutorial
10. Add a new user: adduser <username\>
11. Log off root from the main console  
12. Login via SSH (putty app for windows) as the new user    
* 
13. Login as root by running command "run su"
14. Add git: apk add git
15. Logoff as root (run exit)
* 
16. Download the installation script: git clone https://github.com/xhafan/hosting-server-installation.git
17. Change the working directory to hosting-server-installation: cd hosting-server-installation
* 
18. Login as root by running command "run su"
19. Execute the server installation script: ./install_server.sh
20. Logoff as root (run exit)
* 
21. Execute the blog installation script: ./install_xhafanblog.sh
* 
22. Locally, on your working machine, clone xhafan's blog: git clone https://github.com/xhafan/blog.git
23. Go to the root of the cloned blog repository on your working machine, and add the server as a remote so the blog can be git pushed into the server: git remote add <remote name\> ssh://<user name\>@<server name\>/home/<user name\>/hosting-server-installation/xhafanblog.git (example: git remote add blog ssh://username@192.168.0.185/home/username/hosting-server-installation/xhafanblog.git) 
24. Push the blog into the server: git push <remote name\> (example: git push blog)
* 
25. Back on the server, login as root (run su)
26. Copy docker-compose.yml.production (production server) or docker-compose.yml.dev (dev server) to docker-compose.yml
27. Edit docker-compose.yml and replace values of following environment variables: 
 * DOMAIN\_NAME (4x)
 * POSTGRES\_PASSWORD
 * RABBITMQ\_DEFAULT\_USER
 * RABBITMQ\_DEFAULT\_PASS
 * Rebus\_\_RabbitMQ\_\_ConnectionString (2x)
 * MAILNAME
28. On the server, start the containers: docker-compose up -d
29. Emailmaker app needs to create a database and a database login first. Check the IP address of postgres container: docker exec -it postgres /bin/sh
30. Ping postgres: ping postgres
31. Create SSH tunnel: 5433 -> <postgres container IP address\>:5432
32. Connect to localhost:5433 in pgAdmin , create EmailMaker DB, and emailmaker DB login with a password (these should match the DB connection string in hibernate.cfg.xml).
33. Test emailmaker app (https://<server\>/emailmaker). Once login page is displayed, go to directory hosting-server-installation/postgres-data , edit postgresql.conf , and set _max\_prepared\_transactions = 100_ to enable posgresql DB to work with .NET TransactionScope. Restart postgres: docker-compose restart postgres.

