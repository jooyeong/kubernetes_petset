#!/bin/bash
#to install xfsprogs on k8s nodes

sudo su -
sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

mkdir ~/bin
export PATH="$PATH:$HOME/bin"

curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
mkdir coreos; cd coreos

echo "-----------------------------------------"
hostname 
date 
apt-get update  > /dev/null 2>&1
apt-get install -y xfsprogs > /dev/null 2>&1

FILE1=/usr/sbin/xfs_check

if [ -f  $FILE1 ];
then
   echo "OK"
else
   echo "Not Installed"
fi
