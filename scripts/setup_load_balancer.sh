#!/bin/bash
set -ex

# importamos el archivo .env
source .env

#Actualizamos repositorios
apt update

#Instalamos el servidor nginx
apt install nginx -y

#Deshabilitamos la página por defecto de nginx
if [ -f "/etc/nginx/sites-enabled/default" ]; then
    unlink /etc/nginx/sites-enabled/default
fi

# Copiamos la plantilla del archivo de configuración de nginx
cp ../conf/load-balancer.conf /etc/nginx/sites-available

#Buscamos y reemplazamos los valores de las ips de las variables
sed -i "s/IP_FRONTEND_1/$IP_FRONTEND_1/" /etc/nginx/sites-available/load-balancer.conf
sed -i "s/IP_FRONTEND_2/$IP_FRONTEND_2/" /etc/nginx/sites-available/load-balancer.conf

# Habilitamos el sitio de load balancer
ln -s -f /etc/nginx/sites-available/load-balancer.conf /etc/nginx/sites-enabled/

# Reiniciamos el servicio de nginx para aplicar los cambios
systemctl restart nginx