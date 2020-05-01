%define NULL 0

%define nullTerminator 0

%define list_size 16
%define list_first_offset 0
%define list_last_offset 8

%define list_elem_size 24
%define list_elem_data_offset 0
%define list_elem_next_offset 8
%define list_elem_prev_offset 16

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

section .rodata

stringPrintFormat: db '%s', 0
nullString: db 'NULL'
openBrFormat: db '[', 0
closeBrFormat: db ']', 0
commaFormat: db ',', 0
pointerFormat: db '%p', 0

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
	xor RAX, RAX
	.strCmpLoop:
		cmp byte [RDI], nullTerminator
		je .strCheck
		mov R8b, byte [RSI]
		cmp byte [RDI], R8b
		jg .strCmpGreater
		jl .strCmpLesser
		inc RDI
		inc RSI
		jmp .strCmpLoop
	jmp .endStrCmp 
	.strCheck:;TODO pensar mejor nombre para esta etiqueta
		cmp byte [RSI], nullTerminator
		jne .strCmpLesser
		jmp .endStrCmp
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
		mov RSI, stringPrintFormat
		mov RDX, nullString
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

listPrint:;
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

sorterNew:
ret
sorterAdd:
ret
sorterRemove:
ret
sorterGetSlot:
ret
sorterGetConcatSlot:
ret
sorterCleanSlot:
ret
sorterDelete:
ret
sorterPrint:
ret

;*** aux Functions ***

fs_sizeModFive:
ret
fs_firstChar:
ret
fs_bitSplit:
ret

