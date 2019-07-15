#!/bin/bash
################################################################################
# Script para instalacao PostgreSQL Debian 9
# Author: Sidnei Brianti
# wget https://raw.githubusercontent.com/scbrianti/InstallScript/12.0/install_psql.sh
# Place this content in it and then make the file executable:
# sudo chmod +x install_psql.sh
# Execute the script to install Odoo:
# ./install_psql.sh
################################################################################

OE_USER="odoo"

#PostgreSQL Version
OE_POSTGRESQL_VERSION="10"

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update
sudo apt-get upgrade -y

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server ----"
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update
sudo apt-get install postgresql-${OE_POSTGRESQL_VERSION} -y
