#!/bin/bash

if [ $# -ne 1 ]; then
    echo  "Usage: $0 --client-name"
    exit 1
fi

client_name=$1
password=1
echo $password
rm -r /tmp/keys
mkdir /tmp/keys
cd /etc/easy-rsa
echo $password | ./easyrsa build-client-full $client_name nopass
cp pki/issued/$client_name.crt pki/private/$client_name.key pki/ca.crt pki/ta.key pki/dh.pem /tmp/keys/
chmod -R a+r /tmp/keys

