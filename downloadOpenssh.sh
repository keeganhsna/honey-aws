#!/bin/bash;

sudo ssh-keygen -A
cd /etc/ssh
sudo chmod 400 ssh_host_*

sudo yum install gcc gcc-c++ autoconf automake zlib-devel openssl-devel patch  make -y

cd ~
mkdir ssh-source
cd ssh-source
wget -c https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.0p1.tar.gz
tar -xvzf openssh-8.0p1.tar.gz
cd openssh-8.0p1/
sudo cp auth-passwd.c auth-passwd.c.orig
patch -s -p0 < patchfile.patch
./configure
make
sudo cp sshd_config /usr/local/etc
cd /usr/local/etc
sudo cp /etc/ssh_host_* .


