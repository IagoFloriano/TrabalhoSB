# ---- GLOBAIS ---- #
#Variaveis
.globl	atual_p
.globl	inicio_heap
.globl	fim_heap

#Funcoes
#.globl alocaMem
.globl iniciaAlocador
#.globl finalizaAlocador
#.globl liberaMem
#.globl imprimeMapa

.section .data
	atual_p:		  .quad 0
	inicio_heap:	.quad 0
	fim_heap:	    .quad 0

.section .text

#alocaMem:
#  pushq %rbp
#  movq %rsp, %rbp
#
#  popq %rbp
#  ret


iniciaAlocador:
  pushq %rbp
  movq %rsp, %rbp

  # pegar valor de brk(0)
  movq $12, %rax
  movq $0, %rdi
  syscall

  movq %rax, inicio_heap #salva brk(0) em inicio_heap
  addq $16, %rax
  movq %rax, atual_p     #salva inicio_heap + 16 em atual_p

  # brk(atual_p + 1024)
  addq $1024, %rax
  movq %rax, %rdi
  movq %rax, fim_heap    #salva final de brk em fim_heap
  movq $12, %rax
  syscall

  movq inicio_heap, %rax
  movq $0, (%rax)
  addq $8, %rax
  movq $1024, (%rax)

  popq %rbp
  ret

#
#finalizaAlocador:
#  pushq %rbp
#  movq %rsp, %rbp
#
#  popq %rbp
#  ret
#
#
#liberaMem:
#  pushq %rbp
#  movq %rsp, %rbp
#
#  popq %rbp
#  ret
#
#
#imprimeMapa:
#  pushq %rbp
#  movq %rsp, %rbp
#
#  popq %rbp
#  ret
#	
#	//bora lá, a gente consegue :)
