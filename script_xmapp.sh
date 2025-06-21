#! /bin/bash

set -e
exec > >(tee -a install.log) 2>&1

[ "$EUID" -ne 0 ] && exec sudo "$0" "$@"
echo "Running as root!"

echo "Start Install XMAPP"

apt install -y apache2 php8.3 mysql-server

echo "PHP:"
php -v
echo ""

echo "APACHE:"
apache2 -v
systemctl status apache2 | grep "Active"
echo ""

echo "MYSQL:"
mysql --version
systemctl status mysql | grep "Active"
echo ""

echo "Cloning repository..."
git clone https://github.com/DevOps2-Fundamentals/Blood-Bank-Management-System

echo "Copying to /var/www/html/bloodbank..."
mv ./Blood-Bank-Management-System /var/www/html/bloodbank/

echo "Giving new permissions..."
chown -R www-data:www-data /var/www/html/bloodbank
chmod -R 755 /var/www/html/bloodbank

echo "Creating Database and moving old database..."
mysql -u root -e "DROP DATABASE IF EXISTS bloodbank; CREATE DATABASE bloodbank;"
mysql -u root bloodbank < /var/www/html/bloodbank/sql/bloodbank.sql

echo "Successful job! Go to http://localhost/bloodbank/main.php"