CC = gcc
CFLAGS = -std=c11 -g -O0

.PHONY: all test clean

all: runtime.o fake_prog

test: runtime.o
	racket run-tests.rkt

runtime.o: runtime.c
	$(CC) $(CFLAGS) -c $^

fake_prog: fake_prog.c runtime.o
	$(CC) $(CFLAGS) $^ -o $@

yinyang: runtime.o tests/r8_5.s
	$(CC) $(CFLAGS) $^  -o $@

clean:
	rm -rf fake_prog runtime.o
