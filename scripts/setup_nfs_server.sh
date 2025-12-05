#!/bin/bash
set -ex
#Importamos variables
source .env
#Actualizamos reposoitorios
apt update -y
#Instalamos el servicio de NFS-Server
apt install nfs-kernel-server -y
#Creamos repositorio compartido
mkdir -p /var/www/html
#Modificamos los permisos
sudo chown nobody:nogroup /var/www/html
#Copiamos nuestra plantilla del archivo exports
cp ../exports/exports /etc
#Actualizamos el valor del rango de la subred en la plantilla
sed -i "s#FRONTEND_NETWORK#$FRONTEND_NETWORK#" /etc/exports
#Reiniciamos servicio
sudo systemctl restart nfs-kernel-server