#!/bin/bash
set -ex
#Importamos variables
source .env
#Actualizamos reposoitorios
apt update -y
#Instalamos el servicio de NFS-Server cliente
apt install nfs-common -y
#Montaje del cliente
sudo mount $IP_NFS:/var/www/html /var/www/html
#Configuramos el archivo /etc/fstab
cp ../exports/fstab /etc/fstab
#Añadimos una nueva linea al /etc/fstab con el punto de montaje del NFS Server
echo "$IP_NFS:/var/www/html /var/www/html  nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0">> /etc/fstab