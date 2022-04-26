CFLAGS  = -Wall -g -static
#LDFLAGS = -lmatheval -lm
OBJS = pgma.o meuAlocador.o #meuAlocadorC.o

all: programa

programa: $(OBJS)
	gcc -o programa $(CFLAGS) $(OBJS)

pgma.o: pgma.c
	gcc $(CFLAGS) -c pgma.c

meuAlocadorC.o: meuAlocadorC.c
	gcc $(CFLAGS) -c meuAlocadorC.c

meuAlocador.o: meuAlocador.s
	as meuAlocador.s -o meuAlocador.o -g

clean:
	-rm -f *~ *.o *.gch
