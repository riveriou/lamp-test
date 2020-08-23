#!/bin/bash

ln -snf /usr/share/zoneinfo/Asia/Taipei /etc/localtime && echo Asia/Taipei > /etc/timezone

apt-get update --fix-missing
apt-get install -y curl net-tools wget vim dialog software-properties-common  nano less unzip


curl -o xampp-linux-installer.run "https://master.dl.sourceforge.net/project/xampp/XAMPP%20Linux/7.2.33/xampp-linux-x64-7.2.33-0-installer.run"
chmod +x xampp-linux-installer.run
bash -c './xampp-linux-installer.run'
ln -sf /opt/lampp/lampp /usr/bin/lampp

curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

#Download appropriate package for the OS version
#Choose only ONE of the following, corresponding to your OS version

#Ubuntu 20.04
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2019.list)"
apt-get update
ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-server
# optional: for bcp and sqlcmd
ACCEPT_EULA=Y apt-get install -y mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
# optional: for unixODBC development headers
apt-get install -y unixodbc-dev

pecl install sqlsrv
pecl install pdo_sqlsrv

printf "; priority=20\nextension=sqlsrv.so\n" > /opt/lampp/etc/php/7.2/mods-available/sqlsrv.ini
printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /opt/lampp/etc/php/7.2/mods-available/pdo_sqlsrv.ini

phpenmod sqlsrv pdo_sqlsrv
a2dismod mpm_event
a2enmod mpm_prefork
a2enmod php7.2


# Enable XAMPP web interface(remove security checks)
sed -i.bak s'/Require local/Require all granted/g' /opt/lampp/etc/extra/httpd-xampp.conf

# Enable includes of several configuration files
mkdir /opt/lampp/apache2/conf.d && \
    echo "IncludeOptional /opt/lampp/apache2/conf.d/*.conf" >> /opt/lampp/etc/httpd.conf

# Create a /www folder and a symbolic link to it in /opt/lampp/htdocs. It'll be accessible via http://localhost:[port]/www/
# This is convenient because it doesn't interfere with xampp, phpmyadmin or other tools in /opt/lampp/htdocs
mkdir /www
ln -s /www /opt/lampp/htdocs/

# SSH server
apt-get install -y -q supervisor openssh-server
mkdir -p /var/run/sshd

# Output supervisor config file to start openssh-server
echo "[program:openssh-server]" >> /etc/supervisor/conf.d/supervisord-openssh-server.conf
echo "command=/usr/sbin/sshd -D" >> /etc/supervisor/conf.d/supervisord-openssh-server.conf
echo "numprocs=1" >> /etc/supervisor/conf.d/supervisord-openssh-server.conf
echo "autostart=true" >> /etc/supervisor/conf.d/supervisord-openssh-server.conf
echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord-openssh-server.conf

# Allow root login via password
# root password is: root
sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# Set root password
# password hash generated using this command: openssl passwd -1 -salt xampp root
sed -ri 's/root\:\*/root\:\$1\$xampp\$5\/7SXMYAMmS68bAy94B5f\./g' /etc/shadow


apt-get clean
