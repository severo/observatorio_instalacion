# README

Scripts de instalación de SPIP / sitio del observatorio del racismo

## Instalación del sitio

Primero preparar la configuración

```
cp configuracion.defecto.conf configuracion.conf
nano configuracion.conf
```

y luego lanzar la instalación

```
./instalar.sh
```

Luego de la instalación, seguir los siguientes pasos manuales:
* en ecrire/, terminar la instalación (bdd, usuario)
* en ecrire/?exec=depots, cargar el repositorio de la "zone"
* en ecrire/?exec=admin_plugin, activar el plugin "observatorio"
* en ecrire/?exec=configurer_identite, subir el logotipo del observatorio

## Actualización del sitio

Eventualmente modificar la configuración

```
nano configuracion.conf
```

y luego lanzar la actualización

```
./actualizar.sh
```

Luego de la instalación, seguir los siguientes pasos manuales:
* en ecrire/, terminar la instalación (bdd, usuario)
* en ecrire/?exec=depots, cargar el repositorio de la "zone"
* en ecrire/?exec=admin_plugin, activar el plugin "observatorio"
* en ecrire/?exec=configurer_identite, subir el logotipo del observatorio
