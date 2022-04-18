void *alocaMem (int num_bytes){
  void*  ponteiro_mem = atual_p;
  int    tam          = *(ponteiro_mem - 8);
  int    estado       = *(ponteiro_mem - 16);
  
  while (!( (tam >= num_bytes) && (estado == 0) )){
    ponteiro_mem += tam + 16;
    if (ponteiro_mem == atual_p){
      //o ponteiro deu a volta inteira e nao encontrou espaço
      while (ponteiro_mem < brk){
        //enquanto o ponteiro estiver dentro da heap
        ponteiro_mem += tam + 16;
        tam = *(ponteiro_mem - 8);
      }
      
      brk += (1024 + 16);
      //aumenta a brk de alguma forma para aumentar a heap 
      
      *(ponteiro_mem - 8)  = 1024;
      *(ponteiro_mem - 16) = 0;
      //adiciona um espaço livre de 1024
    }
    
    if (ponteiro_mem > brk)
        ponteiro_mem = inicio_brk + 16;
    //dependendo do jeito de pegar o inicio_brk, talvez nao precise de +16
    
    tam = *(ponteiro_mem - 8);
    estado = *(ponteiro_mem - 16);
  }

  *(ponteiro_mem - 16) = 1;
  if (!( tam > num_bytes + 16)) { //caso dê para criar um novo bloco em tam - num_bytes
    *(ponteiro_mem + num_bytes) = 0;  //estado do próximo bloco como livre
    *(ponteiro_mem + num_bytes + 8) = tam - num_bytes - 16; //tamanho do próximo bloco como tamanho antigo desse bloco menos info
    *(ponteiro_mem - 8) = num_bytes; //salva tamanho desse bloco
  }
  return ponteiro_mem;
}

iniciaAlocador {
  global void* inicio_brk = syscall;
  //chama a syscall que retorna o valor atual de brk
  
  global void* atual_p = inicio_brk;
}

finalizaAlocador (){
  syscall brk <- inicio_brk;
  //chama a syscall alterando o valor da brk pro encontrado no iniciaAlocador
}

liberaAlocador (void* bloco){
  void* est_end = bloco - 16;
  *(est_end) = 0;
  //pega o endereço do estado do bloco, coloca "vazio" nele
}
