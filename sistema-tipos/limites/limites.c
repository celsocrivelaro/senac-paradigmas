#include <stdio.h>
// https://www.tutorialspoint.com/c_standard_library/limits_h.htm
#include <limits.h> // contantes com os valores máximos

int main() {
   int explodir_representacao = 0; 
   
   // INT_MAX = +2147483647 ou 2^32/2 signed_int
   explodir_representacao =  INT_MAX + 1; 
   
   return 0;
}