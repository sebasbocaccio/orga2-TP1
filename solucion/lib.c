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
	listElem_t* actual = l->first;
	while(actual) {
		uint32_t resultCmp = fc(actual->data, data);
		if(resultCmp == 0) {
			if (actual->prev == NULL) {
				listRemoveFirst(l, fd);
				actual = l->first;
			} else if (actual->next == NULL) {
				listRemoveLast(l, fd);
				actual = NULL;
			} else {
				listElem_t* siguiente = actual->next;
				actual->next->prev = actual->prev;
				actual->prev->next = actual->next;

				if (fd) fd(actual->data);
				free(actual);

				actual = siguiente;
			}
		} else {
			actual = actual->next;
		}
	}

}

void listRemoveFirst(list_t* l, funcDelete_t* fd){
	listElem_t* primero = l->first;
	if (primero) {
		listElem_t* segundo = primero->next;
		l->first = segundo;
		if (segundo) {
			segundo->prev = NULL;
		} else {
			l->last = NULL;
		}
		void* data = primero->data;
		if(fd) fd(data);
		free(primero);
	}
}

void listRemoveLast(list_t* l, funcDelete_t* fd){
	listElem_t* ultimo = l->last;
	if (ultimo) {
		listElem_t* anteultimo = ultimo->prev;
		l->last = anteultimo;
		if (anteultimo) {
			anteultimo->next = NULL;
		} else {
			l->first = NULL;
		}
		void* data = ultimo->data;
		if(fd) fd(data);
		free(ultimo);
	}
}
