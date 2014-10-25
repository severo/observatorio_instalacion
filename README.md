# README

Scripts de instalación de Drupal / sitio del observatorio del racismo

## Instalación de drush en Debian

Instalar [Composer](https://getcomposer.org/doc/00-intro.md#system-requirements) en el sistema global

```
cd ~
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

Instalar [drush 6](https://github.com/drush-ops/drush#installupdate---composer)

```
cd ~
composer global require drush/drush:6.*
```

Post-install:
* añadir el acceso al binario `drush` en `$PATH`

	```
	sed -i '1i export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc
	source $HOME/.bashrc
	```

* activar la compleción para el comando `drush`

	```
	curl -sS https://raw.githubusercontent.com/drush-ops/drush/master/drush.complete.sh | sudo tee /etc/bash_completion.d/drush.complete.sh > /dev/null
	```

## Uso de los UserDir en Apache2

Activar el módulo `userdir`

```
sudo a2enmod userdir
```

Modificar el archivo `sudo nano /etc/apache2/mods-enabled/userdir.conf`

```
        <Directory /home/*/public_html>
                AllowOverride All
                #AllowOverride AllFileInfo AuthConfig Limit Indexes
                Options All
                #Options AllMultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
```

Autorizar PHP, comentando las líneas siguientes en `sudo nano /etc/apache2/mods-enabled/php5.conf`

```
#<IfModule mod_userdir.c>
#    <Directory /home/*/public_html>
#        php_admin_value engine Off
#    </Directory>
#</IfModule>
```

Reiniciar Apache2

```
sudo service apache2 restart
```

## Instalación de un sitio drupal


```
./install.sh
```

Referencias:
* http://friendlydrupal.com/screencasts/install-drupal-7-site-drush
* http://www.drushcommands.com/.
