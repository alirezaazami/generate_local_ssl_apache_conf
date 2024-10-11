#!/bin/bash

# Check if a PHP version is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <php_version>"
  exit 1
fi

PHP_VERSION=$1
XDEBUG_CONF="/etc/php/$PHP_VERSION/mods-available/xdebug.ini"

# Check if the xdebug.ini file exists for the given PHP version
if [ ! -f "$XDEBUG_CONF" ]; then
  echo "Xdebug configuration not found for PHP version $PHP_VERSION."
  exit 1
fi

# Toggle Xdebug (comment or uncomment the zend_extension=xdebug.so line)
if grep -q "^zend_extension=xdebug.so" "$XDEBUG_CONF"; then
  echo "Disabling Xdebug for PHP $PHP_VERSION..."
  sudo sed -i 's/^zend_extension=xdebug.so/;zend_extension=xdebug.so/' "$XDEBUG_CONF"
  echo "Xdebug disabled."
elif grep -q "^;zend_extension=xdebug.so" "$XDEBUG_CONF"; then
  echo "Enabling Xdebug for PHP $PHP_VERSION..."
  sudo sed -i 's/^;zend_extension=xdebug.so/zend_extension=xdebug.so/' "$XDEBUG_CONF"
  echo "Xdebug enabled."
else
  echo "No zend_extension=xdebug.so found in $XDEBUG_CONF"
  exit 1
fi

# Restart PHP-FPM and Apache (or Nginx) if they are used
echo "Restarting PHP-FPM and web server (if applicable)..."
sudo systemctl restart php$PHP_VERSION-fpm
sudo systemctl restart apache2 2>/dev/null || sudo systemctl restart nginx 2>/dev/null

echo "Done."
