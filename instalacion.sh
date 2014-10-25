#!/bin/bash

# Configuración


#PAQUETES=sqlite3
URL_HOST=localhost
URL_SUBDIR=observatorio
URL=http://${URL_HOST}/${URL_SUBDIR}

APACHE_USER=www-data

TMP=/tmp
CARPETA_INSTALACION=/var/www/observatorio
DR_VERSION=drupal-7.32

DR_DB_USER=observatorio
DR_DB_PW=observatorio
DR_DB_HOST=localhost
DR_DB_PORT=3306
DR_DB_NAME=observatorio
DR_DB_URL=mysql://${DR_DB_USER}:${DR_DB_PW}@${DR_DB_HOST}:${DR_DB_PORT}/${DR_DB_NAME}

DR_ACCOUNT_NAME=severo
DR_ACCOUNT_PASS=severo
DR_ACCOUNT_MAIL=severo@rednegra.net
DR_LOCALE=es_BO
DR_SITE_MAIL=severo@rednegra.net
DR_SITE_NAME="Observatorio del racismo"
DR_SITES_SUBDIR=${URL_HOST}.${URL_SUBDIR//\//.}

if [ -f ./configuracion ] ; then
        . ./configuracion
fi

# Pre-requisitos

# Instalación de composer
if $(command -v composer >/dev/null 2>&1)
then
  printf "Composer ya esta instalado\n"
else
  printf "Instalación de composer\n"
  cd ~
  curl -sS https://getcomposer.org/installer | php
  sudo mv composer.phar /usr/local/bin/composer
  sed -i '1i export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc
  source $HOME/.bashrc
fi

# Instalación de drush
if $(command -v drush >/dev/null 2>&1)
then
  printf "Drush ya esta instalado\n"
else
  printf "Instalación de drush\n"
  cd ~
  composer global require drush/drush:6.*
  curl -sS https://raw.githubusercontent.com/drush-ops/drush/master/drush.complete.sh | sudo tee /etc/bash_completion.d/drush.complete.sh > /dev/null
fi

#printf "Instalación de los paquetes: %s\n" "${PAQUETES}"
#sudo aptitude install ${PAQUETES}

sudo a2enmod rewrite
sudo service apache2 restart

# Vaciar la base de datos
printf "Creación de la base de datos '%s' y del usuario '%s'\n" "${DR_DB_NAME}" "${DR_DB_USER}"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "DROP DATABASE IF EXISTS ${DR_DB_NAME};"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "CREATE DATABASE ${DR_DB_NAME};"
sudo mysql --defaults-file=/etc/mysql/debian.cnf -se "GRANT ALL PRIVILEGES ON ${DR_DB_NAME}.* TO '${DR_DB_USER}'@'${DR_DB_HOST}' IDENTIFIED BY '${DR_DB_PW}';"

# Instalación
printf "Instalación de Drupal '%s' en la carpeta '%s'\n" "${DR_VERSION}" "${CARPETA_INSTALACION}"
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

sudo rm -rf ${CARPETA_INSTALACION}
sudo mkdir ${CARPETA_INSTALACION}
sudo chown -R ${APACHE_USER} ${CARPETA_INSTALACION}
sudo -u ${APACHE_USER} rsync -r ${TMP}/${DR_VERSION}/ ${CARPETA_INSTALACION}
sudo rm -rf ${TMP}/${DR_VERSION}

printf "Sitio '%s' instalado en %s\n" "${DR_SITE_NAME}" "${URL}"
printf " * usuario: %s\n" "${DR_ACCOUNT_NAME}"
printf " * password: %s\n" "${DR_ACCOUNT_PASS}"

