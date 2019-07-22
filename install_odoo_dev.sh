#!/bin/bash
################################################################################
# Script para instalacao Odoo Debian 9
# Author: Sidnei Brianti
# wget https://raw.githubusercontent.com/scbrianti/InstallScript/12.0/odoo_install.sh
# Place this content in it and then make the file executable:
# sudo chmod +x odoo_install.sh
# Execute the script to install Odoo:
# ./odoo_install
################################################################################

OE_USER="odoo"
OE_HOME="/$OE_USER"
OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
OE_EXTRA="$OE_HOME/extra"
OE_ADDONS_PATH="$OE_HOME_EXT/addons,$OE_HOME/custom/addons"

INSTALL_WKHTMLTOPDF="True"

# Odoo Port
OE_PORT="8069"
# Odoo Version
OE_VERSION="12.0"

OE_SUPERADMIN="admin"
OE_CONFIG="${OE_USER}-server"

#PostgreSQL Version
OE_POSTGRESQL_VERSION="10"

###  WKHTMLTOPDF download links
WKHTMLTOX_X64=https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb
WKHTMLTOX_X32=https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_i386.deb

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

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n--- Installing Python 3 + pip3 --"
sudo apt-get install python3 python3-pip -y

echo -e "\n---- Install tool packages ----"
sudo apt-get install wget git bzr python-pip gdebi-core -y

echo -e "\n---- Install python packages ----"
sudo apt-get install libxml2-dev libxslt1-dev zlib1g-dev -y
sudo apt-get install libsasl2-dev libldap2-dev libssl-dev -y
sudo apt-get install python-dateutil python-feedparser python-ldap python-libxslt1 python-lxml \
python-mako python-openid python-psycopg2 python-pychart python-pydot python-pyparsing python-reportlab \
python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt \
python-yaml python-zsi python-docutils python-psutil python-mock python-unittest2 python-jinja2 \
python-decorator python-requests python-passlib python-pil -y

echo -e "\n---- Install pip packages ----"
sudo pip3 install -r https://raw.githubusercontent.com/OCA/OCB/$OE_VERSION/requirements.txt 

echo -e "\n---- Install python libraries ----"
sudo apt-get install python3-suds

echo -e "\n--- Install other required packages"
sudo apt-get install node-clean-css -y
sudo apt-get install node-less -y
sudo apt-get install python-gevent -y

#--------------------------------------------------
# Install Wkhtmltopdf if needed
#--------------------------------------------------
if [ $INSTALL_WKHTMLTOPDF = "True" ]; then
  echo -e "\n---- Install wkhtml and place shortcuts on correct place for ODOO 12 ----"
  #pick up correct one from x64 & x32 versions:
  if [ "`getconf LONG_BIT`" == "64" ];then
      _url=$WKHTMLTOX_X64
  else
      _url=$WKHTMLTOX_X32
  fi
  sudo wget $_url
  sudo gdebi --n `basename $_url`
  sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
  sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin
else
  echo "Wkhtmltopdf isn't installed due to the choice of the user!"
fi

echo -e "\n---- Create ODOO system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER
#The user should also be added to the sudo'ers group.
sudo adduser $OE_USER sudo

echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo -e "\n==== Installing ODOO Server ===="
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/OCA/OCB $OE_HOME_EXT/


echo -e "\n---- Create custom module directory ----"
sudo su $OE_USER -c "mkdir $OE_HOME/custom"
sudo su $OE_USER -c "mkdir $OE_HOME/conf"
sudo su $OE_USER -c "mkdir $OE_HOME/custom/addons"

echo -e "\n---- Create Extra addons directory ----"
sudo su $OE_USER -c "mkdir $OE_EXTRA"

