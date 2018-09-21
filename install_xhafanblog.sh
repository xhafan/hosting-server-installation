#!/bin/sh
set -x

# this script is a customized version of http://toroid.org/git-website-howto

# creare a directory for xhafanblog git working tree (without .git folder)
mkdir xhafanblog

# creare a directory for xhafanblog git bare repository (with .git folder)
mkdir xhafanblog.git && cd xhafanblog.git
git init --bare
cd ..

# create post receive hook to refresh xhafanblog working tree in xhafanblog folder
echo "#!/bin/sh" > xhafanblog.git/hooks/post-receive
echo "GIT_WORK_TREE=$(pwd)/xhafanblog git checkout -f" >> xhafanblog.git/hooks/post-receive
chmod +x xhafanblog.git/hooks/post-receive
