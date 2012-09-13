#!/bin/bash

if [[ $UID -ne 0 ]]; then
    echo "$0 must be run as root"
    exit 1
fi

if [[ ! -z "$1" ]]; then
	USER=$1
else
	USER=vagrant
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

