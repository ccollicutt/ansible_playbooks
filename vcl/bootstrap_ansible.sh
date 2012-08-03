#!/bin/bash

NEW_REPO=no

if [[ $UID -ne 0 ]]; then
    echo "$0 must be run as root"
    exit 1
fi

if ! rpm -qa | grep epel-release > /dev/null; then
    rpm -ivh http://fedora.mirror.nexicom.net/epel/6/i386/epel-release-6-7.noarch.rpm
    NEW_REPO=yes
fi

if ! rpm -qa | grep rpmforge > /dev/null; then
	rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
	NEW_REPO=yes
fi

if [ "$NEW_REPO" == "yes" ]; then
	yum clean all
	yum makcecache
fi

if ! rpm -qa ansible > /dev/null ; then
    yum install -y ansible
fi

if [ ! -e ./ansible_hosts ]; then

cat << EOANSIBLE_HOSTS > ./ansible_hosts
[vcl]
127.0.0.1
EOANSIBLE_HOSTS

fi

export ANSIBLE_HOSTS=`pwd`/ansible_hosts

if [ ! -e /root/.ssh/authorized_keys ]; then
	mkdir /root/.ssh
	chmod 700 /root/.ssh
	/usr/bin/ssh-keygen -q -t dsa -C '' -N '' -f /home/vagrant/.ssh/id_dsa
	chown vagrant:vagrant /home/vagrant/.ssh/id_dsa*
	cat /home/vagrant/.ssh/id_dsa.pub >> /root/.ssh/authorized_keys
	chmod 600 /root/.ssh/authorized_keys
fi