#!/bin/bash

if [ -z "$1" ]; then
    echo "USAGE: $0 name_of_new_playbook"
    exit 1
else
    PLAYBOOK=$1
fi

if mkdir ./$PLAYBOOK; then
    pushd $PLAYBOOK > /dev/null
        if ! mkdir files templates tasks vars handlers; then
           echo "Creating playbook subdirectories failed"
           exit 1
        fi
        touch README 
    popd > /dev/null
else
   echo "mkdir ./$PLAYBOOK failed"
   exit 1
fi
