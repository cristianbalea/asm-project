.386
.model flat, stdcall

includelib msvcrt.lib
include library.asm

extern exit: proc
extern printf: proc
extern fopen: proc
extern fclose: proc
extern scanf: proc
extern fscanf: proc
extern fprintf: proc
extern strlen: proc

public start

.data
meniu1 DB ">> Introduceti calea spre fisier: ", 10, 13, 0
meniu2 DB ">> Introduceti numarul corespunzator unei operatii: ",10,13,
			">> 1. findc    2. find    3. replace    4. toUpper", 10, 13, 
			">> 5. toLower    6. toSentence    7. list    8. exit", 10, 13, 0
op DB 10,13,10,13,">> Operatia: (1.findc, 2.find, 3.replace, 4.toUpper, 5.toLower, 6.toSentence, 7.list, 8.exit)",10,13,"> ",0
filename DB 20 dup(0)
format_string DB "%s", 0
format_int DB "%d", 0
format_int_space DB "%d ", 0
format_char DB "%c", 0
operatie DB 0
file DD 0
file2 DD 0
mode_read DB "r", 0
mode_write DB "w", 0
char DD 0
char_to_find DD 0
mesaj1_findc DB ">> Introduceti caracterul de cautat:",0
mesaj2_findc DB ">> Aparitii:",0
mesaj1_find DB ">> Introduceti sirul de cautat:", 0
mesaj2_find DB ">> Aparitii la index:", 0
mesaj1_replace DB ">> Introduceti sirul de inlocuit:", 0
mesaj2_replace DB ">> Introduceti sirul cu care se inlocuieste:", 0
sir DB 400 dup(0)
lung DD 0
char2 DB "a", 0
sir2 DB 400 dup(0)
sir3 DB 400 dup(0)
lung2 DD 0
str_old DB 100 dup(0)
str_new DB 100 dup(0)
lung_old DD 0
lung_new DD 0
.code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; salvez continutul din fisier in memorie
save proc
	push ebp
	mov ebp, esp
	xor esi, esi
	bucla_citire:
		push offset char2 ; pun pe stiva variabila char
		push offset format_char ; pun pe stiva formatul de citire
		push file ; pun pe stiva pointerul la fisier
		call fscanf ; apelez functia
		add esp, 12 ; curat stiva
		
		cmp eax, -1 ; fscanf returneaza -1 la eof
		je end_of_file ; daca e -1, iesim din bucla de citire
		
		xor eax, eax ; punem in esi
		mov al, char2
		mov sir[esi], al
		inc esi
	jmp bucla_citire
	end_of_file:
	mov esp, ebp
	pop ebp
	ret
save endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; numar aparitiile unui caracter 
findc macro
local bucla_citire, not_equal, outt
	afisare1 offset mesaj1_findc
	
	citire offset format_char, offset char_to_find
	citire offset format_char, offset char_to_find

	xor ebx, ebx ; curatam ebx
	mov ebx, char_to_find ; punem in ebx caracterul de gasit
	xor ebp, ebp ; in ebp contorizam numarul de aparitii al lui char_to_find
	xor esi, esi
	bucla_citire:
		cmp sir[esi], bl
		jne not_equal ; daca e egal incrementam ebp, altfel nu
		inc ebp
		not_equal:
		inc esi
		cmp sir[esi], 0
		je outt
	jmp bucla_citire
	outt:
	;afisam numarul de aparitii
	afisare1 offset mesaj2_findc

	afisare2 offset format_int, ebp
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; parcurg sirul, daca e litera mica o fac mare
; modific in sir, dupa care scriu in fisier
toUpper macro sir, lung
local bucla, next, outt
	mov ebp, lung
	xor esi, esi
	bucla: 
		xor eax, eax
		mov al, sir[esi]
		cmp al, 'a'
		jb next
		cmp al, 'z'
		jg next
		; ajunge aici daca e litera mica
		sub eax, 32
		next:
		mov sir[esi], al
		
		dec ebp
		cmp ebp, 0
		je outt
		inc esi
	jmp bucla
	outt:
	;sirul modificat il scriu in fisier
	open_file file, offset filename, offset mode_write	
	afisare_file file, offset format_string, offset sir 
	close_file file
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; parcurg sirul, daca e litera mare o fac mica
; modific in sir, dupa care scriu in fisier
toLower macro sir, lung
local bucla, next, outt
	mov ebp, lung ; 
	xor esi, esi ; parcurg sirul
	bucla: 
		xor eax, eax
		mov al, sir[esi]
		cmp al, 'A'
		jb next
		cmp al, 'Z'
		jg next
		;ajunge aici daca e litera mare
		add eax, 32
		next:
		mov sir[esi], al
		
		dec ebp
		cmp ebp, 0
		je outt
		inc esi
	jmp bucla
	outt:

	open_file file, offset filename, offset mode_write
	afisare_file file, offset format_string, offset sir
	close_file file
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
find macro sir1, lung1
local bucla_parcurgere_sir, bucla_parcurgere_text, outt, notequal
	;citesc sirul 2 si ii calculez lungimea
	afisare1 offset mesaj1_find
	citire offset format_string, offset sir2
	
	push offset sir2
	call strlen
	add esp, 4
	
	mov lung2, eax
	
	afisare1 offset mesaj2_find
	
	;parcurg sirul 1, de la fiecare indice compar cu sirul 2
	mov ecx, lung1
	xor esi, esi
	
	bucla_parcurgere_text:
		xor ebp, ebp
		xor edi, edi
		xor eax, eax
		
		mov ecx, lung2
		
		bucla_parcurgere_sir:
			mov al, sir1[esi]
			cmp al, sir2[edi]
			jne notequal
			inc esi
			inc edi
		loop bucla_parcurgere_sir
		
		; sirul se potriveste, calculez pozitia de la care incepe
		mov ebp, esi
		sub ebp, lung2
		
		afisare2 offset format_int_space, ebp
		
		notequal:
		; sirul nu se potriveste
		cmp sir1[esi], 0
		je outt
		
		inc ebp
		inc esi
	jmp bucla_parcurgere_text
	
	outt:
	
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

