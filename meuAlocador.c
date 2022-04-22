#include <unistd.h>
#include <stdint.h>
#include <stdio.h>

void* atual_p;
void* inicio_heap;

void *alocaMem (int num_bytes){
  void*  ponteiro_mem = atual_p;
  int64_t tam         = *(int64_t *)(ponteiro_mem - 8);
  int64_t estado      = *(int64_t *)(ponteiro_mem - 16);
  
  while (!( (tam >= num_bytes) && (estado == 0) )){
    ponteiro_mem += tam + 16;
    if (ponteiro_mem == atual_p){
      //o ponteiro deu a volta inteira e nao encontrou espaço
      while (ponteiro_mem < sbrk(0)){
        //enquanto o ponteiro estiver dentro da heap
        ponteiro_mem += tam + 16;
        tam = *(int64_t *)(ponteiro_mem - 8);
      }
      
      sbrk (1024 + 16);
      //aumenta a brk em num_bytes
      
      *(int64_t *)(ponteiro_mem - 8)  = (int8_t)1024;
      *(int64_t *)(ponteiro_mem - 16) = (int8_t)0;
      //adiciona um espaço livre de 1024
    }
    
    if (ponteiro_mem > sbrk(0))
        ponteiro_mem = inicio_heap + 16;
    //dependendo do jeito de pegar o inicio_brk, talvez nao precise de +16
    
    tam    = *(int64_t *)(ponteiro_mem - 8);
    estado = *(int64_t *)(ponteiro_mem - 16);
  }

  *(int64_t *)(ponteiro_mem - 16) = 1;
  if (tam > num_bytes + 16) { //caso dê para criar um novo bloco em tam - num_bytes
    *(int64_t *)(ponteiro_mem + num_bytes)     = 0;                    //estado do próximo bloco como livre
    *(int64_t *)(ponteiro_mem + num_bytes + 8) = tam - num_bytes - 16; //tamanho do próximo bloco como tamanho antigo desse bloco menos info
    *(int64_t *)(ponteiro_mem - 8)             = num_bytes;            //salva tamanho desse bloco
  }
  atual_p = ponteiro_mem + num_bytes + 16;

  return ponteiro_mem;
}

void iniciaAlocador() {
  printf("\n");
  inicio_heap = sbrk(0);
  //chama a syscall que retorna o valor atual de brk

  sbrk(1024 + 16);
  *(int64_t *)(inicio_heap) = 0;
  *(int64_t *)(inicio_heap + 8) = 1024;
  //cria primeiro bloco
  atual_p      = inicio_heap + 16;
}

void finalizaAlocador (){
  brk(inicio_heap);
  //chama a syscall alterando o valor da brk pro encontrado no iniciaAlocador
}

void liberaMem (void* bloco){
  void* est_end = bloco - 16;
  *(int64_t *)(est_end) = 0;
  //pega o endereço do estado do bloco, coloca "vazio" nele

  //terminar de programar a junção de blocos vazios

  int64_t tam     = *(int64_t *)(bloco - 8);
  void*   end_aux = bloco + tam;
  if (*(int64_t *)(end_aux) == 0){   //juntar o bloco da frente
    *(int64_t *)(bloco-8) += *(int64_t *)(end_aux+8) + 16;  //o tamanho do bloco vai virar o tamanho atual + tamanho do da frente + 16
  }

  tam     = *(int64_t *)(bloco - 8);
  end_aux = bloco + tam + 16;
  atual_p = end_aux;

  void* fim_heap = sbrk(0);

  while ((end_aux != bloco) && (end_aux + *(int64_t *)(end_aux - 8) + 16 != bloco)){    //chega no bloco anterior
    tam     = *(int64_t *)(end_aux - 8);
    end_aux += tam + 16;

    if (end_aux >= fim_heap)                    //chegando no final, vai pro começo
      end_aux = inicio_heap + 16;
  }
  
  if (end_aux == bloco)
    return;

  if (*(int64_t *)(end_aux - 16) == 0){               //juntar o bloco de trás
    *(int64_t *)(end_aux-8) += *(int64_t *)(bloco-8) + 16;  //o tamanho do bloco vai virar o tamanho do atual + o do que foi liberto
  }
}

void imprimeMapa(){
  void* imprimindo = inicio_heap;
  int64_t tam;
  char estado;

  while (imprimindo < sbrk(0)){ // percorrer por toda a heap
    printf("########"); // imprime # de informação
    if (*(int64_t *)(imprimindo) == 0) // verifica qual char vai ser impresso tam vezes
      estado = '-';
    else estado = '+';
    tam = *(int64_t *)(imprimindo + 8);

    for (int i = 0; i < tam; i++){
      printf("%c", estado);
    }

    imprimindo += tam + 16;
  }
  printf("\n");

}
