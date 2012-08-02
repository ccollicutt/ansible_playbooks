#!/bin/bash

if ! rpm -qa | grep epel-release; then
    rpm -ivh http://fedora.mirror.nexicom.net/epel/6/i386/epel-release-6-7.noarch.rpm
fi

if ! which ansible; then
    #yum install -y ansible
    yum localinstall --nogpg http://packages.serverascode.com/mrepo/custom-centos6-noarch/RPMS.all/ansible-0.5-1.el6.noarch.rpm
fi

cat << EOANSIBLE_HOSTS > ./ansible_hosts
[vcl]
127.0.0.1
EOANSIBLE_HOSTS

export ANSIBLE_HOSTS=`pwd`/ansible_hosts

mkdir /root/.ssh

chmod 700 /root/.ssh
/usr/bin/ssh-keygen -q -t dsa -C '' -N '' -f /home/vagrant/.ssh/id_dsa
chown vagrant:vagrant /home/vagrant/.ssh/id_dsa*
cat /home/vagrant/.ssh/id_dsa.pub >> /root/.ssh/authorized_keys

chmod 600 /root/.ssh/authorized_keys

ansible -m ping 127.0.0.1
