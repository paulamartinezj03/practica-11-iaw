# practica-11-iaw
practica 11
# Configuramos el deploy_backend.sh
## #!/bin/bash
set -ex

## importamos el archivo .env
source .env

## Creamos base de datos
mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root -e "Create database $DB_NAME"

## Creamos un usuario y contraseña para la base de datos
mysql -u root -e "DROP USER IF EXISTS $DB_USER@'$IP_CLIENTE_MYSQL'"
mysql -u root -e "CREATE USER $DB_USER@'$IP_CLIENTE_MYSQL' IDENTIFIED BY '$DB_PASSWORD'"
## asignamos permisos
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'$IP_CLIENTE_MYSQL'"
# Configuramos el deploy_frontend.sh
## #!/bin/bash
set -ex
## importamos archivo .env
source .env
## Borramos la instalacion previa de wp-cli si existe
rm -f /tmp/wp-cli.phar
##Descargamos wp-cli
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp
## Le asignamos permisos de ejecucion
chmod +x /tmp/wp-cli.phar
## Movemos el archivo a /usr/local/bin/wp
mv /tmp/wp-cli.phar /usr/local/bin/wp
## eliminamos instalacion previa de wordpress si existe
rm -rf /var/www/html/*
## Descargamos wordpress en español en el directorio /var/www/html como root
wp core download \
  --locale=es_ES \
  --path=/var/www/html \
  --allow-root
## Asignamos los privilegios al usuario
wp config create \
  --dbname=$DB_NAME \
  --dbuser=$DB_USER \
  --dbpass=$DB_PASSWORD \
  --dbhost=$DB_HOST \
  --path=/var/www/html \
  --allow-root
## Instalamos wordpress
wp core install \
  --url=$CERTBOT_DOMAIN \
  --title="$WORDPRESS_TITLE" \
  --admin_user=$WORDPRESS_ADMIN_USER \
  --admin_password=$WORDPRESS_ADMIN_PASSWORD \
  --admin_email=$CERTBOT_EMAIL \
  --path=/var/www/html \
  --allow-root  

## Configuramos los permalinks
wp rewrite structure '/%postname%/' \
  --path=/var/www/html \
  --allow-root

## Instalamos plugin de WPS Hide Login
wp plugin install wps-hide-login --activate \
 --path=/var/www/html \
  --allow-root
## Configuramos la url personalizada para el login
wp option update whl_page "$URL_HIDE_LOGIN" --path=/var/www/html --allow-root

## Instalamos un tema
wp theme install astra --activate \
  --path=/var/www/html \
  --allow-root

## Copiamos el archivo .htaccess personalizado
cp ../htaccess/.htaccess /var/www/html/

## Añadimos la variable $_SERVER['HTTPS'] = 'on';
sed -i "/DB_COLLATE/a \$_SERVER\['HTTPS'\] = 'on';" /var/www/html/wp-config.php

## Modificamos el propietario y el grupo de /var/www/html a www-data
chown -R www-data:www-data /var/www/html

# Configuramos el install_lamp_backend.sh
## #!/bin/bash
set -ex

## importamos el archivo .env
source .env

## Actualizamos los repositorios
apt update

## Actualizamos los paquetes del sistema
apt upgrade -y

## Instalación de mysql server
sudo apt install mysql-server -y

## Modificamos el parámetro bind address
sed -i "s/127.0.0.1/$MYSQL_SERVER_PRIVATE_IP/" /etc/mysql/mysql.conf.d/mysqld.cnf

## Reiniciamos el servicio de Mysql
systemctl restart mysql
# Configuramos el install_lamp_frontend.sh
## #!/bin/bash
set -ex
## Actualizamos los repositorios
apt update
## Actualizamos los paquetes del sistema
apt upgrade -y
## Instalación servidor apache
apt install apache2 -y
## Habilitaremos el módulo rewrite de Apache
a2enmod rewrite
## Copiamos el archivo de configuración de Apache
cp ../conf/000-default.conf /etc/apache2/sites-available
## Reiniciaremos apache2
systemctl restart apache2
## Instalamos PHP
sudo apt install php libapache2-mod-php php-mysql -y
## Copiamos archivo index.php a /var/www/html
cp ../php/index.php /var/www/html
## Cambiamos el propietario del directorio
chown -R www-data:www-data /var/www/html
## Reiniciaremos apache2
systemctl restart apache2
# Configuración setup_letsencrypt_certificate.sh