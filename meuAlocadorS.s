# ---- GLOBAIS ---- #
# Variaveis
.globl	atual_p
.globl	inicio_heap
.globl	fim_heap

# Funcoes
.globl alocaMem
.globl iniciaAlocador
.globl finalizaAlocador
.globl liberaMem
#.globl imprimeMapa

.section .data
	atual_p:		.quad 0
	inicio_heap:	.quad 0
	fim_heap:	    .quad 0

.section .text

alocaMem:
	pushq %rbp
	movq %rsp, %rbp

	pushq %r12				# boas práticas: guardar os registradores callee
	pushq %r13
	pushq %r14
	pushq %r15

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

				pushq %rdi				# guarda o num_bytes (%rdi)

				movq $12, %rax
				movq fim_heap, %rdi
				syscall					# brk(fim_heap)
				# (aumenta a brk no menor multiplo de 1024 maior que num_bytes)

				popq %rdi

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

		f_w_AM_1:		# fim do primeiro while do alocaMem

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

	f_if_AM_3:			# fim do terceiro if do alocaMem

	movq %r12, %rax
	addq %rdi, %rax
	addq $16, %rax
	movq %rax, atual_p

	movq %r12, %rax

	popq %r12				# boas práticas: devolver os registradores callee
	popq %r13
	popq %r14
	popq %r15

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

liberaMem:
	pushq %rbp
	movq %rsp, %rbp

	pushq %r12				# boas práticas: devolver os registradores callee
	pushq %r13
	pushq %r14

	movq %rdi, %rax
	subq $16, %rax			# bloco - 16
	movq %rax, %r12			# est_end (%r12) = bloco - 16

	movq $0, (%r12)			# *(est_end) = 0		(pega o endereço do estado do bloco, coloca "vazio" nele)

	movq %rdi, %rax
	subq $8, %rax			# bloco - 8
	movq (%rax), %r13		# tam (%r13) = *(bloco - 8)

	movq %rdi, %rax
	addq %r13, %rax			# bloco + tam
	movq %rax, %r14			# end_aux (%r14) = bloco + tam

	# if (*(end_aux) == 0)
	movq (%r14), %rax		# (juntar o bloco da frente)
	cmpq $0, %rax			# *(end_aux) == 0
	jne f_if_LM_1

		movq %rdi, %rax
		subq $8, %rax			# bloco - 8

		movq %r14, %rbx
		addq $8, %rbx			# end_aux + 8
		movq (%rbx), %rbx		# *(end_aux + 8)
		addq $16, %rbx			# *(end_aux + 8) + 16

		addq %rbx, (%rax)		# *(bloco - 8) += *(end_aux + 8) + 16
		# (o tamanho do bloco vai virar o tamanho atual + tamanho do da frente + 16)

	f_if_LM_1:		# fim do primeiro if do liberaMem

	movq %rdi, %rax
	subq $8, %rax			# bloco - 8
	movq (%rax), %r13		# tam = *(bloco - 8)

	movq %rdi, %rax
	addq %r13, %rax			# bloco + tam
	addq $16, %rax			# bloco + tam + 16
	movq %rax, %r14			# end_aux = bloco + tam + 16

	movq %r14, atual_p		# atual_p = end_aux

	# while ((end_aux != bloco) && (end_aux + *(int64_t *)(end_aux - 8) + 16 != bloco))
	c_w_LM_1:			# primeiro while do liberaMem
		
		cmpq %rdi, %r14			# end_aux != bloco
		je f_w_LM_1

		movq %r14, %rax
		subq $8, %rax			# end_aux - 8
		movq (%rax), %rax		# *(end_aux - 8)
		addq %r14, %rax			# end_aux + *(end_aux - 8)
		addq $16, %rax			# end_aux + *(end_aux - 8) + 16
		cmpq %rdi, %rax			# end_aux + *(end_aux - 8) + 16 != bloco
		je f_w_LM_1
		# (chega no bloco anterior)

		movq %r14, %rax
		subq $8, %rax			# end_aux - 8
		movq (%rax), %r13		# tam = *(end_aux - 8)

		movq %r13, %rax
		addq $16, %rax			# tam + 16
		addq %rax, %r14			# end_aux += tam + 16

		# if (end_aux >= fim_heap)
		cmpq fim_heap, %r14		# (chegando no final, vai pro começo)
		jl f_if_LM_2

			movq inicio_heap, %rax
			addq $16, %rax					# inicio_heap + 16
			movq %rax, %r14					# end_aux = inicio_heap + 16

		f_if_LM_2: 		# fim do segundo if do liberaMem

		jmp c_w_LM_1		# retorna ao inicio do laço

	f_w_LM_1:		# fim do primeiro while do liberaMem

	# if (end_aux == bloco)
	cmpq %rdi, %r14
	jne f_if_LM_3		# end_aux == bloco

		popq %r12				# boas práticas: devolver os registradores callee
		popq %r13
		popq %r14

		popq %rbp			# return
		ret

	f_if_LM_3:		# fim do terceiro if do liberaMem

	# if (*(int64_t *)(end_aux - 16) == 0)
	movq %r14, %rax
	subq $16, %rax				# end_aux - 16
	movq (%rax), %rax			# *(end_aux - 16)
	cmpq $0, %rax				# *(end_aux - 16) == 0
	jne f_if_LM_4

		# (juntar o bloco de trás)
		movq %r14, %rax
		subq $8, %rax			# end_aux - 8

		movq %rdi, %rbx
		subq $8, %rbx			# bloco - 8
		movq (%rbx), %rbx		# *(bloco - 8)
		addq $16, %rbx			# *(bloco - 8) + 16

		addq %rbx, (%rax)		# *(end_aux - 8) += *(bloco - 8) + 16
		# (o tamanho do bloco vai virar o tamanho do atual + o do que foi liberto)

	f_if_LM_4:		# fim do quarto if do liberaMem

	popq %r12				# boas práticas: devolver os registradores callee
	popq %r13
	popq %r14

	popq %rbp
	ret

#imprimeMapa:
#  pushq %rbp
#  movq %rsp, %rbp
#
#  popq %rbp
#  ret
#	
#	//bora lá, a gente consegue :)
