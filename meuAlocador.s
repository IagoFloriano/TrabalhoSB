.section .data
	atual_p:		.quad 0
	inicio_heap:	.quad 0

.globl	atual_p
.globl	inicio_heap

.section .text

alocaMem:
	
	//bora lá, a gente consegue :)