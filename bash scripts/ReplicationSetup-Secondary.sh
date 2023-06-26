#!/bin/bash

ip_address="$(cat standby_ip.txt)"
standby_public_ip=$(echo "${ip_address}" | sed 's/["\\]//g')

# Connect to the server using private key and run commands
ssh -i privatekey vadiraj@${standby_public_ip} <<EOF

#Stopping Postgres server before configration setup 
sudo systemctl restart postgresql.service
sudo rm -rf /var/lib/postgresql/13/main/*

#Getting backup of primary-postgres-server for db sync 
export PGPASSWORD='mypassword'
sudo -u postgres pg_basebackup -h External_ip -D /var/lib/postgresql/13/main -U repuser -v -P -R -X stream -c fast

#Signal file to know server should work in standby mode
sudo touch /var/lib/postgresql/13/main/standby.signal
sudo systemctl restart postgresql.service
EOF


















