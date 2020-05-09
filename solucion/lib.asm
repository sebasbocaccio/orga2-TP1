%define NULL 0

%define nullTerminator 0

%define list_size 16
%define list_first_offset 0
%define list_last_offset 8

%define list_elem_size 24
%define list_elem_data_offset 0
%define list_elem_next_offset 8
%define list_elem_prev_offset 16

%define sorter_structSize 32
%define sorter_size_offset 0
%define sorter_sorterFunc_offset 8
%define sorter_cmpFunc_offset 16
%define sorter_slots_offset 24

section .data

global strLen
global strClone
global strCmp
global strConcat
global strDelete
global strPrint
global listNew
global listAddFirst
global listAddLast
global listAdd
global listDelete
global listClone
global listPrint
global sorterNew
global sorterAdd
global sorterRemove
global sorterGetSlot
global sorterGetConcatSlot
global sorterCleanSlot
global sorterDelete
global sorterPrint
global fs_sizeModFive
global fs_firstChar
global fs_bitSplit

extern fprintf
extern free
extern malloc
extern listRemove

section .rodata

stringPrintFormat: db '%s', 0
nullString: db 'NULL',0
openBrFormat: db '[', 0
closeBrFormat: db ']', 0
commaFormat: db ',', 0
pointerFormat: db '%p', 0
sorterIndexFormat: db '%d = ', 0
newLineFormat: db 10, 0

section .text
	;*** String ***

strClone:																; R13 = 5   !  RCX = 4
	;ARIDAD: char* strClone(char* pString) 								; R12 -> ! H ! O ! L ! A ! x !
	;RDI: pString														; R8 ->  ! - ! - ! - ! - ! x !
	push rbp															;		 !+0 !+1 !+2 !+3 !+4 !			
	mov rbp, rsp
	push r12
	push r13
	mov r12, rdi; !!  R12: pString    !!
	call strLen
	shl rax, 4
	shr rax, 4
	mov rdi, rax
	inc rdi
	mov r13, rdi;  !! R13; length(pString) + 1
	call malloc; En RAX tengo el nuevo puntero
	mov rcx, r13
	.strCloneLoop:
		mov r9b, byte [r12 + rcx - 1]
		mov byte [rax + rcx - 1], r9b
		loop .strCloneLoop
	pop r13
	pop r12
	pop rbp
	ret

strLen:
	;ARIDAD: uint32_t strLen(char* pString)
	;RDI: pString
	mov R8b, byte [RDI]
	xor rax, rax
	.strLenCountLoop:
		cmp R8b, NULL
		je .endStrLen
		inc eax
		mov r8b, byte [rdi + rax]
		jmp .strLenCountLoop
	.endStrLen:
	ret

strCmp:
	;strCmp(char* a, char* b)
	;RDI; a
	;RSI: b
	;ala
	;a
	xor RAX, RAX
	.strCmpLoop:
		cmp byte [RDI], nullTerminator
		je .strCheck1
		cmp byte [RSI], nullTerminator
		je .strCheck2
		mov R8b, byte [RSI]
		cmp byte [RDI], R8b
		jg .strCmpGreater
		jl .strCmpLesser
		inc RDI
		inc RSI
		jmp .strCmpLoop
	jmp .endStrCmp 
	.strCheck1:;TODO pensar mejor nombre para esta etiqueta
		cmp byte [RSI], nullTerminator
		jne .strCmpLesser
		jmp .endStrCmp
	.strCheck2:
		;cmp byte [RDI], nullTerminator
		jne .strCmpGreater
		;jmp .endStrCmp
	.strCmpGreater:
		dec RAX
		jmp .endStrCmp
	.strCmpLesser:
		inc RAX
		jmp .endStrCmp
	.endStrCmp:
	ret

