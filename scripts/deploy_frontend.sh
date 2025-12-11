#!/bin/bash
set -ex
#importamos archivo .env
source .env
#Borramos la instalacion previa de wp-cli si existe
rm -f /tmp/wp-cli.phar
#Descargamos wp-cli
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp
#Le asignamos permisos de ejecucion
chmod +x /tmp/wp-cli.phar
#Movemos el archivo a /usr/local/bin/wp
mv /tmp/wp-cli.phar /usr/local/bin/wp
#eliminamos instalacion previa de wordpress si existe
rm -rf /var/www/html/*
#Descargamos wordpress en español en el directorio /var/www/html como root
wp core download \
  --locale=es_ES \
  --path=/var/www/html \
  --allow-root
#Asignamos los privilegios al usuario
wp config create \
  --dbname=$DB_NAME \
  --dbuser=$DB_USER \
  --dbpass=$DB_PASSWORD \
  --dbhost=$DB_HOST \
  --path=/var/www/html \
  --allow-root
#Instalamos wordpress
wp core install \
  --url=$CERTBOTDOMAIN \
  --title="$WORDPRESSTITLE" \
  --admin_user=$WORDPRESSADMINUSER \
  --admin_password=$WORDPRESSADMINPASSWORD \
  --admin_email=$CERTBOTEMAIL \
  --path=/var/www/html \
  --allow-root  

#Configuramos los permalinks
wp rewrite structure '/%postname%/' \
  --path=/var/www/html \
  --allow-root

#Instalamos plugin de WPS Hide Login
wp plugin install wps-hide-login --activate \
 --path=/var/www/html \
  --allow-root
#Configuramos la url personalizada para el login
wp option update whl_page "$URL_HIDE_LOGIN" --path=/var/www/html --allow-root

#Instalamos un tema
wp theme install astra --activate \
  --path=/var/www/html \
  --allow-root

#Copiamos el archivo .htaccess personalizado
cp ../htaccess/.htaccess /var/www/html/

#Modificamos el propietario y el grupo de /var/www/html a www-data
chown -R www-data:www-data /var/www/html