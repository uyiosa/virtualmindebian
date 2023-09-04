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

# Prompt for email address input
read -p "Enter the email address for notifications: " email_address

# Change the hostname
echo "$server_hostname" | sudo tee /etc/hostname
sudo hostnamectl set-hostname "$server_hostname"

# Install Virtualmin
wget https://software.virtualmin.com/gpl/scripts/virtualmin-install.sh
sudo sh virtualmin-install.sh -y

# Add PHP repository and install packages
apt-get -y install apt-transport-https lsb-release ca-certificates curl
curl -sSL -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/sury-debian-php-$(lsb_release -sc).list
apt-get update

# Install PHP versions
sudo apt-get update -y
for version in 8.2 8.1 8.0 7.4 7.3 7.2 7.1 5.6; do
    sudo apt-get install php$version-{cgi,cli,fpm,pdo,gd,mbstring,mysqlnd,opcache,curl,xml,zip} -y
done

# Change the root password
echo -e "$password\n$password" | sudo passwd root

# Fetch system IP address
server_ip=$(curl -s http://api.ipify.org)

# Display success message
echo -e "[SUCCESS] Installation Complete!\n[SUCCESS] If there were no errors above, Virtualmin should be ready"
echo -e "[SUCCESS] to configure at https://$server_hostname:10000 (or https://$server_ip:10000)."
echo -e "[SUCCESS] You may receive a security warning in your browser on your first visit."

# Send completion email
echo "Installation was successful!" | mail -s "Installation Complete" -aFrom:system@$server_hostname $email_address
