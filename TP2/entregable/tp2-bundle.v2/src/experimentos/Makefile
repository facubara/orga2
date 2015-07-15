# ************************************************************************* #
# Organizacion del Computador II                                            #
#                                                                           #
#   Trabajo Practico 2                                                      #
#                                                                           #
# ************************************************************************* #

all: makes correrTest

CFLAGS=-Wall -Wextra -pedantic -O0 -ggdb -lm -std=c99

makes:
	make -C ../bmp
	make -C ../tools
	make -C ../filters

%.o: %.c test.h 
	gcc $(CFLAGS) -c -o $@ $<
	
correrTest: test.o correrTest.o makes
	gcc $(CFLAGS) correrTest.o test.o ../filters/*.o ../bmp/*.o -o correrTest -lm
	cp correrTest ../../bin/
	
clean:
	make -C ../bmp clean
	make -C ../tools clean
	make -C ../filters clean
	rm  -f *.o correrTest
