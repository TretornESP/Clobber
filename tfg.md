# Clobber: documento técnico de infraestructuras
## Por Xabier Iglesias Pérez
## Esquema de red

### Router gw.clobber.com (10.10.24.1)

VM Debian con dos interface de red: NAT y RED INTERNA (clobber)
Enruta los paquetes de clobber hacia NAT
Hace de firewall, dhcp y dns

### Servidor de almacenamiento (10.10.24.3 ip fija)

Contiene un servidor SCSI
Se accede a el mediante el webserver por ssh
Contiene scripts de generacion de almacenamiento a medida

### Servidor de virtualizacion (10.10.24.2 ip fija)

Enlaza y maneja el motor docker
Se accede a el mediante el webserver por ssh
Contiene scripts de generacion y puesta en marcha de imágenes

### Servidor web (ip por dhcp, en el futuro se cambiara)

Expone de manera controlada el acceso a las vms


# Configurar la red
## Configuracion del router
- __[Moodle UDC](https://campusvirtual.udc.gal/pluginfile.php/470912/mod_resource/content/1/2021.%20AII.%20Pr%C3%A1cticas.%20D%C3%ADa%201.pdf)__ - Usamos la configuracion del router gw.acme.pri

En este caso configuramos un router debian, a mayores añadimos dhcp:

``` bash
apt install isc-dhcp-server
nano /etc/default/isc-dhcp-server
```
---
``` bash
INTERFACESv4="enp0s3"
```
---
``` bash
nano /etc/dhcp/dhcpd.conf
```
---
``` bash
option domain-name "clobber.com";
option domain-name-servers 127.0.0.1;

authoritative

subnet 10.10.24.0 netmask 255.255.255.0 {
  range 10.10.24.2 10.10.24.254;
  option routers 10.10.24.1;
  option broadcast-address 10.10.24.255;
}

host storage {
  hardware ethernet 08:00:27:74:f7:2b;
  fixed-address 10.10.24.3;
}
```

Y dns con bind9

``` bash
apt install bind9 bind9utils
nano /etc/bind/named.conf.options
```
---
``` bash
acl allowed_clients {
        localhost;
        10.10.24.0/24;
};

options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0s placeholder.

        forwarders {
                8.8.8.8;
                8.8.4.4;
        };
        recursion yes;
        allow-query { allowed_clients; };
        forward only;

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        dnssec-validation auto;

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};
```

---
## Configuracion de los clientes
En los clientes estamos haciendo

``` bash
nano /etc/netplan/01-network-manager-all.yaml
```
---
``` yaml
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enp0s3:
      dhcp4: yes
      addresses: []
```

Tal vez haya que configurar `/etc/resolv.conf`

Añadimos acceso ssh con

``` bash
sudo apt install openssh-server
#cambiamos la contraseña de root
sudo su
passwd
#suelo poner osboxes.org
nano /etc/ssh/sshd_config
systemctl restart sshd
#aqui cambiamos y descomentamos PermitRootLogin a yes
sudo ufw allow ssh
```



# Configurar iSCSI
- __[Cybercity](https://www.cyberciti.biz/tips/howto-setup-linux-iscsi-target-sanwith-tgt.html)__ - Comandos sobre iSCSI
- __[stackoverflow](https://stackoverflow.com/questions/43929963/automate-iscsi-mounting-unmounting)__ - Relacionar el disco scsi con el dispositivo

## Configuracion del servidor iSCSI

El servidor iSCSI en si no tiene configuración, crearemos un target con el nombre de nuestro usuario

``` bash
apt install tgt
/usr/sbin/tgtd
```

Los comandos a ejecutar para crear un disco ext4 de 512MB para el usuario tretorn, numero 76 son:
`la carpeta ~/fs debe existir`
``` bash
dd if=/dev/zero of=~/fs/tretorn bs=1M count=512
mkfs -t ext4 ~/fs/tretorn
tgtadm --lld iscsi --op new --mode target --tid 76 -T iqn.2021-05.com.clobber:tretorn
tgtadm --lld iscsi --op new --mode logicalunit --tid 76 --lun 1 -b ~/fs/tretorn
tgtadm --lld iscsi --op bind --mode target --tid 76 -I ALL
```

### Comandos de limpieza del servidor

``` bash
sudo tgtadm --lld iscsi --op delete --force --mode target --tid 1 #Borra el target 1
sudo tgtadm --lld iscsi --op show --mode target #Muestra todos los targets
rm /fs/* #Borra los ficheros, PELIGROSISIMO!!!!

```
## Configuración del cliente iSCSI

Podemos ejecutar el siguiente comando para testear, pero en el script resulta innecesario
``` bash
iscsiadm --mode discovery --type sendtargets --portal 10.10.24.3
```

Por lo demás con los siguientes comandos:


``` bash
iscsiadm --mode node --targetname iqn.2021-05.com.clobber:tretorn --portal 10.10.24.3:3260 --login
dev=$(lsscsi -t | grep 'iqn.2021-05.com.clobber:tretorn' | grep '/dev/' | awk '{print $NF}')

```

### Comandos de limpieza del cliente

``` bash
lsscsi -t # Ver todos los targets logeados
sudo iscsiadm --mode node --logoutall=all #sale de todos los targets
sudo iscsiadm --mode node --targetname TARGET --portal IP:PUERTO -u #desloguea del target especificado
```

## Configuracion del container docker
- __[Digitalocean](hhttps://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04-es)__ - Como instalar docker
---

Para generar la maquina clobber creamos el siguiente `Dockerfile`

``` dockerfile
# syntax=docker/dockerfile:1

FROM ubuntu
RUN apt update && apt install --no-install-recommends -y ssh python3.8 python3-pip python3.8-dev
WORKDIR /server
COPY python/app/requirements.txt .
RUN pip install -r requirements.txt
COPY python/app/src/ .
RUN echo 'root:clobber' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
WORKDIR /fs
RUN mount /dev/vhd .
ENTRYPOINT service ssh start && python3 main.py

```

Y buildeamos con:

``` bash
docker build -t clobber .
```
`Debemos ejecutar el comando en el mismo directorio que la dockerfile`


## Lanzamiento del container docker

- __[FreeCodeCamp](https://www.freecodecamp.org/news/how-to-get-a-docker-container-ip-address-explained-with-examples/)__ - Sacar la ip via container id
---

Continuando con el último script ejecutamos:

``` bash
id=$(docker run -d --privileged --device $dev:/dev/vhd clobber)
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id

```

Podemos hacer ssh a la ip que nos devolvio el último comando con
`ssh root@ip` user `root` contraseña `clobber`

## Configuracion del servidor web + comandos

En función del tiempo separaré este en 2 (firewall protegiendo datos)

Ejecutaremos los comandos por ssh, asi que:

``` bash
ssh-keygen
ssh-copy-id -i ~/.ssh/id_rsa.pub root@10.10.24.2
ssh-copy-id -i ~/.ssh/id_rsa.pub root@10.10.24.3
```

Luego modificamos de nuevo la config de ssh en los clientes

``` bash
nano /etc/ssh/sshd_config
#ponemos PermitRootLogin a without-password
systemctl restart sshd
```

#URLS:
  https://stackoverflow.com/questions/34496882/get-docker-container-id-from-container-name
  https://stackoverflow.com/questions/43721513/how-to-check-if-the-docker-engine-and-a-docker-container-are-running
  https://www.linuxquestions.org/questions/linux-server-73/iptable-port-forward-between-two-lan-interface-945719/ creo que este
  https://serverfault.com/questions/532569/how-to-do-port-forwarding-redirecting-on-debian creo que este no
  https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-ubuntu-20-04-es
  https://makitweb.com/create-simple-login-page-with-php-and-mysql/
  https://serverfault.com/questions/273324/how-to-make-iptables-rules-expire
  https://askubuntu.com/questions/1108042/map-a-range-of-ports-to-another-range-of-ports-equal-lengths-of-ranges
  https://serverfault.com/questions/729810/dnat-port-range-with-different-internal-port-range-with-iptables importante!!

  gunicorn --bind 0.0.0.0:9420 main:app --log-level warning

  Comando para el docker-server


  Que hice:
    Router ip tables a webserver
    Webserver server apache2 + php + mysql a pelo

  https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-20-04-es
  
