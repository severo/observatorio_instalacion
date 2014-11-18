# README

Scripts de instalación de SPIP / sitio del observatorio del racismo

## Instalación del sitio

Primero preparar la configuración

```
cp configuracion.ejemplo configuracion
nano configuracion
```

y luego lanzar la instalación

```
./instalacion.sh
```

Luego de la instalación, seguir los siguientes pasos manuales:
* en ecrire/, terminar la instalación (bdd, usuario)
* en ecrire/?exec=depots, cargar el repositorio de la "zone"
* en ecrire/?exec=admin_plugin, activar el plugin "observatorio"
* en ecrire/?exec=configurer_identite, subir el logotipo del observatorio
