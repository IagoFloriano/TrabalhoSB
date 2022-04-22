#include "meuAlocador.h"
#include <stdio.h>

int main()
{
	void *a, *b, *c, *d, *e;
	iniciaAlocador();
	imprimeMapa();
	printf("\n");

	a = alocaMem(240);
	b = alocaMem(50);
	c = alocaMem(500);
	d = alocaMem(200);
	e = alocaMem(150);
	imprimeMapa();
	printf("\n");

	liberaMem(d);
	imprimeMapa();
	printf("\n");

	liberaMem(e);
	imprimeMapa();
	printf("\n");

	finalizaAlocador();
}
