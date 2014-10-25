# README

Scripts de instalación de Drupal / sitio del observatorio del racismo

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

