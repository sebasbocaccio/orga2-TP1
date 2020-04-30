#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_string() {
	char* unString = "hola";
	char* otroString = "mundo";

	char* unStringMallocado = strClone(unString);
	char* otroStringMallocado = strClone(otroString);
	
	char* concat = strConcat(unStringMallocado, unStringMallocado);
	printf("%s\nlength = %d\n", concat, strLen(concat));
	free(concat);
}

void test_lista(FILE *pfile){
    
}

void test_sorter(FILE *pfile){
    
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test_lista(pfile);
    test_sorter(pfile);
    test_string();
    fclose(pfile);
    return 0;
}


