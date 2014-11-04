# README

Scripts de instalación de Drupal / sitio del observatorio del racismo

## Instalación de un sitio drupal

### Configurar el archivo de instalación

```
cp configuracion.ejemplo configuracion
nano configuracion
```

Descomentar y modificar los parámetros adecuados

```
#PAQUETES=php5-gd

#URL_HOST=localhost
#URL_SUBDIR=observatorio

#APACHE_USER=www-data

#TMP=/tmp
#CARPETA_INSTALACION=/var/www/observatorio
#DR_VERSION=drupal-7.32

#DR_DB_USER=observatorio
#DR_DB_PW=observatorio
#DR_DB_HOST=localhost
#DR_DB_PORT=3306
#DR_DB_NAME=observatorio

#DR_ACCOUNT_NAME=severo
#DR_ACCOUNT_PASS=severo
#DR_ACCOUNT_MAIL=severo@rednegra.net
#DR_LOCALE=es_BO
#DR_SITE_MAIL=severo@rednegra.net
#DR_SITE_NAME="Observatorio del racismo"

```

### Lanzar la instalación

```
./install.sh
```

### Referencias sobre drush

* http://friendlydrupal.com/screencasts/install-drupal-7-site-drush
* http://www.drushcommands.com/.
