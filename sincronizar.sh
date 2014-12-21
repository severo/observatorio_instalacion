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
printf "Sincronización de los archivos (código y documentos) desde %s\n" ${SERVIDOR_REMOTO}
sudo rsync -e "ssh -i ${CLAVE_PRIVADA_LOCAL}" --log-file=${ARCHIVO_LOG} -a --delete-during --exclude config/connect.php --exclude tmp/ --exclude local/ ${USUARIO_REMOTO}@${SERVIDOR_REMOTO}:${CARPETA_INSTALACION_REMOTA} ${CARPETA_INSTALACION}

# Creación del archivo .htaccess
sed -i "s|RewriteBase ${URL_SUBDIR_REMOTO}|RewriteBase ${URL_SUBDIR}|" ${CARPETA_INSTALACION}/.htaccess

# 2. Recuperar la base de datos
printf "Sincronización de la base de datos desde %s\n" ${SERVIDOR_REMOTO}
echo "1/6 - Backup en el servidor"
ssh -i ${CLAVE_PRIVADA_LOCAL} ${USUARIO_REMOTO}@${SERVIDOR_REMOTO} "/usr/bin/mysqldump --skip-dump-date -u ${SPIP_DB_USER_REMOTO} -h ${SPIP_DB_HOST_REMOTO} -p${SPIP_DB_PW_REMOTO} $SPIP_DB_NAME_REMOTO > /tmp/${SPIP_DB_NAME_REMOTO}.sql"
echo "2/6 - Recuperación del dump"
#scp -i ${CLAVE_PRIVADA_LOCAL} ${USUARIO_REMOTO}@${SERVIDOR_REMOTO}:/tmp/${SPIP_DB_NAME_REMOTO}.sql ${DUMP_LOCAL}
sudo rsync -e "ssh -i ${CLAVE_PRIVADA_LOCAL}" --log-file=${ARCHIVO_LOG} -a --delete-during ${USUARIO_REMOTO}@${SERVIDOR_REMOTO}:/tmp/${SPIP_DB_NAME_REMOTO}.sql ${DUMP_LOCAL}

echo "3/6 - Supresión del dump en el servidor"
ssh -i ${CLAVE_PRIVADA_LOCAL} ${USUARIO_REMOTO}@${SERVIDOR_REMOTO} "rm /tmp/${SPIP_DB_NAME_REMOTO}.sql"
echo "4/6 - Supresión de la base de datos local"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "DROP DATABASE IF EXISTS ${SPIP_DB_NAME};"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "CREATE DATABASE ${SPIP_DB_NAME};"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "GRANT ALL PRIVILEGES ON ${SPIP_DB_NAME}.* TO '${SPIP_DB_USER}'@'${SPIP_DB_HOST}' IDENTIFIED BY '${SPIP_DB_PW}';"
echo "5/6 - Importación del dump en local"
sudo mysql --defaults-file=/etc/mysql/debian.cnf ${SPIP_DB_NAME} < ${DUMP_LOCAL}
echo "6/6 - Modificación de la URL del sitio en la base de datos"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "UPDATE spip_meta SET valeur='${URL}' WHERE nom='adresse_site'" ${SPIP_DB_NAME}