toSentence macro sir, lung
local bucla, litera, next, outt, sau, sau2, semn
	toLower sir, lung
	mov ebp, lung
	xor esi, esi
	xor edi, edi
	xor eax, eax
	mov al, sir[esi]
	sub eax, 32
	mov sir[esi], al
	bucla: 
		xor eax, eax
		mov al, sir[esi]
		; verific daca e . sau ? sau !
		cmp al, '.'
		je semn
		jne sau
		
		sau:
		cmp al, '!'
		je semn
		jne sau2
		
		sau2:
		cmp al, '?'
		jne litera
		;daca e aici e . ? !
		semn:
		mov edi, 1 ; daca e semn, marcam inceputul propozitiei, edi <= 1
		jmp next
		
		litera: 
		;daca e litera, verificam daca e mica
		cmp al, 'a'
		jb next
		cmp al, 'z'
		jg next
		;daca e litera mica, verificam daca avem inceput de propozitie
		cmp edi, 0
		je next
		;daca avem inceput de propozitie, facem litera mare si ii dam lui edi inapoi valoarea 0
		sub eax, 32
		mov edi, 0
		
		next:
		mov sir[esi], al
		dec ebp
		cmp ebp, 0
		je outt
		inc esi
	jmp bucla
	outt:
	
	;deschid fisierul
	open_file file, offset filename, offset mode_write
	afisare_file file, offset format_string, offset sir
	;inchid fisierul
	close_file file
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; replace
replace macro sir, lung
local bucla, parcurgere_subsir, not_old, done, outt, copy, clear, clear2
	
	afisare1 offset mesaj1_replace
	citire offset format_string, offset str_old
	
	afisare1 offset mesaj2_replace
	citire offset format_string, offset str_new
	
	push offset str_old
	call strlen
	add esp, 4
	mov lung_old, eax
	
	push offset str_new
	call strlen
	add esp, 4
	mov lung_new, eax
	
	mov ecx, 300
	xor esi, esi
	; curat sirul sir3
	clear:
		xor eax, eax
		mov sir3[esi], al
		inc esi
	loop clear
	
	xor ebp, ebp ; cu ebp parcurg sir3, cel in care modific
	xor esi, esi ; cu esi parcurg sirul initial
	bucla:
		xor edi, edi
		xor eax, eax
		
		mov ecx, lung_old
		;parcurgem de la fiecare indice din sirul initial pt a verifica daca gasim str_old
		parcurgere_subsir:
			xor eax, eax
			mov al, str_old[edi]
			cmp al, sir[esi]
			jne not_old
			inc esi
			inc edi
		loop parcurgere_subsir
		
		; pun sirul cu care se inlocuieste, str_new, in sir3
		xor edx, edx
		mov ecx, lung_new
		new:
			xor eax, eax
			mov al, str_new[edx]
			mov sir3[ebp], al
			inc edx
			inc ebp
		loop new
		
		jmp done

		; daca nu se potriveste str_old cu subsirul de la indicele esi
		; pun caracterul de la pozitia esi in sir3
	not_old:
		sub esi, edi
		xor eax, eax
		mov al, sir[esi]			
		mov sir3[ebp], al
		inc esi
		inc ebp
		
		done:
		
		cmp sir[esi], 0
		je outt	
	jmp bucla
	
	outt:
	
	mov ecx, 300
	xor esi, esi
	; curat sirul sir
	clear2:
		xor eax, eax
		mov sir[esi], al
		inc esi
	loop clear2
	
	open_file file, offset filename, offset mode_write
	afisare_file file, offset format_string, offset sir3
	close_file file
	
	push offset sir3
	call strlen
	add esp, 4
	
	mov ecx, eax
	xor esi, esi
	xor edi, edi
	
	copy:
		xor eax, eax
		mov al, sir3[esi]
		mov sir[edi], al
		inc esi
		inc edi
	loop copy
	
	xor eax, eax
	mov sir[edi], al
	
	push offset sir
	call strlen
	add esp, 4
	
	mov lung, eax
	
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main macro 
local program, findc_, find_, replace_, toUpper_, toLower_, toSentence_, list_, exit_
	;afisez meniurile, citesc calea spre fisier
	afisare1 offset meniu1 
	citire offset format_string, offset filename
	afisare1 offset meniu2

	;salvez continutul din fisier pentru a-l modifica
	open_file file, offset filename, offset mode_read		
	call save
	close_file file
	
	push offset sir
	call strlen
	add esp, 4
	mov lung, eax
	
	program:
		afisare1 offset op
		citire offset format_int, offset operatie
	
		cmp operatie, 1
		je  findc_
		cmp operatie, 2
		je find_
		cmp operatie, 3
		je replace_
		cmp operatie, 4
		je toUpper_
		cmp operatie, 5
		je toLower_
		cmp operatie, 6
		je toSentence_
		cmp operatie, 7
		je list_
		cmp operatie, 8
		je exit_
		
		list_:
			afisare2 offset format_string, offset sir
			jmp program
		findc_: 
			findc
			jmp program
		toUpper_:
			toUpper sir, lung
			jmp program
		toLower_:
			toLower sir, lung
			jmp program
		find_:
			find sir, lung
			jmp program
		toSentence_:
			toSentence sir, lung
			jmp program
		replace_:
			replace sir, lung
			jmp program
		
	jmp program
	exit_:
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start:
	main
	push 0
	call exit
end start