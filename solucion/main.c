#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_lista(FILE *pfile){
    list_t* lista = listNew();
    char* strings[10] = {"aa","bb","dd","ff","00","zz","cc","ee","gg","hh"};
    for(int i = 0; i < 10; ++i) {
        listAddLast(lista, strClone(strings[i]));
    }

    listPrint(lista, pfile, (funcPrint_t*) &strPrint);
    listDelete(lista, (funcDelete_t*) &strDelete);
}

void test_sorter(FILE *pfile){
    char* strings[10] = {"a","bb","ccc","dddd","eeeee"};
    sorter_t* sorter = sorterNew(5, (funcSorter_t*) &fs_sizeModFive, (funcCmp_t*) strCmp);

    for(int i = 0; i < 5; ++i) {
        sorterAdd(sorter, strClone(strings[i]));
    }

    sorterPrint(sorter, pfile, (funcPrint_t*) &strPrint);
    sorterDelete(sorter, (funcDelete_t*) &strDelete);
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test_lista(pfile);
    fprintf(pfile, "\n\n");
    test_sorter(pfile);
    fclose(pfile);
    return 0;
}