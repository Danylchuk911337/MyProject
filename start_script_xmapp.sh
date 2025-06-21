#! /bin/bash

echo "Start Install XMAPP"

apt install -y apache2 php8.3 mysql-server  2>$1 logs.log

echo "PHP:"
echo `php -v`
echo ""

echo "APACHE:"
echo `apache2 -v`
echo `systemctl status apache2 | grep "Active"`
echo ""

echo "MYSQL:"
echo `mysql --version`
echo `systemctl status mysql | grep "Active"`
echo ""