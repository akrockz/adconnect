#! /bin/bash
# Usage: ./create_group.sh AWSFS_26512_READONLY ak
GROUPNAME=$1
USERNAME=$2
dseditgroup -u $USERNAME -p -n "/Active Directory/ABCW2KDOM/All Domains" -o create $GROUPNAME
