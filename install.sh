#!/bin/bash

# Configuración
#PAQUETES=sqlite3

URL_HOST=localhost
URL_SUBDIR=observatorio

APACHE_USER=www-data

TMP=/tmp
RAIZ=/var/www
SITIO=observatorio
DR_VERSION=drupal-7.32

DR_DB_USER=observatorio
DR_DB_PW=observatorio
DR_DB_HOST=localhost
DR_DB_PORT=3306
DR_DB_NAME=observatorio
DR_DB_URL=mysql://${DR_DB_USER}:${DR_DB_PW}@${DR_DB_HOST}:${DR_DB_PORT}/${DR_DB_NAME}

MYSQL_USER=root
MYSQL_PW=abc

DR_ACCOUNT_NAME=severo
DR_ACCOUNT_PASS=severo
DR_ACCOUNT_MAIL=severo@rednegra.net
DR_LOCALE=es_BO
DR_SITE_MAIL=severo@rednegra.net
DR_SITE_NAME="Observatorio del racismo"
DR_SITES_SUBDIR=${URL_HOST}.${URL_SUBDIR}

URL=http://${URL_HOST}/${URL_SUBDIR}

# Pre-requisitos

#printf "Instalación de los paquetes: %s\n" "${PAQUETES}"
#sudo aptitude install ${PAQUETES}

sudo a2enmod rewrite
sudo service apache2 restart

# Vaciar la base de datos
printf "Creación de la base de datos '%s' y del usuario '%s'\n" "${DR_DB_NAME}" "${DR_DB_USER}"
mysql --user=${MYSQL_USER} --password=${MYSQL_PW} -e "DROP DATABASE IF EXISTS ${DR_DB_NAME};"
mysql --user=${MYSQL_USER} --password=${MYSQL_PW} -e "CREATE DATABASE ${DR_DB_NAME};"
mysql --user=${MYSQL_USER} --password=${MYSQL_PW} -e "GRANT ALL PRIVILEGES ON ${DR_DB_NAME}.* TO '${DR_DB_USER}'@'${DR_DB_HOST}' IDENTIFIED BY '${DR_DB_PW}';"

# Instalación
printf "Instalación de Drupal '%s' en la carpeta '%s'\n" "${DR_VERSION}" "${RAIZ}/${SITIO}"
cd ${TMP}
sudo rm -rf ${TMP}/${DR_VERSION}
drush dl ${DR_VERSION} --destination=${TMP}
cd ${TMP}/${DR_VERSION}
drush si standard \
  --db-url=${DR_DB_URL} \
  --account-name=${DR_ACCOUNT_NAME} \
  --account-pass=${DR_ACCOUNT_PASS} \
  --account-mail=${DR_ACCOUNT_MAIL} \
  --locale=${DR_LOCALE} \
  --site-mail=${DR_SITE_MAIL} \
  --site-name=${DR_SITE_NAME} \
  --sites-subdir=${DR_SITES_SUBDIR}

sudo rm -rf ${RAIZ}/${SITIO}
sudo mkdir ${RAIZ}/${SITIO}
sudo chown -R ${APACHE_USER} ${RAIZ}/${SITIO}
sudo -u ${APACHE_USER} rsync -r ${TMP}/${DR_VERSION}/ ${RAIZ}/${SITIO}
sudo rm -rf ${TMP}/${DR_VERSION}

printf "Sitio '%s' instalado en %s\n" "${DR_SITE_NAME}" "${URL}"
printf " * usuario: %s\n" "${DR_ACCOUNT_NAME}"
printf " * password: %s\n" "${DR_ACCOUNT_PASS}"