strConcat:
	;ARIDAD: char* strConcat(char* a, char* b) a = H O L A x
	;RDI: a
	;RSI: b
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14; R14: length(a)
	push r15; R15: length(b)
	;-----------------
	mov r12, rdi; R12: a
	mov r13, rsi; R13: b

	call strLen
	mov r14, rax
	shl r14, 4
	shr r14, 4

	mov rdi, r13
	call strLen
	mov r15, rax
	shl r15, 4
	shr r15, 4

	lea rdi, [r14 + r15 + 1]
	call malloc

	mov rcx, r14
	cmp rcx, 0
	je .copyB
	.copyALoop:					   	   ; R12 -> ! H ! O ! L ! A ! x !   R14: 4
		mov r8b, byte [r12 + rcx - 1]  ; R13 -> ! H ! I ! x !			R15: 2
		mov byte [rax + rcx - 1], r8b  ; RCX: 3
		loop .copyALoop                ; RAX:   ! H ! O ! L ! A ! _ ! _ ! _ !
	;-----------------
	.copyB:
	lea r9, [rax + r14]
	lea rcx, [r15 + 1]
	.copyBLoop:
		mov r8b, byte [r13 + rcx - 1]
		mov byte [r9 + rcx - 1], r8b
		loop .copyBLoop
	;------------------
	mov r14, rax; guardamos rax, sino se pierde con los calls a free
	;------------------
	mov rdi, r12
	call free
	cmp r12, r13
	je .finStrConcat
	mov rdi, r13
	call free
	;-------------------
	.finStrConcat:
	mov rax, r14
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

strDelete:
	push rbp
	mov rbp, rsp
	call free
	pop rbp
	ret

strPrint:
	;ARIDAD: voidstrPrint(char* a, FILE *pFile)
	;RDI: string
	;RSI: pFile
	push RBP
	mov RBP, RSP
	mov R8, RDI; R8 tiene al string
	xor RAX, RAX
	cmp byte [RDI], nullTerminator
	je .printNull
	.printNormal:
		mov RDI, RSI
		mov RSI, stringPrintFormat
		mov RDX, R8
		jmp .endStrPrint
	.printNull:
		mov RDI, RSI
		;mov RSI, stringPrintFormat
		;mov RDX, nullString
		mov rsi, nullString
			
	.endStrPrint:
		call fprintf
	pop rbp
	ret

;*** List ***

listNew:
	push rbp
	mov rbp, rsp
	;------------
	mov rdi, list_size
	call malloc
	mov qword [rax + list_first_offset], NULL
	mov qword [rax + list_last_offset], NULL
	;------------
	pop rbp
	ret

listAddFirst:
	;ARIDAD: void listAddFirst(list_t* l, void* data)
	;RDI: lista
	;RSI: puntero a data
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	;-----------------
	mov r12, rdi; R12: lista
	mov r13, rsi; R13: puntero a data
	;-----------------
	mov rdi, list_elem_size
	mov r14, [R12 + list_first_offset]; R14: first original
	call malloc
	mov qword [rax + list_elem_prev_offset], NULL
	mov [rax + list_elem_data_offset], r13
	mov [R12 + list_first_offset], rax
	;-----------------
	cmp r14, NULL
	je .addFirstToEmptyList
	;-----------------
	.addFirstToNonEmptyList:
		mov [rax + list_elem_next_offset], r14
		mov [r14 + list_elem_prev_offset], rax
		jmp .finAddFirstList
	;-----------------
	.addFirstToEmptyList:
		mov qword [rax + list_elem_next_offset], NULL
		mov [r12 + list_last_offset], rax
	;-----------------
	.finAddFirstList:
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
		ret

