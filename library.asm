; OPEN FILE MACRO
open_file macro	file, filename, mode; deschidem fisierul
	push eax
	push mode ; punem pe stiva modul de deschidere
	push filename ; punem pe stiva numele fisierului
	call fopen ; apelam functia
	add esp, 8 ; curatam stiva
	mov file, eax ; punem pointerul spre fisier in list_file
	pop eax
endm
; CLOSE FILE MACRO
close_file macro file ; inchidem fisierul
	push file
	call fclose
	add esp, 4
endm
; AFISARE MESAJE
afisare1 macro param
	push param
	call printf
	add esp, 4
endm
; AFISARE CU FORMAT
afisare2 macro param1, param2
	push param2
	push param1
	call printf
	add esp, 8
endm
; CITIRE CONSOLA
citire macro param1, param2
	push param2
	push param1
	call scanf
	add esp, 8
endm
; SCRIERE IN FISIER
afisare_file macro param1, param2, param3
	push param3
	push param2
	push param1
	call fprintf
	add esp, 12
endm