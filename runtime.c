#include <stdlib.h>
#include <stdio.h>
#include "runtime.h"

long int read_int() {
  long int i;
  scanf("%ld", &i);
  return i;
}

void print_int(long x) {
  printf("%ld", x);
}


void print_bool(int x) {
  if (x) 
    printf("#t");
  else printf("#f");
}

    
