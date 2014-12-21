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

# Borrar la base de datos
printf "Supresión de la base de datos '%s' \n" "${SPIP_DB_NAME}"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "DROP DATABASE IF EXISTS ${SPIP_DB_NAME};"

# Instalación en la carpeta www
printf "Supresión de la carpeta '%s'\n" "${CARPETA_INSTALACION}"
sudo rm -rf ${CARPETA_INSTALACION}
