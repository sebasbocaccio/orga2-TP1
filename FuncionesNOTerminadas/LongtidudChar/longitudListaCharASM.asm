global strLen
section .text

%define punteroVector rdi 

;puntero del inicio + tamano del dato *  indice elemento

strLen:
 push rbp
 mov rbp, rsp


;Pongo en cero la salida y el contador por cuantos elementos llevo contando
 mov rcx , 0
 mov eax , 0
ciclar:
 
;Me tengo que fijar si el caracter que me dan no es nulo

mov  al , [punteroVector + 1 * rcx]
cmp al, 0 
je fin
inc rcx 
inc eax
jmp ciclar


fin:
pop rbp
ret 
