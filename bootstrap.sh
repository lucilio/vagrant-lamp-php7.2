# Setup
PHP_VER="7.1";

# Update Packages
apt-get update
# Upgrade Packages
apt-get upgrade

# Basic Linux Stuff
apt-get install -y git

# Apache
apt-get install -y apache2

# Enable Apache Mods
a2enmod rewrite

#Add Onrej PPA Repo
apt-add-repository ppa:ondrej/php
apt-get update

# Install PHP
apt-get install -y php${PHP_VER}

# PHP Apache Mod
apt-get install -y libapache2-mod-php${PHP_VER}

# Restart Apache
service apache2 restart

# PHP Mods
apt-get install -y php${PHP_VER}-common
apt-get install -y php${PHP_VER}-zip
apt-get install -y php${PHP_VER}-mcrypt

# Set MySQL Pass
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

# Install MySQL
apt-get install -y mysql-server

# Source SQL Files
if [[ -d /vagrant/mysql ]]; then
	for dumpfile in /vagrant/mysql/*.sql; do
		mysql -u root -proot < $dumpfile
	done
fi

# PHP-MYSQL lib
apt-get install -y php${PHP_VER}-mysql

# Setup Apache
a2enmod rewrite

if [[ -d /vagrant/apache ]]; then
	for file in /vagrant/apache/*-vhost.conf; do
		cp -avf $file /etc/apache2/sites-available/$(basename ${file/-vhost/});
		[ -f /etc/apache2/sites-enabled/$(basename ${file/-vhost/}) ] && rm -rf /etc/apache2/sites-enabled/$(basename ${file/-vhost/}); 
		ln -sf /etc/apache2/sites-available/$(basename ${file/-vhost/}) /etc/apache2/sites-enabled/$(basename ${file/-vhost/});
	done
fi

# Restart Apache
sudo service apache2 restart

# Done
echo "*** READY TO GO ***\n\nreplace your /etc/hosts with the version included\n"