listAddLast:
	;ARIDAD: void listAddLast(list_t* l, void* data)
	;RDI: lista
	;RSI: puntero a data
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	;-----------------
	mov r12, rdi; R12: lista
	mov r13, rsi; R13: puntero a data
	;-----------------
	mov rdi, list_elem_size
	mov r14, [R12 + list_last_offset]; R14: last original
	call malloc
	mov qword [rax + list_elem_next_offset], NULL
	mov [rax + list_elem_data_offset], r13
	mov [R12 + list_last_offset], rax
	;-----------------
	cmp r14, NULL
	je .addLastToEmptyList
	;-----------------
	.addLastToNonEmptyList:
		mov [rax + list_elem_prev_offset], r14
		mov [r14 + list_elem_next_offset], rax
		jmp .finAddLastList
	;-----------------
	.addLastToEmptyList:
		mov qword [rax + list_elem_prev_offset], NULL
		mov [r12 + list_first_offset], rax
	;-----------------
	.finAddLastList:
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
		ret

listAdd:
	;ARIDAD: void listAdd(list_t* l, void* data, funcCmp_t* fc)
	;RDI: lista
	;RSI: data
	;RDX: funcCmp
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8
	;----------------
	mov r12, rdi; R12: lista
	mov r13, rsi; R13: data
	mov r14, rdx; R14: funcCmp
	;----------------
	mov r15, [r12 + list_first_offset]
	.listAddLoop:
		cmp r15, NULL
		je .listAdd_addToBack
		mov rdi, r13
		mov rsi, [r15 + list_elem_data_offset]
		call r14
		cmp rax, 0
		jl .continueWithListAddLoop; data con elemActual_data. Si es >= 0, lo ponemos a la izq de elemento actual
		jmp .addElement
		.continueWithListAddLoop:
			mov r15, [r15 + list_elem_next_offset] 
		jmp .listAddLoop
	.addElement:
		mov rbx, [r15 + list_elem_prev_offset]
		cmp rbx, NULL
		je .listAdd_addToFront
		;En este caso quedó en el medio de dos elementos
		mov rdi, list_elem_size
		call malloc; RAX: Nuevo nodo
		;-------------------------------------
		mov [rax + list_elem_data_offset], r13
		mov [rbx + list_elem_next_offset], rax
		mov [rax + list_elem_prev_offset], rbx
		mov [r15 + list_elem_prev_offset], rax
		mov [rax + list_elem_next_offset], r15
		jmp .endListAdd
	.listAdd_addToFront:
		mov rdi, r12
		mov rsi, r13
		call listAddFirst
		jmp .endListAdd
	.listAdd_addToBack:
		mov rdi, r12
		mov rsi, r13
		call listAddLast
	;----------------
	.endListAdd:
		add rsp, 8
		pop rbx
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
		ret

listClone:
	;ARIDAD: list_t* listClone(list_t* l, funcDup_t* fn)
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	;-----------
	mov r12, rdi; R12: lista
	mov r13, rsi; R13: fn
	;-----------
	call listNew
	mov r14, rax; r14: nuevaLista
	mov r15, [r12 + list_first_offset]
	.loopListCopy:
		cmp r15, NULL
		je .endListClone
		mov rdi, [r15 + list_elem_data_offset]
		call r13; En rax està el clon de la data
		mov rdi, r14
		mov rsi, rax
		call listAddLast
		mov r15, [r15 + list_elem_next_offset]
		jmp .loopListCopy
	;-----------
	.endListClone:
		mov rax, r14
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
		ret

listDelete:
	;ARIDAD: listDelete(list_t* l, funcDelete_t* fd)
	;RDI: list
	;RSI: funcDelete
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	;--------------
	mov r12, rdi; R12: lista
	mov r13, rsi; R13: funcDelete
	;--------------
	mov r14, [RDI + list_first_offset]
	.loopListDelete:
		cmp r14, NULL
		je .endListDelete
		mov r15, [r14 + list_elem_next_offset]
		mov rdi, r14
		mov rsi, r13
		call listDeleteNode
		mov r14, r15
		jmp .loopListDelete
	;--------------
	.endListDelete:
		mov rdi, r12
		call free
	;--------------
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

	listDeleteNode:
	;listDeleteNode(node*, funcDelete* fd)
	;RDI: nodo
	;RSI: funcDelete
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8
	mov rbx, rdi; RBX: nodo
	cmp rsi, NULL 
	je .deleteListNode
	mov rdi, [rbx + list_elem_data_offset]
	call rsi
	.deleteListNode:
		mov rdi, rbx
		call free

	add rsp, 8
	pop rbx
	pop rbp
	ret

