CFLAGS  = -Wall -g 
#LDFLAGS = -lmatheval -lm
OBJS = pgma.o meuAlocador.o

all: newtonPC

newtonPC: $(OBJS)
	gcc -o programa $(CFLAGS) $(OBJS)

pgma.o: pgma.c
	gcc $(CFLAGS) -c pgma.c

meuAlocador.o: meuAlocador.c
	gcc $(CFLAGS) -c meuAlocador.c

clean: all
	-rm -f *~ *.o *.gch