%define NULL 0
%define nullTerminator 0

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
	;ARIDAD: char* strConcat(char* a, char* b)
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
	mov rax, r14
	;-------------------
	.finStrConcat:
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
ret
listAddFirst:
ret
listAddLast:
ret
listAdd:
ret
listClone:
ret
listDelete:
ret
listPrint:
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

