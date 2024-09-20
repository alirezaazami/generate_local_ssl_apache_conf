#!/bin/bash



html=$2
ssl_dir=$3

# Create a single certificate for all domains
sudo mkcert -cert-file "${ssl_dir}/certs/localhost.pem" -key-file "${ssl_dir}/private/localhost.pem" $1
echo "Certificate and key have been created:"
echo "Certificate: ${ssl_dir}/certs/localhost.pem"
echo "Key: ${ssl_dir}/private/localhost.pem"
sudo chmod 644 ${ssl_dir}/private/localhost.pem
sudo chmod 644 ${ssl_dir}/certs/localhost.pem

mkcert -install
