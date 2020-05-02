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
    sorter_t* sorter = sorterNew(5, (funcSorter_t*)&fs_sizeModFive, (funcCmp_t*)&strCmp);
    sorterAdd(sorter, strClone("hola"));
    sorterAdd(sorter, strClone("manzana"));
    sorterAdd(sorter, strClone("abuelas"));
    sorterAdd(sorter, strClone("papa"));
    sorterAdd(sorter, strClone("ma"));
    sorterAdd(sorter, strClone("pa"));
    sorterAdd(sorter, strClone("perro"));
    sorterAdd(sorter, strClone("perro"));
    sorterAdd(sorter, strClone("perro"));
    char* slot2Concatted = sorterGetConcatSlot(sorter, 1);
    fprintf(pfile, "Slot2 concatted: %s\n", slot2Concatted);
    sorterPrint(sorter, pfile, (funcPrint_t*)&strPrint);

    list_t* slot2 = sorterGetSlot(sorter, 3, (funcDup_t*)&strClone);
    fprintf(pfile, "Printing slot 3: \n");
    listPrint(slot2, pfile, (funcPrint_t*)&strPrint);

    listDelete(slot2, (funcDelete_t*)&strDelete);
    sorterDelete(sorter, (funcDelete_t*)&strDelete);
    strDelete(slot2Concatted);
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    //test_lista(pfile);
    test_sorter(pfile);
    //test_string();
    fclose(pfile);
    return 0;
}


