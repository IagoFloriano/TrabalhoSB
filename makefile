CFLAGS  = -Wall -g -static
#LDFLAGS = -lmatheval -lm
OBJS = pgma.o meuAlocador.o meuAlocadorS.o

all: programa

programa: $(OBJS)
	gcc -o programa $(CFLAGS) $(OBJS)

pgma.o: pgma.c
	gcc $(CFLAGS) -c pgma.c

meuAlocador.o: meuAlocador.c
	gcc $(CFLAGS) -c meuAlocador.c

meuAlocadorS.o: meuAlocadorS.s
	as meuAlocadorS.s -o meuAlocadorS.o

clean:
	-rm -f *~ *.o *.gch
