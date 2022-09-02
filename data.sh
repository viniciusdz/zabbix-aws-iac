#!/bin/bash

echo "Data script started!"

# Source base https://www.zabbix.com/documentation/current/en/manual/installation/install_from_packages/debian_ubuntu

##############################
# LOCAL VARS  UPDATE HERE
###############################


ZBX_REPO_URL= "https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release"
ZBX_PKG_NAME= "zabbix-release_6.2-1+ubuntu20.04_all.deb"
DB_USER="zabbix" # change for you db user
DB_PASS="zabbix" # change for you db pass
DB_NAME="zabbix" # change for you db name

##############################
# NOT UPDATE
###############################

AWS_INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`


sudo wget  ${ZBX_REPO_URL}/${ZBX_PKG_NAME}
sudo dpkg -i ${ZBX_PKG_NAME}

#UPDATE OS
sudo update-grub-legacy-ec2 -y
sudo apt-get dist-upgrade -qq --force-yes
sudo apt update
sudo apt full-upgrade -y

#INSTALL POSTGRESQL
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install postgresql

#INSTALL ZABBIX AND PACKAGES

sudo apt-get -y install zabbix-server-pgsql zabbix-frontend-php php7.4-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent


#CREATE ZABBIX USER AND DB

sudo -u postgres createuser ${DB_USER} PASSWORD ${DB_PASS}
sudo -u postgres createdb -O ${DB_USER} ${DB_NAME}

sudo zcat /usr/share/doc/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u ${DB_USER} psql ${DB_NAME}

sudo systemctl restart zabbix-server zabbix-agent apache2 postgresql
sudo systemctl enable zabbix-server zabbix-agent apache2  postgresql
