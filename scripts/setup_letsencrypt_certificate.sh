#!/bin/bash
set -ex
#importamos archivo .env
source .env
#Realizamos la instalación y actualización de snapd.
snap install core
snap refresh core
#COPIAMOS LA PLANTILLA DEL ARCHIVO DE CONFIGURACION DE APACHE
sed -i "s/server_name\ _/server_name\ $CERTBOT_DOMAIN/" /etc/nginx/sites-available/load-balancer.conf
#Eliminamos si existiese alguna instalación previa de certbot con apt.
apt remove certbot -y
#Instalamos el cliente de Certbot con snapd.
snap install --classic certbot
#Contestamos a las preguntas para la obtención del certificado SSL.
certbot --nginx -m $CERTBOT_EMAIL --agree-tos --no-eff-email -d $CERTBOT_DOMAIN --non-interactive