#!/bin/bash
set -ex
#Importamos variables
source .env
#Actualizamos reposoitorios
apt update -y
#Instalamos el servicio de NFS-Server cliente
apt install nfs-common -y
#Montaje del cliente
sudo mount $NFS_IP:/var/www/html /var/www/html