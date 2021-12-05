#!/bin/bash

set -ex

sudo ssh-keygen -A
sudo chmod 400 /etc/ssh/ssh_host_*

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
sudo make install
sudo cp sshd_config /usr/local/etc

sudo cp /etc/ssh/ssh_host_* /usr/local/etc/
sudo patch -s -d / -p0 < ../../patchlocalssh.patch

sudo patch -s -d / -p0 < ../../patchetcsshd.patch

sudo systemctl restart sshd

sudo `pwd`/sshd -f /usr/local/etc/sshd_config
