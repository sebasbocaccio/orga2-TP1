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
    listAddLast(l, strClone("hola"));
    listAddLast(l, strClone("zapallo"));
    listAddLast(l, strClone("hola"));

    char* toRemove = "hola";

    FILE* fptr = fopen("output.txt", "w");
    listPrint(l, fptr, (funcPrint_t*)&strPrint);
    printf("\n");
    listRemove(l, toRemove, (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    listRemoveLast(l, (funcDelete_t*)&strDelete);
    listPrint(l, fptr, (funcPrint_t*)&strPrint);
    //listDelete(l, (funcDelete_t*)&strDelete);
    free(l);
    fclose(fptr);
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


