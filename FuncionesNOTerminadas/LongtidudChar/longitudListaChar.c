#include <stdio.h>
extern __uint32_t strLen(char* a);




int main(int argc, char* argv[]){
	//Primero Asigno
	char  v[5] = {'h','o','l','a','s'};

	// LLamo a mi funcion
	__uint32_t   cantidad = strLen(&v[0]);  
	printf("%c\n",v[0]);
	printf("%hd\n", cantidad);
	return 0;
}