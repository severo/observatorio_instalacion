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

# Actualización de SPIP
printf "Actualización de SPIP"
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

