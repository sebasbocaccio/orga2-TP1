#include "lib.h"

/** STRING **/

void hexPrint(char* a, FILE *pFile) {
    int i = 0;
    while (a[i] != 0) {
        fprintf(pFile, "%02hhx", a[i]);
        i++;
    }
    fprintf(pFile, "00");
}

/** Lista **/

void listRemove(list_t* l, void* data, funcCmp_t* fc, funcDelete_t* fd){
}

void listRemoveFirst(list_t* l, funcDelete_t* fd){
}

void listRemoveLast(list_t* l, funcDelete_t* fd){
}
