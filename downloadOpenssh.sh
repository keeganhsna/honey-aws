#!/bin/bash

set -ex

sudo ssh-keygen -A
cd /etc/ssh
sudo chmod 400 ssh_host_*

sudo yum install gcc gcc-c++ autoconf automake zlib-devel openssl-devel patch  make -y


mkdir ssh-source
cd ssh-source
wget -c https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.0p1.tar.gz
tar -xvzf openssh-8.0p1.tar.gz
cd openssh-8.0p1/
sudo cp auth-passwd.c auth-passwd.c.orig
sudo patch -s -p0 < ../../patch.patch
./configure
make
sudo cp sshd_config /usr/local/etc

cd /usr/local/etc
sudo cp /etc/ssh/ssh_host_* .
sudo patch -s -p0 < /home/ec2-user/honey-aws/patchlocalssh.patch

cd /etc/ssh
sudo patch -s -p0 < /home/ec2-user/honey-aws/patchetcsshd.patch

sudo systemctl restart sshd
