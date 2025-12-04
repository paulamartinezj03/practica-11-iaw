#!/bin/bash
set -ex

# importamos el archivo .env
source .env

#Actualizamos los repositorios
apt update

#Actualizamos los paquetes del sistema
apt upgrade -y

#Instalación de mysql server
sudo apt install mysql-server -y

#Modificamos el parámetro bind address
sed -i "s/127.0.0.1/$MYSQL_SERVER_PRIVATE_IP/" /etc/mysql/mysql.conf.d/mysqld.cnf

#Reiniciamos el servicio de Mysql
systemctl restart mysql