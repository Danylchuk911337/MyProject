#! /bin/bash

set -e
exec > >(tee -a install.log) 2>&1

[ "$EUID" -ne 0 ] && exec sudo "$0" "$@"
echo -e "\e[32mRunning as root!\e[0m"

echo -e "\e[32mStart Install XMAPP\e[0m"

apt update
apt install -y apache2 php8.3 git

echo -e "\e[32mPHP:\e[0m"
php -v
echo ""

echo -e "\e[32mAPACHE:\e[0m"
apache2 -v
systemctl status apache2 | grep "Active"
echo ""

echo -e "\e[32mCloning repository...\e[0m"
git clone https://github.com/DevOps2-Fundamentals/Blood-Bank-Management-System

echo -e "\e[32mCopying to /var/www/html/bloodbank...\e[0m"
mv ./Blood-Bank-Management-System /var/www/html/bloodbank/

echo -e "\e[32mGiving new permissions...\e[0m"
chown -R www-data:www-data /var/www/html/bloodbank
chmod -R 755 /var/www/html/bloodbank

echo -e "\e[32mSuccessful job! Connect to your database, or use a dedicated database connection.\e[0m"

read -p "You will use local database?(y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Installing MySQL and PHP extensions..."
    
    apt install -y mysql-server php8.3-mysql
    
    echo -e "\e[32mPHP module mysqli:\e[0m"
    php -m | grep mysqli
    echo ""

    echo -e "\e[32mMYSQL:\e[0m"
    mysql --version
    systemctl status mysql | grep "Active"
    echo ""
    
    echo -e "\e[32mCreating Database and setting old database...\e[0m"
    mysql -u root -e "DROP DATABASE IF EXISTS bloodbank; CREATE DATABASE bloodbank;"
    mysql -u root bloodbank < /var/www/html/bloodbank/sql/bloodbank.sql

    read -p "Please write username for database: " username
    read -p "Please write password for database: " password

    mysql -u root -e "DROP USER IF EXISTS '$username'@'localhost';"
    mysql -u root -e "CREATE USER '$username'@'localhost' IDENTIFIED BY '$password';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON bloodbank.* TO '$username'@'localhost';"
    mysql -u root -e "FLUSH PRIVILEGES;"
    cat <<EOF > /var/www/html/bloodbank/file/connection.php
<?php
\$servername = "localhost";
\$username = "$username";
\$password = "$password";
\$dbname = "bloodbank";
\$conn = new mysqli(\$servername, \$username, \$password, \$dbname);
if (!\$conn) {
    die('Could not Connect MySql:' . mysqli_error());
}
?>
EOF
    
    chown www-data:www-data /var/www/html/bloodbank/file/connection.php
    chmod 755 /var/www/html/bloodbank/file/connection.php
    echo -e "\n\e[32mLocal database configured successfully.\e[0m"
    echo -e "\e[32mGo to http://localhost/bloodbank/main.php\e[0m"
else
    echo -e "\e[32mCreate your dedicated database server with database name=bloodbank and import SQL from: /var/www/html/bloodbank/sql/bloodbank.sql\e[0m"
    echo -e "\e[32mEditing /var/www/html/bloodbank/file/connection.php and write \$servername = \"\e[31mserver\e[0m\"; \$username = \"\e[31musername\e[0m\"; \$password = \"\e[31mpassword\e[0m\"; \$dbname = \"bloodbank\";\e[0m"
fi