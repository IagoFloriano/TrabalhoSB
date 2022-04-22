#include "meuAlocador.h" 

int main() {
  void *a, *b, *c, *d, *e;
  iniciaAlocador();
  imprimeMapa();
  a	=	alocaMem(240);
  imprimeMapa();
  b	=	alocaMem(50);
  imprimeMapa();

  e = alocaMem(1000);
  liberaMem(a);
  imprimeMapa();
  a=alocaMem(50);
  imprimeMapa();




  finalizaAlocador();

}
