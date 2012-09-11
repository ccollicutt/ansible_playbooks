#!/bin/bash

if [[ $UID -ne 0 ]]; then
    echo "$0 must be run as root"
    exit 1
fi

if ! which ansible > /dev/null ; then
	if [ ! -e /usr/local/src/ansible ]; then
		apt-get install git -y
		pushd /usr/local/src
			git clone git://github.com/ansible/ansible.git || exit 1
			pushd ansible
				# Only use release 7 for now...
				git checkout release-0.7
			popd
		popd
	fi
	pushd /usr/local/src/ansible
		apt-get install python-yaml python-paramiko python-jinja2 make -y
		make install
	popd
fi

#
# This vagrant part could all be removed given the playbooks running at the end now...
# 

if [ ! -e /home/vagrant/ansible_hosts ]; then

cat << EOANSIBLE_HOSTS > /home/vagrant/ansible_hosts
[openstack]
127.0.0.1
EOANSIBLE_HOSTS

fi

if ! grep ANSIBLE_HOSTS ~/.bashrc; then
	echo "export ANSIBLE_HOSTS=/home/vagrant/ansible_hosts" >> /home/vagrant/.bashrc
fi

# Add a new ssh for vagrant and stuff into root's authorized_keys file
# so that ansible has something to ssh into
if [ ! -e /root/.ssh/authorized_keys ]; then
	mkdir /root/.ssh
	chmod 700 /root/.ssh
	echo " /usr/bin/ssh-keygen -q -t dsa -C '' -N '' -f /home/vagrant/.ssh/id_dsa"
	/usr/bin/ssh-keygen -q -t dsa -C '' -N '' -f /home/vagrant/.ssh/id_dsa
	chown vagrant:vagrant /home/vagrant/.ssh/id_dsa*
	cat /home/vagrant/.ssh/id_dsa.pub >> /root/.ssh/authorized_keys
	chmod 600 /root/.ssh/authorized_keys
fi

HOSTNAME=`hostname`
export ANSIBLE_HOSTS=/home/vagrant/ansible_hosts

#
# End vagrant
#

#
# Depending on hostname make a controller or a compute node.
# 

if [ "$HOSTNAME" == "cc01" ]; then
	/usr/local/bin/ansible-playbook /vagrant/ansible_playbooks/openstack_essex/controller.yml --connection=local
elif [ "$HOSTNAME" == "node01" -o "$HOSTNAME" == "node02" ]; then
	/usr/local/bin/ansible-playbook /vagrant/ansible_playbooks/openstack_essex/compute.yml --connection=local
fi
