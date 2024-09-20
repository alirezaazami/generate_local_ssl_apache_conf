#!/bin/bash

# Check if mkcert is installed
if ! command -v mkcert &> /dev/null; then
    echo "mkcert could not be found. Please install mkcert first."
	echo "sudo apt install mkcert libnss3-tools"
    exit 1
fi

pwd=$(dirname $(readlink -f $0)) # current path relative

html=/var/www/html
ssl_dir=/etc/pki/tls

openssl_config=''

sudo a2enmod rewrite
sudo a2enmod setenvif
sudo a2enmod ssl
sudo a2enmod fcgid
sudo a2enmod alias
sudo a2enmod actions
sudo a2enmod headers
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_fcgi
sudo service apache2 stop


cd ${html}

i=3
website=''
hosts="127.0.0.1     "
domain_args='localhost 127.0.0.1'

sudo /bin/bash ${pwd}/inc/create_apache_conf.sh ${html} localhost ${ssl_dir}
sudo /bin/bash ${pwd}/inc/create_apache_conf.sh ${html} 127.0.0.1 ${ssl_dir}

for j in /etc/apache2/sites-enabled/*.conf; do
	sudo rm -f $j;
done

sudo /bin/bash ${pwd}/inc/create_apache_conf.sh ${html} localhost ${ssl_dir}
for d in */ ; do
if [[ $d == *"."* ]] && [[ $d != "-"* ]]; then

	domain="${d%/}" # Remove trailing slash
	domain_args="${domain_args} ${domain}"

	website=$(echo  ${d} | sed 's/.$//')


	#regenerate httpd host config
	sudo /bin/bash ${pwd}/inc/create_apache_conf.sh ${html} ${website} ${ssl_dir}


	#create hosts string in loop
	hosts="${hosts} ${website}"


	#create open ssl config loop
	openssl_config="${openssl_config}
	DNS.${i} = ${website}"


	i=$(($i+1))

fi
done

sudo rm -f "/etc/apache2/sites-enabled/.conf"


#regenerate new openssl certificate
sudo /bin/bash ${pwd}/inc/mkcrt.sh "${domain_args}" "${html}" "${ssl_dir}"
# sudo /bin/bash ${pwd}/inc/create_certificate.sh "${openssl_config}" "${html}" "${ssl_dir}"
#end


#replace host file content
sudo /bin/bash ${pwd}/inc/create_new_hosts.sh "${hosts}"
#end

sudo systemctl restart apache2 php8.1-fpm

