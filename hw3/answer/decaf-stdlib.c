

#include <stdio.h>

void print_int(int x) {
  printf("%d", x);
}

void print_string(const char *s) {
  printf("%s", s);
}

int read_int() {
  int i;
  scanf("%d", &i);
  return i;
}