listPrint:
	;ARIDAD: void listPrint(list_t* l, FILE *pFile, funcPrint_t* fp)
	;RDI: lista
	;RSI: file
	;RDX: funcPrint
	;fprintf: file format argumentos
	;funcPrint_t: puntero file
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	
	;---------------
	mov r12, rdi; R12: lista
	mov r13, rsi; R13: file
	mov r14, rdx; r14: funcion
	;---------------
	mov rdi, r13
	mov rsi, openBrFormat
	call fprintf

	mov r15, [r12 + list_first_offset]
	;---------------
	cmp r14, NULL
	je .loopListFPrintf
	jmp .loopListPrint
	;---------------
	.loopListPrint:
		cmp r15, NULL
		je .endListPrint
		mov rdi, [r15 + list_elem_data_offset] 
		mov rsi, r13
		call r14
		mov r15, [r15 + list_elem_next_offset]
		cmp r15, NULL
		je .endListPrint
		mov rdi, r13
		mov rsi, commaFormat
		call fprintf
		jmp .loopListPrint
	jmp .endListPrint
	;---------------
	.loopListFPrintf:
		cmp r15, NULL
		je .endListPrint
		inc rbx
		mov rdi, r13 
		mov rsi, pointerFormat
		mov rdx, [r15 + list_elem_data_offset]
		call fprintf
		mov r15, [r15 + list_elem_next_offset]
		cmp r15, NULL
		je .endListPrint
		mov rdi, r13
		mov rsi, commaFormat
		call fprintf
		jmp .loopListFPrintf
	;---------------
	.endListPrint:
	mov rdi, r13
	cmp r12, NULL
	mov rsi, closeBrFormat
	call fprintf
	;---------------	
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

;*** Sorter ***

%define sorter_structSize 32
%define sorter_size_offset 0
%define sorter_sorterFunc_offset 8
%define sorter_cmpFunc_offset 16
%define sorter_slots_offset 24

sorterNew:
	;ARIDAD: sorter_t* sorterNew(uint16_t slots, funcSorter_t* fs, funcCmp_t* fc)
	;DI: slots
	;RSI: fs
	;RDX: funcCmp
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	;--------
	shl rdi, 48
	shr rdi, 48
	xor r13, r13
	mov r12, rdi; R12: slots
	mov r13, rsi; R13: fs
	mov r14, rdx; R14: fc
	;--------
	mov rdi, sorter_structSize
	call malloc
	mov r15, rax; r15: newSorter
	mov [r15 + sorter_size_offset], r12
	mov [r15 + sorter_sorterFunc_offset], r13
	mov [r15 + sorter_cmpFunc_offset], r14
	mov r13, rax
	lea rdi, [8 * r12]
	call malloc
	mov [r15 + sorter_slots_offset], rax 
	;--------
	mov rcx, r12
	.loopSorterNew:
		mov r14, rcx
		call listNew
		mov rcx, r14
		mov rbx, [r15 + sorter_slots_offset]
		mov [rbx + rcx * 8 - 8], rax
		loop .loopSorterNew
	;------------
	mov rax, r13
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

sorterAdd:
	;ARIDAD: void sorterAdd(sorter_t* sorter, void* data)
	;RDI: sorter
	;RSI: data
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	;---------
	mov r12, rdi; R12: sorter
	mov r13, rsi; R13: data
	;---------
	mov rdi, r13
	call [r12 + sorter_sorterFunc_offset]
	;Tengo que hacer EAX mod |sorter|
	mov edx, eax
	shr edx, 16
	shl edx, 16
	div word [r12 + sorter_size_offset]; DX ahora tiene el nro de slot
	xor r14, r14
	mov r14w, dx
	mov r8, [r12 + sorter_slots_offset]
	mov rdi, [r8 + r14 * 8]
	mov rsi, r13
	mov rdx, [r12 + sorter_cmpFunc_offset]
	call listAdd
	;---------
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

