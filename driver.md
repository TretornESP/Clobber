# Driver para comandos
## Dockerfile y los privilegios

Hasta ahora el esquema de almacenamiento se basaba en lo siguiente:

- Añadimos el dispositivo por iSCSI a la maquina host
- Pasamos el disco a la maquina docker con `--device`
- La maquina docker monta el dispositivo que le pasamos

Esto requiere ejecutar la máquina en modo `--privileged`. Lo cual permite
al contenedor leer y escribir en todos los dispositivos del host, y por
extensión acceder a sus datos. Lo cual constituye un problema de seguridad

En esta nueva versión montaremos el dispositivo en el host `/fs`

Actualizamos entonces los `Dockerfile` y `new_instance.sh`

## Clobber core

El programa a ejecutarse en cada instancia de clobber es un servidor Flask
que aceptará, procesará y devolverá datos JSON de manera muy eficiente.

### Diseño

La arquitectura del núcleo es simple. Un backend extensible al que podemos añadir dos
elementos diferenciados: Apps y Reglas.

Las apps son páginas frontend, para funcionar solo necesitan incluir el script proporcionado clobber.js
Las reglas son librerías de funciones que se comunican con la máquina docker diréctamente.

Estos dos elementos pueden interaccionar mediante peticiones (las reglas se exponen como endpoints y devuelven
un json)
