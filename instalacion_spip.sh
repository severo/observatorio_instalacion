#!/bin/bash

# Configuración
PAQUETES=php5-gd

URL_HOST=localhost
URL_SUBDIR=www/observatorio

APACHE_USER=www-data
APACHE_GROUP=www-data

TMP=/tmp
CARPETA_INSTALACION=/home/slesage/www/observatorio
SPIP_VERSION=spip-3-stable

SPIP_DB_USER=observatorio
SPIP_DB_PW=observatorio
SPIP_DB_HOST=localhost
SPIP_DB_PORT=3306
SPIP_DB_NAME=observatorio

if [ -f ./configuracion ] ; then
        . ./configuracion
fi

URL=https://${URL_HOST}/${URL_SUBDIR}
SPIP_REPO_SVN=svn://trac.rezo.net/spip/branches/${SPIP_VERSION}
SPIP_TMP_REPO=${TMP}/${SPIP_VERSION}
SPIP_CARPETAS_APACHE="${CARPETA_INSTALACION}/config ${CARPETA_INSTALACION}/local ${CARPETA_INSTALACION}/tmp ${CARPETA_INSTALACION}/IMG"

# Pre-requisitos

printf "Instalación de los paquetes: %s\n" "${PAQUETES}"
sudo aptitude install ${PAQUETES}

sudo a2enmod rewrite
sudo service apache2 restart

# Vaciar la base de datos
printf "Creación de la base de datos '%s' y del usuario '%s'\n" "${SPIP_DB_NAME}" "${SPIP_DB_USER}"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "DROP DATABASE IF EXISTS ${SPIP_DB_NAME};"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "CREATE DATABASE ${SPIP_DB_NAME};"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "GRANT ALL PRIVILEGES ON ${SPIP_DB_NAME}.* TO '${SPIP_DB_USER}'@'${SPIP_DB_HOST}' IDENTIFIED BY '${SPIP_DB_PW}';"

# Descarga de SPIP
if [ ! -d ${SPIP_TMP_REPO} ]
then
	printf "Descarga de SPIP '%s' en la carpeta '%s'\n" "${SPIP_VERSION}" "${SPIP_TMP_REPO}"
	svn checkout ${SPIP_REPO_SVN} ${SPIP_TMP_REPO}
fi

# Instalación en la carpeta www
printf "Instalación de SPIP '%s' en la carpeta '%s'\n" "${SPIP_VERSION}" "${CARPETA_INSTALACION}"
rm -rf ${CARPETA_INSTALACION}
mkdir -p ${CARPETA_INSTALACION}
rsync -r ${SPIP_TMP_REPO}/ ${CARPETA_INSTALACION}

# Derechos
sudo chgrp -R ${APACHE_GROUP} ${SPIP_CARPETAS_APACHE}
sudo chmod -R g+sXw ${SPIP_CARPETAS_APACHE}

printf "Ingresar a %s para terminar la instalación\n" "${URL}/ecrire"
printf " * usuario de la base de datos: %s\n" "${SPIP_DB_USER}"
printf " * password de la base de datos: %s\n" "${SPIP_DB_PW}"
