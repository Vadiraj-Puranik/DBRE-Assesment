#!/bin/bash
  
# Step 1: Install curl and ca-certificates
sudo apt install -y curl ca-certificates

# Step 2: Define the filename for the GPG key for the PostgreSQL repository.
filename="/usr/share/keyrings/apt-postgresql-keyring.gpg"

# Step 3: Downloaded GPG Key converted to appropriate format
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor --output "$filename" -y


# Step 4:Download and save the keyring file/addoing user postgres to sudo permissions
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor --output /usr/share/keyrings/apt-postgresql-keyring.gpg
echo "postgres ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/postgres > /dev/null


# Step 5: Setup APT package repository configuration for the PostgreSQL repository
echo "deb [signed-by=/usr/share/keyrings/apt-postgresql-keyring.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list > /dev/null

# Step 6: Update apt
sudo apt update

# Step 7: Install PostgreSQL 13
sudo apt install -y postgresql-13

# Step 8: Restart PostgreSQL service
sudo systemctl restart postgresql

# Step 9: Stop PostgreSQL service to add required port
sudo systemctl stop postgresql

# Step 10: Modify the configuration file to change the port to 5432
sudo sed -i 's/port = 5433/port = 5432/g' /etc/postgresql/13/main/postgresql.conf

# Step 11: Restart PostgreSQL after changing the port
sudo systemctl restart postgresql

sudo apt-get install --reinstall postgresql-13
sudo systemctl restart postgresql

# Step 12: Create the database and pgbench schema with All Privileges
sudo -u postgres psql -c "CREATE DATABASE mydatabase;"
sudo -u postgres psql -d mydatabase -c "CREATE SCHEMA pgbench;"
sudo -u postgres psql -d mydatabase -c "GRANT ALL PRIVILEGES ON SCHEMA pgbench TO postgres;"





