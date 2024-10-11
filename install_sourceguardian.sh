#!/bin/bash

sudo systemctl stop apache2
# Download the sourceguardian loaders
rm -rf /tmp/loaders.linux-x86_64.tar.gz
wget -P /tmp --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36" https://www.sourceguardian.com/loaders/download/loaders.linux-x86_64.tar.gz


# Extract to /usr/lib/php
if [ -d "/usr/lib/php/sourceguardian" ]; then
    sudo rm -rf /usr/lib/php/sourceguardian
fi
sudo bash -c "mkdir -p /usr/lib/php/sourceguardian"
sudo bash -c "tar -xzvf /tmp/loaders.linux-x86_64.tar.gz -C /usr/lib/php/sourceguardian"

# List all directories in /etc/php/ and store them
php_versions=$(ls /etc/php/)

# Loop through each PHP version and create the 00-sourceguardian.ini file in the specified directories if they exist
for version in $php_versions; do
    for type in apache2 cli fpm; do
        dir_path="/etc/php/${version}/${type}/conf.d/"
        ini_file="${dir_path}00-sourceguardian.ini"
        if [ -d "$dir_path" ]; then
            if [ -f "$ini_file" ]; then
                sudo bash -c "rm -f '$ini_file'"
                echo "Existing file $ini_file removed."
            fi
            # Adjust the filename pattern to match the PHP version
            sudo bash -c "echo 'extension = /usr/lib/php/sourceguardian/ixed.${version}.lin' > '$ini_file'"
            echo "File created in: $ini_file"
            sudo systemctl restart "php${version}-fpm"
        fi
    done
done

echo "sourceguardian loader installation script completed."
sudo systemctl start apache2 
