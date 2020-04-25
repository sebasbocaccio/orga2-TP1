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

section .rodata

stringPrintFormat: db '%s', 0
nullString: db 'NULL'

section .text

;*** String ***

strClone:
	;*** Necesitamos Malloc ***
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
	;*** Necesitamos Malloc ***
	ret

strDelete:
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

