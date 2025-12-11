#!/bin/bash
set -ex

# importamos el archivo .env
source .env

#Creamos base de datos
mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root -e "Create database $DB_NAME"

#Creamos un usuario y contraseña para la base de datos
mysql -u root -e "DROP USER IF EXISTS $DB_USER@'$IP_CLIENTE_MYSQL'"
mysql -u root -e "CREATE USER $DB_USER@'$IP_CLIENTE_MYSQL' IDENTIFIED BY '$DB_PASSWORD'"
#asignamos permisos
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'$IP_CLIENTE_MYSQL'"