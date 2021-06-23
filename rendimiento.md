4GB Ram
idle -> 2800mb libres (1055 used)
70 máquinas -> 115mb libres
100 máquinas:
  ST: 17:46
  TG: 18:35
  IN: 22:10
  RE: 22:48
8GB 4 Cores:
  idle -> 5850mb libres (1055 used)
  Se completa con 2150 libres, la cpu maxea
8GB 4 Cores
  Se completa con 2150mb libres, la cpu no pasa del 75%
  ST: 44:48
  TG: 45:38
  IN: 47:02
  RE: 47:29

Aproximación:
  El sistema ocupa aproximadamente 1gb de memoria
  Las máquinas ocupan aproximadamente 37 mb cada una
  Se recomienda un 25% de memoria libre para evitar cuelgues.

  f(n)= (3700*n+102400)/75 ~= 50n+1365

  Según la cuenta de la vieja cada 20 máquinas necesitamos incrementar 1gb
  de memoria

  Mi máquina en idle tiene 13600mb libres.
    El límite con margen de mi máquina es de:
      13600=50n+1365 -> n = 244 máquinas.
    El ĺímite teórico es de:
      (13600-1024)/37 = 339 máquinas.
  En la realidad, con el entorno deplegado quedan unos 6500mb libres.
    El límite real con margen de mi máquina es de:
      6500=50n+1365 -> n = 102 máquinas
    El límite real de mi máquina es de:
      (6500-1024)/37 = 148


Server:
  El server iSCSI aguanto 931 targets de manera lineal antes de petar

Virtualización
  El server de virtualizacion aguantó 175 máquinas hasta gastar los 6.5gb libres de la máquina anfitrión y
  producir un crash. De los 148 calculados hasta los 175 logró llegar mediante el uso del swapfile.
  
