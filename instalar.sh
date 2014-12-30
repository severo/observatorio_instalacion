#!/bin/bash

# Cargar la configuración
if [ -f ./configuracion.defecto.conf ] ; then
        . ./configuracion.defecto.conf
fi

if [ -f ./configuracion.conf ] ; then
        . ./configuracion.conf
fi

# Preparación de variables
URL=https://${URL_HOST}${URL_SUBDIR}
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
sudo rm -rf ${CARPETA_INSTALACION}
sudo mkdir -p ${CARPETA_INSTALACION}

# Derechos
sudo chgrp -R ${APACHE_GROUP} ${CARPETA_INSTALACION}
sudo chmod -R g+rsXw ${CARPETA_INSTALACION}

rsync -r ${SPIP_TMP_REPO}/ ${CARPETA_INSTALACION}

# Supresión de los CSS de squelettes-dist
svn rm ${CARPETA_INSTALACION}/squelettes-dist/css

# Creación del archivo .htaccess
mv ${CARPETA_INSTALACION}/htaccess.txt ${CARPETA_INSTALACION}/.htaccess
sed -i "s|RewriteBase /|RewriteBase ${URL_SUBDIR}|" ${CARPETA_INSTALACION}/.htaccess

# Preparación de la carpeta de librerías
mkdir -p ${CARPETA_INSTALACION}/lib/
sudo chgrp -R ${APACHE_GROUP} ${CARPETA_INSTALACION}/lib/
sudo chmod -R g+sXw ${CARPETA_INSTALACION}/lib/

# Instalación del plugin observatorio
mkdir -p ${CARPETA_INSTALACION}/plugins/auto
sudo chgrp -R ${APACHE_GROUP} ${CARPETA_INSTALACION}/plugins/auto
sudo chmod -R g+sXw ${CARPETA_INSTALACION}/plugins/auto

git clone ${SPIP_PLUGIN_OBSERVATORIO_REPO_GIT} ${CARPETA_INSTALACION}/plugins/${SPIP_PLUGIN_OBSERVATORIO_NOMBRE}
git clone ${SPIP_PLUGIN_OBSERVATORIO_ESQ_REPO_GIT} ${CARPETA_INSTALACION}/plugins/${SPIP_PLUGIN_OBSERVATORIO_ESQ_NOMBRE}

printf "Ingresar a %s para terminar la instalación\n" "${URL}/ecrire"
printf " * usuario de la base de datos: %s\n" "${SPIP_DB_USER}"
printf " * password de la base de datos: %s\n" "${SPIP_DB_PW}"
