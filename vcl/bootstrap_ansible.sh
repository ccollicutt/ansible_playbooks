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

if ! rpm -qa | grep rpmforge-release > /dev/null; then
	rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
	NEW_REPO=yes
fi

if [ "$NEW_REPO" == "yes" ]; then
	yum clean all
	yum makecache
fi

if ! rpm -qa | grep ansible > /dev/null ; then
	# Should come from rpmforge
    yum localinstall -y --nogpg http://packages.serverascode.com/mrepo/custom-centos6-noarch/RPMS.all/ansible-0.5-1.el6.noarch.rpm 
fi

if [ ! -e ./ansible_hosts ]; then

cat << EOANSIBLE_HOSTS > ./ansible_hosts
[vcl]
127.0.0.1
EOANSIBLE_HOSTS

fi

# Not all that helpful unless actually running as root, ie. not sudo
export ANSIBLE_HOSTS=`pwd`/ansible_hosts

# Add a new ssh for vagrant and stuff into root's authorized_keys file
# so that ansible has something to ssh into
if [ ! -e /root/.ssh/authorized_keys ]; then
	mkdir /root/.ssh
	chmod 700 /root/.ssh
	/usr/bin/ssh-keygen -q -t dsa -C '' -N '' -f /home/vagrant/.ssh/id_dsa
	chown vagrant:vagrant /home/vagrant/.ssh/id_dsa*
	cat /home/vagrant/.ssh/id_dsa.pub >> /root/.ssh/authorized_keys
	chmod 600 /root/.ssh/authorized_keys
fi