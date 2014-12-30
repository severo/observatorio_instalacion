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
SPIP_CARPETAS_APACHE="${CARPETA_INSTALACION}/config ${CARPETA_INSTALACION}/local ${CARPETA_INSTALACION}/tmp ${CARPETA_INSTALACION}/IMG"

# Pre-requisitos
printf "Instalación de los paquetes: %s\n" "${PAQUETES}"
sudo aptitude install ${PAQUETES}

sudo a2enmod rewrite
sudo service apache2 restart

# Nos aseguramos que las carpetas necesarias existen

# Derechos
sudo chgrp -R ${APACHE_GROUP} ${CARPETA_INSTALACION}
sudo chmod -R g+rsXw ${CARPETA_INSTALACION}

# Preparación de la carpeta de librerías
mkdir -p ${CARPETA_INSTALACION}/lib/
sudo chgrp -R ${APACHE_GROUP} ${CARPETA_INSTALACION}/lib/
sudo chmod -R g+sXw ${CARPETA_INSTALACION}/lib/

# Instalación del plugin observatorio
mkdir -p ${CARPETA_INSTALACION}/plugins/auto
sudo chgrp -R ${APACHE_GROUP} ${CARPETA_INSTALACION}/plugins/auto
sudo chmod -R g+sXw ${CARPETA_INSTALACION}/plugins/auto

# Actualización de SPIP
printf "Actualización de SPIP"
svn cleanup ${CARPETA_INSTALACION}
svn update ${CARPETA_INSTALACION}

# Actualización del plugin observatorio
printf "Actualización del plugin %s en %s\n" "${SPIP_PLUGIN_OBSERVATORIO_NOMBRE}" "${CARPETA_INSTALACION}/plugins/${SPIP_PLUGIN_OBSERVATORIO_NOMBRE}"
cd ${CARPETA_INSTALACION}/plugins/${SPIP_PLUGIN_OBSERVATORIO_NOMBRE}
git fetch -p
git merge origin master

printf "Actualización del plugin %s en %s\n" "${SPIP_PLUGIN_OBSERVATORIO_ESQ_NOMBRE}" "${CARPETA_INSTALACION}/plugins/${SPIP_PLUGIN_OBSERVATORIO_ESQ_NOMBRE}"
cd ${CARPETA_INSTALACION}/plugins/${SPIP_PLUGIN_OBSERVATORIO_ESQ_NOMBRE}
git fetch -p
git merge origin master

