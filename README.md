# p423-public-code
Utility code, test suites, etc. for the compiler course.

This code is suppose to be described in the Appendix of the book.

The runtime.c file needs to be compiled and linked with the assembly
code that your compiler produces. To compile runtime.c, do the
following

   gcc -c -g -std=c99 runtime.c

This will produce a file named runtime.o. The -g flag is to tell the
compiler to produce debug information that you may need to use
the gdb (or lldb) debugger.

Next, suppose your compiler has translated the Racket program in file
foo.rkt into the x86 assembly program in file foo.s (The .s filename
extension is the standard one for assembly programs.) To produce
an executable program, you can then do

  gcc -g runtime.o foo.s

which will produce the executable program named a.out.
  