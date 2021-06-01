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
