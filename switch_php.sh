#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <php_version>"
    echo "Example: $0 php7.4"
    exit 1
fi

php=${1}
[ ! -f "/usr/bin/${php}" ] && echo "installing ${php}"

if [ ! -f "/usr/bin/${php}" ]; then
    sudo apt install ${php} ${php}-xml ${php}-mysql ${php}-fpm ${php}-zip ${php}-soap ${php}-mongodb ${php}-mbstring ${php}-intl ${php}-gd ${php}-curl ${php}-bz2 ${php}-xdebug ${php}-gmp libapache2-mod-${php}
fi

sudo a2enmod proxy_fcgi setenvif actions fcgid alias
sudo update-alternatives --set php /usr/bin/$php
sudo a2enmod  ${php}
sudo a2enconf ${php}-fpm
sudo service restart apache2 ${php}-fpm
echo 'done'
exit 1
