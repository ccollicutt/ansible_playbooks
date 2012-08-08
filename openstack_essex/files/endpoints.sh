#!/bin/sh

# Author:       Martin Gerhard Loschwitz
# (c) 2012      hastexo Professional Services GmbH

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# On Debian-based systems the full text of the Apache version 2.0 
# license can be found in `/usr/share/common-licenses/Apache-2.0'.

# MySQL definitions
MYSQL_USER=keystone
MYSQL_DATABASE=keystone
MYSQL_HOST=localhost

# other definitions
MASTER=localhost

while getopts "u:D:p:m:K:R:E:S:T:vh" opt; do
  case $opt in
    u)
      MYSQL_USER=$OPTARG
      ;;
    D)
      MYSQL_DATABASE=$OPTARG
      ;;
    p)
      MYSQL_PASSWORD=$OPTARG
      ;;
    m)
      MYSQL_HOST=$OPTARG
      ;;
    K)
      MASTER=$OPTARG
      ;;
    R)
      KEYSTONE_REGION=$OPTARG
      ;;
    E)
      export SERVICE_ENDPOINT=$OPTARG
      ;;
    S)
      SWIFT_MASTER=$OPTARG
      ;;
    T)
      export SERVICE_TOKEN=$OPTARG
      ;;
    v)
      set -x
      ;;
    h)
      cat <<EOF
Usage: $0 [-m mysql_hostname] [-u mysql_username] [-D mysql_database] [-p mysql_password]
       [-K keystone_master ] [ -R keystone_region ] [ -E keystone_endpoint_url ] 
       [ -S swift_master ] [ -T keystone_token ]
          
Add -v for verbose mode, -h to display this message.
EOF
      exit 0
      ;;
    \?)
      echo "Unknown option -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument" >&2
      exit 1
      ;;
  esac
done  

if [ -z "$KEYSTONE_REGION" ]; then
  echo "Keystone region not set. Please set with -R option or set KEYSTONE_REGION variable." >&2
  missing_args="true"
fi

if [ -z "$SERVICE_TOKEN" ]; then
  echo "Keystone service token not set. Please set with -T option or set SERVICE_TOKEN variable." >&2
  missing_args="true"
fi

if [ -z "$SERVICE_ENDPOINT" ]; then
  echo "Keystone service endpoint not set. Please set with -E option or set SERVICE_ENDPOINT variable." >&2
  missing_args="true"
fi

if [ -z "$MYSQL_PASSWORD" ]; then
  echo "MySQL password not set. Please set with -p option or set MYSQL_PASSWORD variable." >&2
  missing_args="true"
fi

if [ -n "$missing_args" ]; then
  exit 1
fi
 
keystone service-create --name nova --type compute --description 'OpenStack Compute Service'
keystone service-create --name volume --type volume --description 'OpenStack Volume Service'
keystone service-create --name glance --type image --description 'OpenStack Image Service'
keystone service-create --name swift --type object-store --description 'OpenStack Storage Service'
keystone service-create --name keystone --type identity --description 'OpenStack Identity'
keystone service-create --name ec2 --type ec2 --description 'OpenStack EC2 service'

create_endpoint () {
  case $1 in
    compute)
    keystone endpoint-create --region $KEYSTONE_REGION --service_id $2 --publicurl 'http://'"$MASTER"':8774/v2/%(tenant_id)s' --adminurl 'http://'"$MASTER"':8774/v2/%(tenant_id)s' --internalurl 'http://'"$MASTER"':8774/v2/%(tenant_id)s'
    ;;
    volume)
    keystone endpoint-create --region $KEYSTONE_REGION --service_id $2 --publicurl 'http://'"$MASTER"':8776/v1/%(tenant_id)s' --adminurl 'http://'"$MASTER"':8776/v1/%(tenant_id)s' --internalurl 'http://'"$MASTER"':8776/v1/%(tenant_id)s'
    ;;
    image)
    keystone endpoint-create --region $KEYSTONE_REGION --service_id $2 --publicurl 'http://'"$MASTER"':9292/v1' --adminurl 'http://'"$MASTER"':9292/v1' --internalurl 'http://'"$MASTER"':9292/v1'
    ;;
    object-store)
    if [ $SWIFT_MASTER ]; then
      keystone endpoint-create --region $KEYSTONE_REGION --service_id $2 --publicurl 'http://'"$SWIFT_MASTER"':8080/v1/AUTH_%(tenant_id)s' --adminurl 'http://'"$SWIFT_MASTER"':8080/v1' --internalurl 'http://'"$SWIFT_MASTER"':8080/v1/AUTH_%(tenant_id)s'
    else
      keystone endpoint-create --region $KEYSTONE_REGION --service_id $2 --publicurl 'http://'"$MASTER"':8080/v1/AUTH_%(tenant_id)s' --adminurl 'http://'"$MASTER"':8080/v1' --internalurl 'http://'"$MASTER"':8080/v1/AUTH_%(tenant_id)s'
    fi
    ;;
    identity)
    keystone endpoint-create --region $KEYSTONE_REGION --service_id $2 --publicurl 'http://'"$MASTER"':5000/v2.0' --adminurl 'http://'"$MASTER"':35357/v2.0' --internalurl 'http://'"$MASTER"':5000/v2.0'
    ;;
    ec2)
    keystone endpoint-create --region $KEYSTONE_REGION --service_id $2 --publicurl 'http://'"$MASTER"':8773/services/Cloud' --adminurl 'http://'"$MASTER"':8773/services/Admin' --internalurl 'http://'"$MASTER"':8773/services/Cloud'
    ;;
  esac
}

for i in compute volume image object-store identity ec2; do
  id=`mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -ss -e "SELECT id FROM service WHERE type='"$i"';"` || exit 1
  create_endpoint $i $id
done