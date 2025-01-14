#!/bin/bash

# Variables
read -p "Enter folder name (default: wordpress): " FOLDER_NAME
FOLDER_NAME=${FOLDER_NAME:-wordpress}

read -p "Enter database name (default: wordpress): " DB_NAME
DB_NAME=${DB_NAME:-wordpress}

read -p "Enter database user (default: wordpressuser): " DB_USER
DB_USER=${DB_USER:-wordpressuser}

read -p "Enter database password (default: password): " DB_PASSWORD
DB_PASSWORD=${DB_PASSWORD:-password}

read -p "Enter domain name (default: example.com): " DOMAIN_NAME
DOMAIN_NAME=${DOMAIN_NAME:-example.com}

# Update and install necessary packages
sudo apt update
sudo apt install -y apache2 mysql-server php php-mysql libapache2-mod-php php-cli unzip wget certbot python3-certbot-apache

# Download and extract the latest WordPress
wget https://wordpress.org/latest.zip
unzip latest.zip
sudo mv wordpress /var/www/html/$FOLDER_NAME

# Set permissions
sudo chown -R www-data:www-data /var/www/html/$FOLDER_NAME
sudo chmod -R 755 /var/www/html/$FOLDER_NAME

# Create a MySQL database and user for WordPress
sudo mysql -e "CREATE DATABASE $DB_NAME;"
sudo mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Configure Apache virtual host
sudo bash -c "cat <<EOF > /etc/apache2/sites-available/$FOLDER_NAME.conf
<VirtualHost *:80>
    ServerAdmin admin@$DOMAIN_NAME
    DocumentRoot /var/www/html/$FOLDER_NAME
    ServerName $DOMAIN_NAME
    ServerAlias www.$DOMAIN_NAME

    <Directory /var/www/html/$FOLDER_NAME>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF"

# Enable the WordPress site and rewrite module
sudo a2ensite $FOLDER_NAME.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# Obtain SSL certificate and configure auto-renewal
sudo certbot --apache -d $DOMAIN_NAME -d www.$DOMAIN_NAME