sorterRemove:
	;ARIDAD: void sorterAdd(sorter_t* sorter, void* data, funcDelete_t* fd)
	;RDI: sorter
	;RSI: data
	;RDX: fd
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	;---------
	mov r12, rdi; R12: sorter
	mov r13, rsi; R13: data
	mov r14, rdx; R14: fd
	;---------
	mov rdi, r13
	call [r12 + sorter_sorterFunc_offset]
	;Tengo que hacer EAX mod |sorter|
	mov edx, eax
	shr edx, 16
	shl edx, 16
	div word [r12 + sorter_size_offset]; DX ahora tiene el nro de slot
	xor r15, r15
	mov r15w, dx
	mov r8, [r12 + sorter_slots_offset]
	mov rdi, [r8 + r15 * 8]
	mov rsi, r13
	mov rdx, [r12 + sorter_cmpFunc_offset]
	mov rcx, r14
	call listRemove
	;---------
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

sorterGetSlot:
	;ARIDAD: void sorterGetSlot(sorter_t* sorter, uint16_t slot, funcDeleteup_t* fd)
	;RDI: sorter
	;SI: slot
	;RDX: fd
	push rbp
	mov rbp, rsp
	push r12
	push r13
	;-----------
	mov r12, rdi; R12: sorter
	mov r13, rdx; R13: fd
	xor rax, rax
	mov ax, si
	xor rdx, rdx
	div word [r12 + sorter_size_offset]; DX ahora tiene el nro de slot
	mov rdi, [r12 + sorter_slots_offset]
	mov rdi, [rdi + rdx * 8]
	mov rsi, r13
	call listClone ; 
	;-----------
	pop r13
	pop r12
	pop rbp
	ret

%define list_size 16
%define list_first_offset 0
%define list_last_offset 8

%define list_elem_size 24
%define list_elem_data_offset 0
%define list_elem_next_offset 8
%define list_elem_prev_offset 16

sorterGetConcatSlot:
	;ARIDAD: char* sorterGetConcatSlot(sorter_t* sorter, uint16_t slot)
	;RDI: sorter
	;SI: slot
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	;-------------
	mov r12, rdi; R12: sorter
	xor rax, rax
	mov ax, si
	xor rdx, rdx
	div word [r12 + sorter_size_offset]; DX ahora tiene el nro de slot
	mov r13, [r12 + sorter_slots_offset]
	mov r13, [r13 + rdx * 8]; R13 tiene la lista buscada
	;-------------
	mov rdi, 1
	call malloc
	mov byte [rax], 0; Esto me sirve de buffer
	mov r15, rax; R15 tiene al buffer
	mov r14, [r13 + list_first_offset]; R14 nodo actual
	.loopSorterSlotConcat:
		cmp r14, NULL
		je .finSorterSlotConcat
		mov rdi, [r14 + list_elem_data_offset]
		call strClone
		mov rdi, r15
		mov rsi, rax
		call strConcat
		mov r15, rax
		mov r14, [r14 + list_elem_next_offset]
		jmp .loopSorterSlotConcat
	.finSorterSlotConcat:
		mov rax, r15
	;-------------
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

