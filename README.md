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

Luego de la actualización, seguir los siguientes pasos manuales:
* en ecrire/?exec=admin_plugin, se actualizan las versiones de plugins

## Sincronizar el sitio desde la producción

Eventualmente modificar la configuración

```
nano configuracion.conf
```

y luego lanzar la sincronización

```
./sincronizar.sh
```

# Producción y localhost

Para trabajar de manera limpia con el sitio local de desarrollo:

1. (solo la primera vez) lanzar la instalación
2. lanzar la sincronización con el sitio de producción
3. lanzar la actualización

Para un sitio de test, lo mismo.

Una vez testeado, solo lanzar la actualización en el sitio de producción.

## Supresión del sitio

Primero preparar la configuración

```
cp configuracion.defecto.conf configuracion.conf
nano configuracion.conf
```

y luego lanzar la desinstalación / supresión

```
./desinstalar.sh
```
