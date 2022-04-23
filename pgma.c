#include "meuAlocador.h"
#include <stdio.h>

int main()
{
	void *a, *b, *c, *d, *e;
	iniciaAlocador();
	imprimeMapa();
	printf("\n");
	fflush(stdout);

	a = alocaMem(240);
	imprimeMapa();
	printf("\n");
	fflush(stdout);
	b = alocaMem(50);
	imprimeMapa();
	printf("\n");
	fflush(stdout);
	c = alocaMem(500);
	imprimeMapa();
	printf("\n");
	fflush(stdout);
	d = alocaMem(200);
	imprimeMapa();
	printf("\n");
	fflush(stdout);
	e = alocaMem(150);
	imprimeMapa();
	printf("\n");
	fflush(stdout);

	liberaMem(d);
	imprimeMapa();
	printf("\n");
	fflush(stdout);

	liberaMem(e);
	imprimeMapa();
	printf("\n");
	fflush(stdout);

	finalizaAlocador();
}
