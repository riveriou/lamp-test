#!/bin/bash

apt-get update --fix-missing
apt-get install -y curl net-tools


curl -o xampp-linux-installer.run "https://downloadsapachefriends.global.ssl.fastly.net/7.4.8/xampp-linux-x64-7.4.8-0-installer.run?from_af=true"
chmod +x xampp-linux-installer.run
bash -c './xampp-linux-installer.run'
ln -sf /opt/lampp/lampp /usr/bin/lampp



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

# Few handy utilities which are nice to have
apt-get -y install nano vim less unzip wget --no-install-recommends

apt-get clean
