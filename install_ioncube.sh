#!/bin/bash

sudo systemctl stop apache2
# Download the ionCube loaders
rm -rf /tmp/ioncube_loaders_lin_x86-64.tar.gz
wget -P /tmp https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz

# Extract to /usr/lib/php
if [ -d "/usr/lib/php/ioncube" ]; then
    sudo rm -rf /usr/lib/php/ioncube
fi
sudo bash -c "mkdir -p /usr/lib/php/ioncube"
sudo bash -c "tar -xzvf /tmp/ioncube_loaders_lin_x86-64.tar.gz -C /usr/lib/php/"

# List all directories in /etc/php/ and store them
php_versions=$(ls /etc/php/)

# Loop through each PHP version and create the 00-ioncube.ini file in the specified directories if they exist
for version in $php_versions; do
    for type in apache2 cli fpm; do
        dir_path="/etc/php/${version}/${type}/conf.d/"
        ini_file="${dir_path}00-ioncube.ini"
        if [ -d "$dir_path" ]; then
            if [ -f "$ini_file" ]; then
                sudo bash -c "rm -f '$ini_file'"
                echo "Existing file $ini_file removed."
            fi
            # Adjust the filename pattern to match the PHP version
            sudo bash -c "echo 'zend_extension = /usr/lib/php/ioncube/ioncube_loader_lin_${version}.so' > '$ini_file'"
            echo "File created in: $ini_file"
            sudo systemctl restart "php${version}-fpm"
        fi
    done
done

echo "ionCube loader installation script completed."
sudo systemctl start apache2 
