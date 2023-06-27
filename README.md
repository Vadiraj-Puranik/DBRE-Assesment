# DBRE-Assesment

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Description
The Repository focuses on using **Terraform** for provisioning **VPC Network**,**Firewalls**, **Primary&Standby Databases**, **GCP Cloud Storage Bucket**, **Monitoring CPU and Disk Utilization Policies** on Google Cloud Platform (GCP). The project aims to demonstrate how to automate the creation and management of Primary Postgres instance and Standby Postgres Instance using Terraform's declarative configuration language.

## Table of Contents
- [Implementation](#implementation)
- [Files](#files)
- [Testing](#testing)

# Implementation

▪ The infrastructure has been provisioned using Terraform, and has a Debian Primary server running PostgreSQL 13. 
Terraform has been initialized with the necessary configurations, ensuring a smooth deployment. Primary-Postgres-server is initialized with pgbench schema.<br>
How does the server has Postgres installed ? <br>
▪ I have written a startup script (**primary_startup.sh**) which installs postgresql-13 and opens port 5432 for accepting connections. <br>

▪ Once the instance is up the public(external-ip) of the instance is stored in **external_ip.txt** file.<br>

▪ Alongside the primary server, we also have provisioned a secondary server(**standby-postgres-instance**) running PostgreSQL 13 using Terraform. Replication has been established between the primary and secondary databases, guaranteeing data consistency and availability.I have written a startup script (**standby_startup.sh**) which installs postgresql-13 and opens port 5432 for accepting connections.While it is possible to use the same primary_startup.sh script for the standby PostgreSQL instance, I have developed a new script specifically for the standby instance, taking into consideration any future modifications that may be required exclusively for the standby environment<br>

▪ As soon as the servers are provisioned using terraform we are making use of bash scripts to setup replication between primary and standby postgres servers<br>

### **ReplicationSetup-Primary.sh** <br>
▪ Uses helper file external_ip.txt which consist of the public ip of the primary server to establish SSH Connection using Private and Public Keys located on Local System.<br>

▪ ReplicationSetup-Primary.sh creates a **pgbench** schema, a table called **ToogltrackAssesment** and inserts value in **ToogltrackAssesment**. It further creates a user called **repuser** used for replication and a replication slot (repslot).<br>

▪ `listen_addresses` - Allowing to listen on all network addresses available on the server of the network addresses on the server, so that the standby server could access it.<br>

▪ `wal_level` - By setting the wal_level parameter to replica, the script ensures that the level of data written to the Write-Ahead Log (WAL) is sufficient to support the replication process<br>

▪ `max_wal_senders` - To facilitate the streaming of Write-Ahead Log (WAL) data to the standby server, the script ensures the availability of the required number of wal_sender processes<br>

▪ `hot_standby` - Enabling the hot_standby configuration option grants the ability to execute read-only operations on the standby server, 

▪ `primary_conninfo` = 'user=repluser host=[primary_server_ip] port=5432 sslmode=prefer sslcompression=1' <br>
To allow replication connections, the script appends the following configuration to the end of the pg_hba.conf file<br>

▪ `host	replication		repuser	[standby-postgres-server-ip]/32		md5`<br>
The above line allows the standby server to establish access using the user repluser from a specified IP address, utilizing password authentication for secure connectivity.<br>

`postgresql.service` is restarted after updating configuration file.

### **ReplicationSetup-Secondary.sh** <br>
▪  Uses helper file standby_ip.txt which consist of the public ip of the standby-postres-server to establish SSH Connection using Private and Public Keys located on Local System.<br>

▪  Prior to implementing any modifications of configuration the script stops PostgreSQL service and removes earlier configurations from postgres data directory `/var/lib/postgresql/13/main/*`<br>

▪ We export `PGPASSWORD='mypassword'` and run base backup which achieve the initial synchronization of the databases, the script retrieves a base backup from the primary server and proceeds to restore it on the standby server. This process ensures that the standby server starts with an up-to-date copy of the database, establishing the initial synchronization and enabling seamless replication moving forward.<br>

▪ To inform the current PostgreSQL instance that it should operate in standby mode, the script creates a `standby.signal` file. This file serves as a notification mechanism, triggering the standby functionality within the PostgreSQL instance, ensuring that it operates in accordance with the desired standby configuration.

▪ `postgresql.service` is restarted after updating configuration file.


# Files
In this section, I will provide an overview of the file locations and their respective functionalities:<br>

**terraform.tf** : The terraform.tf file specifies the cloud provider or service provider details and configuration. It defines which provider plugin to use, along with the required authentication credentials, region, and other provider-specific settings.<br>

**main.tf** : The main.tf file is the primary Terraform configuration file for our infrastructure. It typically contains the main components of our infrastructure, such as resource definitions.
terraform.tf

**variables.tf** : variables.tf file is used to declare input variables for your Terraform configuration. Input variables allow you to parameterize your infrastructure and make it more flexible.

**terraform.tfvars** : terraform.tfvars file is used to store input variable values for our Terraform configuration. It allows us to provide values for the variables defined in our Terraform files without explicitly passing them through the CLI or using environment variables.

**primary_startup.sh**: Located in the bash scripts directory, this script is responsible for initializing and configuring the primary server running PostgreSQL 13<br>

**standby_startup.sh**: Also located in the bash scripts directory, this script is specifically designed for the standby server. It includes similar functionalities to primary_startup.sh It takes into account any future modifications required exclusively for the standby environment.**

**external_ip.txt**: The provided helper file plays a vital role in facilitating SSH access to the primary server by populating it with the external IP address. This information is essential for running the ReplicationSetup-Primary.sh script, which sets up the necessary configurations for the replication process.<br>

**standby_ip.txt** : This file plays a vital role in facilitating SSH access to the secondary server by populating it with the external IP address. This information is essential for running the ReplicationSetup-Secondary.sh script, which sets up the necessary configurations for the replication process.<br>

**Configurations.md** : This file provides detailed information on the configuration of the cloud resources used and the rationale behind their selection.<br>


# Testing

## Postgres VPC Network<br>

![image](https://github.com/Vadiraj-Puranik/DBRE-Assesment/assets/113619300/2f68b55b-1dc2-4ca3-a978-f96899397c1b)

## The following represents the successful launch of both the primary and standby PostgreSQL servers.<br>

![image](https://github.com/Vadiraj-Puranik/DBRE-Assesment/assets/113619300/c74b34f8-ebdd-472c-96ba-555232d7ad8f)

## Firewall Created:<br>

![image](https://github.com/Vadiraj-Puranik/DBRE-Assesment/assets/113619300/ec401a1f-8335-4ced-ba48-4525a881b49b)


## Cloud Storage Bucket<br>

![image](https://github.com/Vadiraj-Puranik/DBRE-Assesment/assets/113619300/04eab858-34bf-41a8-a143-1ef5e7a36f50)

## Cloud Monitoring Alert Polices<br>

![image](https://github.com/Vadiraj-Puranik/DBRE-Assesment/assets/113619300/23e79fdc-f0da-4a1e-ae65-8e213be3949d)

## Replication working Successfully <br>

Primary Postgres Replication<br>

![primary-postgres-replication](https://github.com/Vadiraj-Puranik/DBRE-Assesment/assets/113619300/c3cad6bb-522c-40a3-a8ef-cf5746cce55f)

Secondary Postgres Replication <br>

![secondary-postgres-replication](https://github.com/Vadiraj-Puranik/DBRE-Assesment/assets/113619300/cc3d57b3-8656-4051-9f60-f192a0ac9868)



## Alerts received for the CPU policy created  <br>
Induced stress on primary-postgres-instance to make it reach 95% threshold

![image](https://github.com/Vadiraj-Puranik/DBRE-Assesment/assets/113619300/bfb681ae-5b71-4adb-b115-42bb2c840f68)

Alert notification received via alert channel <br>
![image](https://github.com/Vadiraj-Puranik/DBRE-Assesment/assets/113619300/3b01e869-a9bb-4b0e-8ae7-9f34010fc067)













# Contact
Feel free to reach out to me on below handles<br>

Email: shreyaspuranik008@gmail.com <br>
LinkedIn: [Vadiraj-Puranik](https://www.linkedin.com/in/vadiraj-puranik-4518a4165) <br>
Medium : [How to crack terraform certification on your first attempt](https://medium.com/@vadiraj.puranik/secrets-unveiled-how-to-ace-the-terraform-certification-exam-on-your-first-attempt-cb7622c45da1)





