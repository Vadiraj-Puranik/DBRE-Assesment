#!/bin/bash

ip_address="$(cat external_ip.txt)"
primary_public_ip=$(echo "${ip_address}" | sed 's/["\\]//g')

# Connect to the server using private key and run commands
ssh -i privatekey vadiraj@${primary_public_ip} <<EOF

# Creat a pgbench schema and a table:
sudo -u postgres psql -c "CREATE SCHEMA pgbench;"
sudo -u postgres psql -c "CREATE TABLE ToogltrackAssesment (visitor_email text, vistor_id serial, date timestamp, message text);"
sudo -u postgres psql -c "INSERT INTO ToogltrackAssesment (visitor_email, date, message) VALUES ( 'test@gmail.com', current_date, 'Replication completed to standby server.');"

#Replication Configration Setup
#sudo -u postgres createuser -U postgres repuser -P -c 5 --replication
sudo -u postgres psql -c "SELECT * FROM pg_create_physical_replication_slot('rep_slot');"

# Edit postgresql.conf file
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/13/main/postgresql.conf
sudo sed -i "s/#wal_level = replica/wal_level = replica/" /etc/postgresql/13/main/postgresql.conf
sudo sed -i "s/#max_wal_senders = 10/max_wal_senders = 10/" /etc/postgresql/13/main/postgresql.conf
sudo sed -i "s/#wal_keep_segments = 32/wal_keep_segments = 32/" /etc/postgresql/13/main/postgresql.conf
sudo sed -i "s/#hot_standby = off/hot_standby = on/" /etc/postgresql/13/main/postgresql.conf

#External_IP of primary-postgres-server is passed as environment variable from local system obtained from Terraform Output block
sudo sed -i "s/#primary_conninfo = ''/primary_conninfo = 'user=repuser host=${External_ip} port=5432 sslmode=prefer sslcompression=1'/" /etc/postgresql/13/main/postgresql.conf
sudo sed -i "s/#primary_slot_name = ''/primary_slot_name = 'rep_slot'/" /etc/postgresql/13/main/postgresql.conf
sudo bash -c 'echo "host replication repuser ${External_ip}/32 md5" >> /etc/postgresql/13/main/pg_hba.conf'
sudo systemctl restart postgresql.service
EOF














