# ---- GLOBAIS ---- #
#Variaveis
.globl	atual_p
.globl	inicio_heap
.globl	fim_heap

#Funcoes
.globl alocaMem
.globl iniciaAlocador
.globl finalizaAlocador
#.globl liberaMem
#.globl imprimeMapa

.section .data
	atual_p:		.quad 0
	inicio_heap:	.quad 0
	fim_heap:	    .quad 0

.section .text

alocaMem:
	pushq %rbp
	movq %rsp, %rbp

	movq atual_p, %r12		# ponteiro_mem (%r12) = atual_p

	movq %r12, %rax
	subq $8, %rax			# ponteiro_mem - 8
	movq (%rax), %r13		# tam (%r13) = *(ponteiro_mem - 8)

	movq %r12, %rax
	subq $16, %rax			# ponteiro_mem - 16
	movq (%rax), %r14		# est (%r14) = *(ponteiro_mem - 16)

	# while ((tam < num_bytes) || (estado != 0))
	w_AM_1:			# primeiro while do alocaMem
		cmpq %rdi, %r13		# tam < num_bytes
		jl c_w_AM_1			# se tam < num_bytes, já começa o laço

		cmpq $0, %r14		# est != 0
		jne c_w_AM_1		# se est != 0, já começa o laço

		jmp f_w_AM_1		# sai do laço

		c_w_AM_1:		# começo do primeiro while do alocaMem
			movq %r13, %rax
			addq $16, %rax			# tam + 16
			addq %rax, %r12			# ponteiro_mem += tam + 16

			# if (ponteiro_mem == atual_p)		(o ponteiro deu a volta inteira e nao encontrou espaço)
			cmpq atual_p, %r12		# ponteiro_mem == atual_p
			jne f_if_AM_1

				# while (ponteiro_mem < fim_heap)		(enquanto o ponteiro estiver dentro da heap)
				c_w_AM_2:		# começo do segundo while do alocaMem
					cmpq fim_heap, %r12		# ponteiro_mem < fim_heap
					jge f_w_AM_2

					movq %r12, %rax
					subq $8, %rax			# ponteiro_mem - 8
					movq (%rax), %r13		# tam = *(ponteiro_mem - 8)

					movq %r13, %rax
					addq $16, %rax			# tam + 16
					addq %rax, %r12			# ponteiro_mem += tam + 16

					jmp c_w_AM_2		# retorna ao inicio do laço
				f_w_AM_2:		# fim do segundo while do alocaMem

				movq $0, %r15			# incremento (%r15) = 0

				# while (incremento < num_bytes)
				c_w_AM_3:		# começo do terceiro while do alocaMem
					cmpq %rdi, %r15			# incremento < num_bytes
					jge f_w_AM_3

					addq $1024, %r15		# incremento += 1024

					jmp c_w_AM_3		# retorna ao inicio do laço
				f_w_AM_3: 		# fim do terceiro while do alocaMem

				movq %r15, %rax
				addq $16, %rax			# incremento + 16
				addq %rax, fim_heap		# fim_heap += incremento + 16

				movq $12, %rax
				movq fim_heap, %rdi
				syscall					# brk(fim_heap)
				# (aumenta a brk no menor multiplo de 1024 maior que num_bytes)

				movq %r12, %rax
				subq $8, %rax
				movq %r15, (%rax)		# *(ponteiro_mem - 8) = incremento

				movq %r12, %rax
				subq $16, %rax
				movq $0, (%rax)			# *(ponteiro_mem - 16) = 0

				# (adiciona um espaço livre de 1024)

			f_if_AM_1:		# fim do primeiro if do alocaMem

			# if (ponteiro_mem > fim_heap)
			cmpq fim_heap, %r12		# ponteiro_mem > fim_heap
			jle f_if_AM_2

				movq inicio_heap, %rax
				addq $16, %rax				# inicio_heap + 16
				movq %rax, %r12				# ponteiro_mem = inicio_heap + 16

			f_if_AM_2:		# fim do segundo if do alocaMem

			movq %r12, %rax
			subq $8, %rax			# ponteiro_mem - 8
			movq (%rax), %r13		# tam (%r13) = *(ponteiro_mem - 8)

			movq %r12, %rax
			subq $16, %rax			# ponteiro_mem - 16
			movq (%rax), %r14		# est (%r14) = *(ponteiro_mem - 16)

			jmp w_AM_1		# retorna ao inicio do laço

		f_w_AM_1:

	# acabou o primeiro while :)

	movq %r12, %rax
	subq $16, %rax			# ponteiro_mem - 16
	movq $1, (%rax)			# *(ponteiro_mem - 16) = 1

	# if (tam > num_bytes + 16)
	movq %rdi, %rax
	addq $16, %rax			# num_bytes + 16
	cmpq %rax, %r13			# tam > num_bytes + 16
	jle f_if_AM_3

		movq %r12, %rax
		addq %rdi, %rax			# ponteiro_mem + num_bytes
		movq $0, (%rax)			# *(ponteiro_mem + num_bytes) = 0

		movq %r12, %rax
		addq %rdi, %rax			# ponteiro_mem + num_bytes
		addq $8, %rax			# ponteiro_mem + num_bytes + 8
		movq %r13, %rbx
		subq %rdi, %rbx			# tam - num_bytes
		subq $16, %rbx			# tam - num_bytes - 16
		movq %rbx, (%rax)		# *(ponteiro_mem + num_bytes + 8) = tam - num_bytes - 16

		movq %r12, %rax
		subq $8, %rax			# ponteiro_mem - 8
		movq %rdi, (%rax)		# *(ponteiro_mem - 8) = num_bytes

	f_if_AM_3:			# fim do segundo if do alocaMem

	movq %r12, %rax
	addq %rdi, %rax
	addq $16, %rax
	movq %rax, atual_p

	movq %r12, %rax

	popq %rbp
	ret


iniciaAlocador:
  	pushq %rbp
	movq %rsp, %rbp

	# pegar valor de brk(0)
	movq $12, %rax
	movq $0, %rdi
	syscall

	movq %rax, inicio_heap	# salva brk(0) em inicio_heap			inicio_heap	= sbrk(0)
	addq $16, %rax
	movq %rax, atual_p    	# salva inicio_heap + 16 em atual_p		atual_p		= inicio_heap

	# brk(atual_p + 1024)
	addq $1024, %rax		# %rax	= inicio_heap + 16 + 1024
	movq %rax, %rdi
	movq %rax, fim_heap		# salva final de brk em fim_heap		fim_heap	= inicio_heap + 16 + 1024 
 	movq $12, %rax
	syscall					# o brk agora aponta pro final			brk(fim_heap)

	movq inicio_heap, %rax
	movq $0, (%rax)			# *(inicio_heap + 8)	= 0
	addq $8, %rax
	movq $1024, (%rax)		# *(inicio_heap + 16)	= 1024

	popq %rbp
	ret

finalizaAlocador:
	pushq %rbp
	movq %rsp, %rbp

	movq inicio_heap, %rdi
	movq $12, %rax
	syscall					# brk(inicio_heap)

	popq %rbp				# pera, é só isso mesmo? '-'
	ret

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
