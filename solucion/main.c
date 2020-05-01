#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_string() {
}

void test_lista(FILE *pfile){
    list_t* l = listNew();
    char* data = "Batata";
    char* data2 = "Dado";
    char* data3 = "Pedrito";

    char* mallocdata = strClone(data);
    char* mallocdata2 = strClone(data2);
    char* mallocdata3 = strClone(data3);

    char* prueba = "Zapallo";
    char* mallocprueba = strClone(prueba);

    listAddLast(l, mallocdata);
    listAddLast(l, mallocdata2);
    listAddLast(l, mallocdata3);

    listAdd(l, mallocprueba, (funcCmp_t*)&strCmp);

    FILE* fptr = fopen("output.txt", "w");
    listPrint(l, fptr, (funcPrint_t*)&strPrint);

    fclose(fptr);

    listDelete(l, (funcDelete_t*)&strDelete);
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