echo -e "\n==== Installing ODOO Extra Addons ===="
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/OCA/server-tools.git $OE_EXTRA/oca-server-tools/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/OCA/connector-telephony.git $OE_EXTRA/oca-connector-telephone/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/OCA/web.git $OE_EXTRA/oca-web/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/OCA/partner-contact.git $OE_EXTRA/oca-partner-contact/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/OCA/crm.git $OE_EXTRA/oca-crm/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/OCA/l10n-brazil.git $OE_EXTRA/oca-l10n-brazil/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/OCA/helpdesk.git $OE_EXTRA/oca-helpdesk/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/OCA/server-auth.git $OE_EXTRA/oca-server-auth/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/OCA/social.git $OE_EXTRA/oca-social/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/OCA/rest-framework.git $OE_EXTRA/oca-rest-framework/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/Openworx/backend_theme.git $OE_EXTRA/openwork-backend_theme/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/muk-it/muk_base.git $OE_EXTRA/muk-it-muk_base/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/muk-it/muk_web.git $OE_EXTRA/muk-it-muk_web/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/muk-it/muk_docs.git $OE_EXTRA/muk-it-muk_docs/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/muk-it/muk_dms.git $OE_EXTRA/muk-it-muk_dms/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/muk-it/muk_misc.git $OE_EXTRA/muk-it-muk_misc/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/muk-it/muk_quality.git $OE_EXTRA/muk-it-muk_quality/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/muk-it/muk_website.git $OE_EXTRA/muk-it-muk_website/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/xubiuit/odoo_web_login.git $OE_EXTRA/xubiuit-odoo_web_login/
sudo git clone --depth 1 --branch $OE_VERSION https://gitlab.com/tekcloud/web-interface.git $OE_EXTRA/tekcloud-web-interface/
sudo git clone --depth 1 --branch $OE_VERSION https://gitlab.com/tekcloud/addons.git $OE_EXTRA/tekcloud-addons/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/debbabu/Lead-History.git $OE_EXTRA/debbabu-Lead_History/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/mustafirus/odoo_addons.git $OE_EXTRA/mustafirus-odoo_addons/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/onesteinbv/addons-onestein.git $OE_EXTRA/onesteinbv-addons-onestein/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/CybroOdoo/CybroAddons.git $OE_EXTRA/cybroOdoo-cybroAddons/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/odoomates/odooapps.git $OE_EXTRA/odoomates-odooapps/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/Smile-SA/odoo_addons.git $OE_EXTRA/smile-sa-odoo_addons/
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/SythilTech/Odoo.git $OE_EXTRA/sythilech-odoo/
https://github.com/OCA/business-requirement.git
https://github.com/OCA/purchase-workflow.git
https://github.com/OCA/stock-logistics-warehouse.git
https://github.com/OCA/field-service.git
https://github.com/OCA/sale-workflow.git
https://github.com/OCA/stock-logistics-barcode.git
https://github.com/OCA/account-invoicing.git
https://github.com/OCA/project.git
https://github.com/OCA/pos.git
https://github.com/OCA/reporting-engine.git
https://github.com/OCA/account-financial-reporting.git
https://github.com/OCA/hr.git
https://github.com/OCA/product-attribute.git
https://github.com/OCA/product-variant.git
https://github.com/OCA/bank-payment.git
https://github.com/OCA/timesheet.git
https://github.com/OCA/search-engine.git
https://github.com/OCA/mis-builder.git
https://github.com/OCA/queue.git
https://github.com/OCA/knowledge.git
https://github.com/OCA/manufacture-reporting.git
https://github.com/OCA/data-protection.git
https://github.com/OCA/stock-logistics-workflow.git
https://github.com/OCA/account-analytic.git
https://github.com/OCA/manufacture.git
https://github.com/OCA/bank-statement-import.git
https://github.com/OCA/server-ux.git
https://github.com/OCA/stock-logistics-reporting.git
https://github.com/OCA/account-financial-tools.git
https://github.com/OCA/server-backend.git
https://github.com/OCA/vertical-hotel.git
https://github.com/OCA/account-invoice-reporting.git
https://github.com/OCA/account-payment.git
https://github.com/OCA/donation.git
https://github.com/OCA/multi-company.git
https://github.com/OCA/interface-github.git
https://github.com/OCA/website.git
https://github.com/OCA/maintenance.git
https://github.com/OCA/server-env.git
https://github.com/OCA/geospatial.git
https://github.com/OCA/commission.git
https://github.com/OCA/contract.git
https://github.com/OCA/delivery-carrier.git
https://github.com/OCA/credit-control.git
https://github.com/OCA/connector-interfaces.git
https://github.com/OCA/website-cms.git
https://github.com/OCA/vertical-association.git
https://github.com/OCA/event.git
https://github.com/OCA/sale-reporting.git
https://github.com/OCA/management-system.git
https://github.com/OCA/e-commerce.git
https://github.com/OCA/account-budgeting.git
https://github.com/OCA/stock-logistics-tracking.git
https://github.com/OCA/purchase-reporting.git
https://github.com/OCA/currency.git
https://github.com/OCA/account-closing.git
https://github.com/OCA/edi.git
https://github.com/OCA/rma.git
https://github.com/OCA/ddmrp.git
https://github.com/OCA/calendar.git
https://github.com/OCA/operating-unit.git
https://github.com/OCA/community-data-files.git
https://github.com/OCA/intrastat-extrastat.git
https://github.com/OCA/report-print-send.git
https://github.com/OCA/project-agile.git
https://github.com/OCA/margin-analysis.git




echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*


