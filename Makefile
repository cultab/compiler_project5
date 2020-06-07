FLAGS= -Wall -Wpedantic
LIBS = -lm


all:
	flex  -o flex.c  flex.l
	bison -o bison.c bison.y -v -d
	cc -o pyparse flex.c bison.c $(FLAGS) $(LIBS)

clean:
	rm flex.c bison.c bison.h

run: all
	./pyparse

test: all
	./pyparse input.txt output.txt

tests: all
	./test_bad.sh
