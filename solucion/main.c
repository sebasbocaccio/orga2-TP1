#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_cmp(FILE *pfile) {
    uint8_t* a = (uint8_t*)malloc(3);
    a[0] = 'a';
    a[1] = 0xFF
    ;
    a[2] = 0;

    int res = strCmp("a", (char*)a);
    int res_back = strCmp((char*)a, "a");

    printf("Primero 'a' es: %d. Backwards es: %d\n", res, res_back);
}

char* randomHexString(uint32_t l) {
    char* s = malloc(l+1);
    for(uint32_t i=0; i<(l+1); i++) {
        do {
            s[i] = (char)(rand()%256);
        } while (s[i]==0);
    }
    s[l] = 0;
    return s;
}

void test_string() {
    FILE* files = fopen("salidanull.txt", "w");    
    char* b = strClone("");
    strPrint(b, files);
    strDelete(b);

    fclose(files);
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

void test_sorter_hash_funcs(FILE *pfile) {
    sorter_t* s = sorterNew(256, (funcSorter_t*)&fs_firstChar, (funcCmp_t*)&strCmp);
        for(int j=0; j<30; j++) {
            for(int l=0; l<10; l++) {
                sorterAdd(s, randomHexString(l));
            }
        }
        sorterPrint(s, pfile, (funcPrint_t*)&strPrint);
        for(int i=0; i<256; i++) {
            if (i == 64) {
                char* concat = sorterGetConcatSlot(s,i);
                fprintf(pfile, "\n [GASTI]  \n");
                hexPrint(concat, pfile);
                free(concat);
            }
        }
        sorterRemove(s, "a", (funcDelete_t*)&strDelete);
        sorterCleanSlot(s, (17*0)%256, (funcDelete_t*)&strDelete);
        //sorterPrint(s, pfile, (funcPrint_t*)&strPrint);
    
}

int main (void){
    srand(12345);

    FILE *pfile = fopen("salida.caso.propios.txt","w");
    //test_lista(pfile);
    //test_sorter(pfile);
    //test_string();
    //test_sorter_hash_funcs(pfile);
    test_cmp(NULL);
    fclose(pfile);
    printf("\n Termino tests \n");
    return 0;
}