sorterCleanSlot:
	;ARIDAD: void sorterCleanSlot(sorter_t* sorter, uint16_t slot, funcDelete_t* fd)
	;RDI: sorter
	;RSI: slot
	;RDX: fd
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	;-----------
	mov r12, rdi; R12: sorter
	mov r13, rdx; R13: fd
	xor rax, rax
	mov ax, si
	xor rdx, rdx
	div word [r12 + sorter_size_offset]; DX ahora tiene el nro de slot
	mov r14, rdx; R14 tiene numero de slot
	mov rdi, [r12 + sorter_slots_offset]
	mov rdi, [rdi + rdx * 8]
	mov rsi, r13
	call listDelete
	call listNew
	mov rdi, [r12 + sorter_slots_offset]
	mov [rdi + r14 * 8], rax
	;-----------
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

sorterDelete:
	;ARIDAD: void sorterDelete(sorter_t* sorter, funcDelete_t* fd)
	;RDI: sorter
	;RSI: fd
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8
	;------------
	mov r12, rdi; R12: sorter
	mov r13, rsi; R13: fd
	;------------
	mov r14, [r12 + sorter_slots_offset]
	xor r15, r15
	mov r15w, word [r12 + sorter_size_offset]
	xor rbx, rbx
	.loopSorterDeleteLists:
		cmp rbx, r15
		je .endSorterDelete
		mov rdi, [r14 + rbx * 8]
		mov rsi, r13
		call listDelete
		inc rbx
		jmp .loopSorterDeleteLists
	.endSorterDelete:
		mov rdi, [r12 + sorter_slots_offset]
		call free
		mov rdi, r12
		call free
	;------------
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

sorterPrint:
	;ARIDAD: void sorterPrint(sorter_t* sorter, FILE* pFile, funcPrint_t* fp)
	;RDI: sorter
	;RSI: file
	;RDX: fp
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8
	;----------
	mov r12, rdi; R12: sorter
	mov r13, rsi; r13: file
	mov r14, rdx; R14: fp
	;----------
	mov r15w, word [r12 + sorter_size_offset]
	xor rbx, rbx
	.loopSorterPrint:
		cmp bx, r15w
		je .finSorterPrint
		mov rdi, r13
		mov rsi, sorterIndexFormat
		mov rdx, rbx
		call fprintf
		mov rdi, [r12 + sorter_slots_offset];lista
		mov rdi, [rdi + rbx * 8]
		mov rsi, r13;file
		mov rdx, r14;fp
		call listPrint
		mov rdi, r13
		mov rsi, newLineFormat
		call fprintf
		inc rbx 
		jmp .loopSorterPrint
	;----------
	.finSorterPrint:
	;----------
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

;*** aux Functions ***

fs_sizeModFive:
	;ARIDAD: uint16_t fs_sizeModFive(char* s)
	;RDI: string
	push rbp
	mov rbp, rsp
	;--------
	call strLen
	mov edx, eax
	shr edx, 16
	shl edx, 16
	mov r8, 5
	div r8w
	xor rax, rax
	mov ax, dx
	;--------
	pop rbp
	ret

fs_firstChar:
	;ARIDAD uint16_t fs_firstChar(char* s)
	; RDI: string
	;-----------
	xor rax, rax ; Limpio registro
	;Consigo el primer valor, sea nulo o no
	mov AL , byte [rdi]
	;-----------
	ret


fs_bitSplit:
	push rbp
	mov rbp, rsp
	push rbx
	;-----------
	xor ax,ax
	xor r8, r8
	xor r9, r9   
	mov bl,2
	mov byte al, [rdi]
	mov r9b, al 
	cmp al, 0
	je  poner8

	mov r8, 1
	xor cx, cx ; Se usa para ver si es potencia de 2 cual es.

	verBiti:
	div bl
	cmp ah,0
	jne ponerBiti
	inc cx
	shl r8, 1
	jmp verBiti

	poner8:
	mov ax, 8
	jmp fs_bitSplitEnd

	poner9:
	mov ax,9
	jmp fs_bitSplitEnd

	ponerBiti:
	cmp r8, r9
	jne poner9
	mov ax,cx 

	fs_bitSplitEnd:
	;-----------
	pop rbx
	pop rbp
	ret