#!/bin/bash

# Cargar la configuración
if [ -f ./configuracion.defecto.conf ] ; then
        . ./configuracion.defecto.conf
fi

if [ -f ./configuracion.conf ] ; then
        . ./configuracion.conf
fi

# Preparación de variables
ARCHIVO_LOG="${TMP}/sincronizar.log"
DUMP_LOCAL="${TMP}/${SPIP_DB_NAME_REMOTO}.log"
URL=https://${URL_HOST}${URL_SUBDIR}

# 1. Recuperar los archivos de código y los documentos
if [ "${SERVIDOR_REMOTO}" == "localhost" ]
then
  printf "Sincronización de los archivos (código y documentos) desde %s\n" ${CARPETA_INSTALACION_REMOTA}
  sudo rsync --log-file=${ARCHIVO_LOG} -a --delete-during --exclude config/connect.php --exclude tmp/ --exclude local/ ${CARPETA_INSTALACION_REMOTA}/ ${CARPETA_INSTALACION}/
else
  printf "Sincronización de los archivos (código y documentos) desde %s\n" ${SERVIDOR_REMOTO}
  sudo rsync -e "ssh -i ${CLAVE_PRIVADA_LOCAL}" --log-file=${ARCHIVO_LOG} -a --delete-during --exclude config/connect.php --exclude tmp/ --exclude local/ ${USUARIO_REMOTO}@${SERVIDOR_REMOTO}:${CARPETA_INSTALACION_REMOTA} ${CARPETA_INSTALACION}
fi

# Modificación del archivo .htaccess
sed -i "s|RewriteBase ${URL_SUBDIR_REMOTO}|RewriteBase ${URL_SUBDIR}|" ${CARPETA_INSTALACION}/.htaccess

# 2. Recuperar la base de datos
if [ "${SERVIDOR_REMOTO}" == "localhost" ]
then
  printf "Sincronización de la base de datos desde %s\n" ${SPIP_DB_NAME_REMOTO}
  printf "Backup de la base %s\n" ${SPIP_DB_NAME_REMOTO}
  /usr/bin/mysqldump --skip-dump-date -u ${SPIP_DB_USER_REMOTO} -h ${SPIP_DB_HOST_REMOTO} -p${SPIP_DB_PW_REMOTO} $SPIP_DB_NAME_REMOTO > ${DUMP_LOCAL}
else
  printf "Sincronización de la base de datos desde %s\n" ${SERVIDOR_REMOTO}
  printf "Backup en el servidor\n"
  ssh -i ${CLAVE_PRIVADA_LOCAL} ${USUARIO_REMOTO}@${SERVIDOR_REMOTO} "/usr/bin/mysqldump --skip-dump-date -u ${SPIP_DB_USER_REMOTO} -h ${SPIP_DB_HOST_REMOTO} -p${SPIP_DB_PW_REMOTO} $SPIP_DB_NAME_REMOTO > /tmp/${SPIP_DB_NAME_REMOTO}.sql"
  printf "Recuperación del dump\n"
  sudo rsync -e "ssh -i ${CLAVE_PRIVADA_LOCAL}" --log-file=${ARCHIVO_LOG} -a --delete-during ${USUARIO_REMOTO}@${SERVIDOR_REMOTO}:/tmp/${SPIP_DB_NAME_REMOTO}.sql ${DUMP_LOCAL}
  printf "Supresión del dump en el servidor\n"
  ssh -i ${CLAVE_PRIVADA_LOCAL} ${USUARIO_REMOTO}@${SERVIDOR_REMOTO} "rm /tmp/${SPIP_DB_NAME_REMOTO}.sql"
fi

printf "Supresión de la base de datos local\n"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "DROP DATABASE IF EXISTS ${SPIP_DB_NAME};"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "CREATE DATABASE ${SPIP_DB_NAME};"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "GRANT ALL PRIVILEGES ON ${SPIP_DB_NAME}.* TO '${SPIP_DB_USER}'@'${SPIP_DB_HOST}' IDENTIFIED BY '${SPIP_DB_PW}';"
printf "Importación del dump en local\n"
sudo mysql --defaults-file=/etc/mysql/debian.cnf ${SPIP_DB_NAME} < ${DUMP_LOCAL}
printf "Modificación de la URL del sitio en la base de datos\n"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "UPDATE spip_meta SET valeur='${URL}' WHERE nom='adresse_site'" ${SPIP_DB_NAME}

# 3. Limpiar los archivos temporales que pueden estar en desfaz con el código
sudo rm -rf ${CARPETA_INSTALACION}/tmp/* ${CARPETA_INSTALACION}/local/*
