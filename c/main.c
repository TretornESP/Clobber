#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main() {

  int fd, fd2, longitud_cliente, puerto, numbytes;
  char buf[100];
  struct sockaddr_in server;
  struct sockaddr_in client;

  server.sin_family = AF_INET;
  server.sin_port = htons(1337);
  server.sin_addr.s_addr = INADDR_ANY;
  bzero(&(server.sin_zero), 8);

  if (( fd = socket(AF_INET, SOCK_STREAM, 0) ) < 0 ) {
    perror("Error de apertura de socket");
    exit(-1);
  }

  if (bind(fd, (struct sockaddr*) &server, sizeof(struct sockaddr)) == -1) {
    printf("Error en bind() \n");
    exit(-1);
  }

  if (listen(fd, 5) == -1) {
    printf("error en listen()\n");
    exit(-1);
  }

  while (1) {
    longitud_cliente = sizeof(struct sockaddr_in);

    if ((fd2 = accept(fd, (struct sockaddr *) &client, &longitud_cliente)) == -1) {
      printf("error en accept() \n");
      exit(-1);
    }

    send(fd2, "Bienvenido al server\n", 26, 0);

    while ((numbytes=recv(fd2,buf,100,0)) > 0){
      buf[numbytes]='\0';
      printf("Mensaje del Servidor: %s\n",buf);
    }
    close(fd2);
  }
  close(fd);
  return 0;
}
