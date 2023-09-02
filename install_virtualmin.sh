#!/bin/bash

# Prompt for hostname input
read -p "Enter the desired hostname: " server_hostname

# Prompt for password input (twice for confirmation)
while true; do
    read -s -p "Enter the new root password: " password
    echo
    read -s -p "Confirm the new root password: " password_confirm
    echo

    if [ "$password" = "$password_confirm" ]; then
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done

# Change the hostname
echo "$server_hostname" | sudo tee /etc/hostname
sudo hostnamectl set-hostname "$server_hostname"

# Install Virtualmin
wget https://software.virtualmin.com/gpl/scripts/virtualmin-install.sh
sudo sh virtualmin-install.sh -y

# Add PHP repository and install packages
apt-get -y install apt-transport-https lsb-release ca-certificates curl && curl -sSL -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/sury-debian-php-$(lsb_release -sc).list' && apt-get update

sudo apt-get update -y
sudo apt-get install php8.2-{cgi,cli,fpm,pdo,gd,mbstring,mysqlnd,opcache,curl,xml,zip} -y
sudo apt-get install php8.1-{cgi,cli,fpm,pdo,gd,mbstring,mysqlnd,opcache,curl,xml,zip} -y
sudo apt-get install php8.0-{cgi,cli,fpm,pdo,gd,mbstring,mysqlnd,opcache,curl,xml,zip} -y
sudo apt-get install php7.4-{cgi,cli,fpm,pdo,gd,mbstring,mysqlnd,opcache,curl,xml,zip} -y
sudo apt-get install php7.3-{cgi,cli,fpm,pdo,gd,mbstring,mysqlnd,opcache,curl,xml,zip} -y
sudo apt-get install php7.2-{cgi,cli,fpm,pdo,gd,mbstring,mysqlnd,opcache,curl,xml,zip} -y
sudo apt-get install php7.1-{cgi,cli,fpm,pdo,gd,mbstring,mysqlnd,opcache,curl,xml,zip} -y
sudo apt-get install php5.6-{cgi,cli,fpm,pdo,gd,mbstring,mysqlnd,opcache,curl,xml,zip} -y

# Change the root password
echo -e "$password\n$password" | sudo passwd root

# Fetch system IP address
server_ip=$(curl -s http://api.ipify.org)

# Display success message
echo -e "[SUCCESS] Installation Complete!\n[SUCCESS] If there were no errors above, Virtualmin should be ready"
echo -e "[SUCCESS] to configure at https://$server_hostname:10000 (or https://$server_ip:10000)."
echo -e "[SUCCESS] You may receive a security warning in your browser on your first visit."
