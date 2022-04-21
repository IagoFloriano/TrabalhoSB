#ifndef __CODIGO_SB__
#define __CODIGO_SB__

void *alocaMem (int num_bytes);

void iniciaAlocador();

void finalizaAlocador();

void liberaMem(void *bloco);

void imprimeMapa();

#endif  // __CODIGO_SB__
