
; ESTUDIANTE
	global estudianteCrear
	global estudianteBorrar
	global menorEstudiante
	global estudianteConFormato
	global estudianteImprimir
	
; ALTALISTA y NODO
	global nodoCrear
	global nodoBorrar
	global altaListaCrear
	global altaListaBorrar
	global altaListaImprimir

; AVANZADAS
	global edadMedia
	global insertarOrdenado
	global filtrarAltaLista

; YA IMPLEMENTADAS EN C
	extern string_iguales
	extern insertarAtras
	extern malloc
	extern free
	extern fopen
	extern fclose
	extern fprintf

;FUNCIONES AUXILIARES
	global string_longitud
	global string_menor
	global string_copiar
	global nodoEliminar

; /** DEFINES **/    >> SE RECOMIENDA COMPLETAR LOS DEFINES CON LOS VALORES CORRECTOS
	%define NULL 	0
	%define TRUE 	1
	%define FALSE 	0

	%define ALTALISTA_SIZE     		16
	%define OFFSET_PRIMERO 			0
	%define OFFSET_ULTIMO  			8

	%define NODO_SIZE     			24
	%define OFFSET_SIGUIENTE   		0
	%define OFFSET_ANTERIOR   		8
	%define OFFSET_DATO 			16

	%define ESTUDIANTE_SIZE  		20
	%define OFFSET_NOMBRE 			0
	%define OFFSET_GRUPO  			8
	%define OFFSET_EDAD 			16

section .rodata


section .data
	msg db '%s',10,9,'%s',10,9,'%u',10,0
	msg1 db 'a', 0
	msg2 db '<vacia>',10,0

section .text

;/** FUNCIONES OBLIGATORIAS DE ESTUDIANTE **/    >> PUEDEN CREAR LAS FUNCIONES AUXILIARES QUE CREAN CONVENIENTES
;---------------------------------------------------------------------------------------------------------------

	; estudiante *estudianteCrear( char *nombre, char *grupo, unsigned int edad );
	estudianteCrear:
		; COMPLETAR AQUI EL CODIGO
		; rdi, rsi, rdx parametros 
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14 ;pila alineada

		mov rbx, rdi ;backup
		mov r12, rsi ;backup
		sub r13,r13 ; limpio r13
		mov r13d, edx ;backup del int en r13 limpio
		mov rdi, ESTUDIANTE_SIZE
		call malloc ;tengo en rax la direccion del alumno
		mov r14, rax
		mov rdi, rbx
		call string_copiar ; tengo en rax la direccion de la copia
		mov [r14 + OFFSET_NOMBRE], rax
		mov rdi, r12
		call string_copiar ;tengo en rax la direccion de la copia
		mov [r14 + OFFSET_GRUPO], rax
		mov [r14 + OFFSET_EDAD], r13d ; muevo la mitad de r13
		mov rax, r14
		pop r14  
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret


	; void estudianteBorrar( estudiante *e );
	estudianteBorrar:
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp, rsp
		push rbx
		sub rsp, 8; pila alineada
		mov rbx, rdi ; backup estudiante
		mov rdi, [rbx + OFFSET_NOMBRE] ;preparo liberar nombre
		call free
		mov rdi, [rbx + OFFSET_GRUPO] ; preparo liberar grupo
		call free
		mov rdi,rbx ;preparo para liberar todo el estudiante
		call free
		add rsp,8
		pop rbx
		pop rbp
		ret


	; bool menorEstudiante( estudiante *e1, estudiante *e2 ){
	menorEstudiante:
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp, rsp
		push rbx
		push r12 ;pila alineada

		mov rbx, rdi;backup
		mov r12, rsi;backup
		mov rdi, [rbx+OFFSET_NOMBRE];pongo los nombres 1
		mov rsi, [r12+OFFSET_NOMBRE];pongo los nombres 2
		call string_menor
		cmp rax, TRUE
		jne check_iguales
		jmp terminar ;rax es TRUE y son menores los nombres
		check_iguales:
			mov rdi, [rbx+OFFSET_NOMBRE];pongo los nombres 1
			mov rsi, [r12+OFFSET_NOMBRE];pongo los nombres 2
			call string_iguales
			cmp rax, TRUE
			jne terminar ; no es menor y tampoco es igual termino rax es FALSE
			xor rdi,rdi ; los limpio
			xor rsi,rsi ; los limpio
			mov edi, dword [rbx+OFFSET_EDAD] ; coloco las edades
			mov esi, dword [r12+OFFSET_EDAD] ;coloco las edades
			cmp rdi,rsi
			jle terminar  ; no es menor el nombre pues es igual y la edad1 es menor que la edad2 rax es TRUE
			mov rax, FALSE
			jmp terminar ;rax es FALSE y la edad1 es mayor que edad2
		terminar:
			pop r12
			pop rbx
			pop rbp
			ret




	; void estudianteConFormato( estudiante *e, tipoFuncionModificarString f )
	estudianteConFormato:
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp, rsp
		push rbx
		push r12 ; pila alineada

		mov rbx, rdi ;backup parametros
		mov r12, rsi ;backup parametros
		mov rdi, [rbx + OFFSET_NOMBRE]
		call r12
		mov rdi, [rbx + OFFSET_GRUPO]
		call r12
		pop r12
		pop rbx
		pop rbp
		ret

	; void estudianteImprimir( estudiante *e, FILE *file )
	estudianteImprimir:
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp, rsp 
		push rbx
		sub rsp,8 ;pila alineada

		mov rbx, rdi ;backup estudiante
		mov rdi, rsi ;muevo el file* a rdi./
		mov rsi, msg ; en rsi pongo el formato
		mov rdx, [rbx + OFFSET_NOMBRE] ;puntero string nombre
		mov rcx, [rbx + OFFSET_GRUPO] ;puntero string grupo
		sub r8,r8
		mov r8d, dword [rbx + OFFSET_EDAD] ;muevo solo 4 bytes ??? los que quiero????
		call fprintf

		add rsp, 8
		pop rbx
		pop rbp
		ret

;/** FUNCIONES DE ALTALISTA Y NODO **/    >> PUEDEN CREAR LAS FUNCIONES AUXILIARES QUE CREAN CONVENIENTES
;--------------------------------------------------------------------------------------------------------

	; nodo *nodoCrear( void *dato )
	nodoCrear:
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp,rsp
		push rbx
		sub rsp, 8 ; pila alineada

		mov rbx, rdi;backup dato
		mov rdi, NODO_SIZE
		call malloc ; en rax esta el nodo
		mov qword [rax + OFFSET_SIGUIENTE],NULL
		mov qword [rax + OFFSET_ANTERIOR],NULL
		mov [rax + OFFSET_DATO], rbx

		add rsp,8
		pop rbx
		pop rbp
		ret 

	; void nodoBorrar( nodo *n, tipoFuncionBorrarDato f )
	nodoBorrar:
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp, rsp
		push rbx 
		sub rsp, 8	 ; pila alineada

		mov rbx, rdi ; puntero al nodo en rbx
		mov rdi, [rbx + OFFSET_DATO] ; coloco el dato en rdi
		call rsi ; llamada a la funcion borrar dato
		mov rdi, rbx ;coloco el nodo en rdi
		call free ; libero el nodo

		add rsp, 8
		pop rbx
		pop rbp
		ret

	; altaLista *altaListaCrear( void )
	altaListaCrear:
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp, rsp 
		mov rdi, ALTALISTA_SIZE
		call malloc ; en rax tengo la altaLista
		mov qword [rax + OFFSET_PRIMERO], NULL
		mov qword [rax + OFFSET_ULTIMO],NULL
		pop rbp
		ret


	; void altaListaBorrar( altaLista *l, tipoFuncionBorrarDato f )
	altaListaBorrar:
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		sub rsp, 8 ; pila alineada

		mov rbx, rdi ; direccion de la lista
		mov r12, rsi ; direccion de la funcion
		cmp qword [rbx + OFFSET_PRIMERO], NULL
		je finalizar ; desde ahora no esta vacia
		mov r13, [rbx + OFFSET_PRIMERO] ; muevo la direccion del primero
		lap: 
			cmp r13, NULL ; me fijo si r13 es NULL
			je finalizar 
			mov rdi, r13 ; muevo el nodo a rdi
			mov rsi, r12 ; muevo la funcion a rsi
			mov r13, [r13 + OFFSET_SIGUIENTE];muevo a r13 el nodo->siguiente
			call nodoBorrar ; borre el nodo
			jmp lap
		finalizar:
			mov rdi, rbx
			call free

			add rsp, 8
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret

	; void altaListaImprimir( altaLista *l, char *archivo, tipoFuncionImprimirDato f )
	altaListaImprimir:
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14; pila alineada

		;llamandoFopen:
			mov rbx, rdi ; direccion de la lista
			mov r12, rdx ; direccion de la funcion
			mov r14, rsi ; direccion archivo
			mov rdi, r14
			mov rsi, msg1 ; muevo el modo de operacion
			call fopen ; ya no me importa la direccion del archivo
		
		mov r14, rax ; direccion de FILE
		
		cmp qword [rbx + OFFSET_PRIMERO], NULL
		je imprimir_Vacia ; desde ahora no esta vacia
		mov r13, [rbx + OFFSET_PRIMERO] ; muevo la direccion del primer nodo
		lup: 
			cmp r13, NULL ; me fijo si r13 es NULL
			je final 
			mov rdi, [r13 + OFFSET_DATO] ; muevo el dato a rdi
			mov rsi, r14 ; muevo el file a rsi
			call r12; llamo a la funcion q imprime el dato
			mov r13, [r13 + OFFSET_SIGUIENTE];muevo a r13 el nodo->siguiente
			jmp lup
		
		imprimir_Vacia:
			mov rdi, r14 ; muevo el file 
			mov rsi, msg2 ; muevo el msg2
			call fprintf

		final:

			;llamandoFclose:
				mov rdi, r14 ;muevo el file a rdi
				call fclose

			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret





;/** FUNCIONES AVANZADAS **/    >> PUEDEN CREAR LAS FUNCIONES AUXILIARES QUE CREAN CONVENIENTES
;----------------------------------------------------------------------------------------------

	; float edadMedia( altaLista *l )
	edadMedia:
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp, rsp
		mov r10, rdi ; tengo la lista 
		mov qword rsi, [r10 + OFFSET_PRIMERO] ;tengo el puntero a primero
		cmp qword rsi, NULL 
		je devolver0
		sub rcx, rcx ; este va a ser mi contador 
		sub rdx, rdx ; este va a ser acumulador
		ciclar:
			cmp qword rsi, NULL
			je dividir;
			inc rcx
			mov r9, [rsi + OFFSET_DATO ]
			add edx, dword [r9 + OFFSET_EDAD]
			mov rsi, [rsi + OFFSET_SIGUIENTE]
			jmp ciclar

		dividir: 
		;codigo en rcx tengo contador rdx acumulador
		cvtsi2ss xmm0, edx
		cvtsi2ss xmm1, ecx
		divss xmm0, xmm1 
		jmp term	


		devolver0:
			pxor xmm0, xmm0
		; devolver float 0 


		term:

			pop rbp 
			ret 

	; void insertarOrdenado( altaLista *l, void *dato, tipoFuncionCompararDato f )
	insertarOrdenado:
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp, rsi 
		push rbx 
		push r12
		push r13
		push r14 ; pila alineada

		mov rbx, rdi ; backup lista
		mov r12, rsi ; backup dato
		mov r13, rdx ; backup funcion
		;caso vacio
		mov rdi, [rbx + OFFSET_PRIMERO] ; muevo a rdi el primer nodo
		cmp qword rdi, NULL
		je llamaIAtras
		;caso menor que el primero
		mov rsi, [rdi + OFFSET_DATO] ; muevo a rsi el dato del primer nodo 
		mov rdi, r12 ; muevo el dato que me pasaron a rdi
		call r13
		cmp qword rax, TRUE
		je insertarPrim
		;caso mayor al ultimo
		mov rdi, r12 ;dato pasado
		mov rsi, [rbx + OFFSET_ULTIMO]
		mov rsi, [rsi + OFFSET_DATO]; dato del ultimo
		call r13
		cmp qword rax, TRUE
		jne llamaIAtras
		; caso lo coloco en algun lugar del medio
		mov r14, [rbx + OFFSET_PRIMERO] ; coloco el nodo primero 

		ccl: 
			mov rdi, r12 ;muevo el dato
			mov rsi, [r14 + OFFSET_DATO]
			call r13
			cmp rax,TRUE
			je insertMed
			mov r14, [r14 + OFFSET_SIGUIENTE]
			jmp ccl
		
		insertMed:
			mov rdi, r12 ; muevo el dato
			call nodoCrear ;tengo en rax el nodo
			mov rsi, [r14 + OFFSET_ANTERIOR] 
			mov  [rsi + OFFSET_SIGUIENTE],rax 
			mov  [rax + OFFSET_ANTERIOR],rsi
			mov  [rax + OFFSET_SIGUIENTE],r14
			mov  [r14 + OFFSET_ANTERIOR], rax
			jmp trm
		llamaIAtras:
			mov rdi, rbx
			mov rsi, r12
			call insertarAtras
			jmp trm
		insertarPrim:
			mov rdi, r12 ; muevo el dato
			call nodoCrear ;tengo en rax el nodo
			mov rsi,[rbx + OFFSET_PRIMERO] ;tengo el nodo primero
			mov [rbx + OFFSET_PRIMERO],rax ; lo hice primero
			mov qword [rax + OFFSET_ANTERIOR], NULL
			mov [rax + OFFSET_SIGUIENTE], rsi ;nodo seteado
			mov [rsi + OFFSET_ANTERIOR], rax
		trm:
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret

	; void filtrarAltaLista( altaLista *l, tipoFuncionCompararDato f, void *datoCmp )
	filtrarAltaLista:
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp, rsp 
		push rbx
		push r12
		push r13
		push r14 ; pila alineada
		push r15
		sub rsp, 8

		mov rbx, [rdi + OFFSET_PRIMERO] ; pongo el primero en la en rbx
		mov r12, rsi ;backup funcion
		mov r13, rdx ;backup dato
		mov r14, rdi ; backup lista
		cmp qword rbx, NULL
		je .fin
	
		.ciclo: ; me dijeron q asi es la posta cuando se me acababan las etiquetas
			cmp qword rbx, NULL
			je .fin
			;comparo
			mov r15, [rbx + OFFSET_SIGUIENTE]
			mov rsi, r13;muevo el dato pasado a rdi
			mov rdi, [rbx + OFFSET_DATO] ;muevo el dato  del nodo a rsi
			call r12 ;llamo a la funcion
			cmp rax, TRUE
			je .avanzar ;si la comparacion es verdad el dato queda
			;si no elimino
			mov rdi, r14 ; coloco la lista
			mov rsi, rbx ; coloco el nodo
			call nodoEliminar
			.avanzar :
				mov rbx,r15
			jmp .ciclo
		.fin:
			add rsp, 8
			pop r15
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret


; FUNCIONES AUXILIARES
	;void nodoEliminar(altaLista * l, nodo *n,)
	nodoEliminar:
	push rbp
	mov rbp, rsp
	push rbx
	push r12 ; pila alineada

	mov rbx, rdi ; direccion lista
	mov r12, rsi ; nodo 

	mov rdi, [rbx + OFFSET_PRIMERO] 
	cmp qword rdi, NULL ; veo si esta vacia
	je termnr

	cmp rdi, r12 ; veo si es el primero 
	je brPrim

	mov rdi, [rbx + OFFSET_ULTIMO] ; veo si es el ultimo
	cmp rdi, r12
	je brUlt ; tengo en rdi el ultimo

	mov rcx, [r12 + OFFSET_ANTERIOR] ; pongo el anterior al nodo
	mov rdx, [r12 + OFFSET_SIGUIENTE] ; pongo el siguiente al nodo
	mov [rcx + OFFSET_SIGUIENTE], rdx
	mov [rdx + OFFSET_ANTERIOR], rcx ; desconecto el nodo
	jmp termnr ; falta borrar el nodo y pushear registros

	brUlt:
		mov rsi, [r12 + OFFSET_ANTERIOR] ; pongo el anterior en rsi
		mov [rbx + OFFSET_ULTIMO], rsi ; ahora el ultimo es el anterior
		mov qword [rsi + OFFSET_SIGUIENTE], NULL ; ahora el anterior siguiente apunta a null
		jmp termnr

	brPrim:

		mov rsi, [r12 + OFFSET_SIGUIENTE] ; pongo el siguiente en rsi
		mov [rbx + OFFSET_PRIMERO], rsi ; ahora el primero es el siguiente
		cmp qword rsi, NULL
		je .esUnico
		mov qword [rsi + OFFSET_ANTERIOR], NULL ;ahora su anterior apunta a null
		mov rsi, [rbx + OFFSET_ULTIMO] ; pongo el ultimo de la lista en rsi
		cmp rsi, r12 ;me fijo si es igual al ultimo tmb (-> es el unico)
		jne termnr
		.esUnico:
		mov qword [rbx + OFFSET_ULTIMO], NULL
	termnr:

		mov rdi, r12
		mov rsi, estudianteBorrar ; esto no se que onda filtrar lista no me pasa una funcion borrar dato
		call nodoBorrar
		pop r12
		pop rbx
		pop rbp
		ret






	;unsigned char string_longitud( char *s )
	string_longitud:
		;recibo parametro en rdi
		push rbp; pila alineada

		mov rbp, rsp
		sub	rcx, rcx ; limpio rcx
		sub	al, al ; limpio al, aca va el caracter buscado, en este caso 0
		not	rcx ; ahora rcx es -1 (uso esto para que sea infinito el ciclo)
		cld ;limpio el flag direccion para q vaya de iza a derecha
		repne	scasb ;repito mientras el byte no sea igual
		not	ecx ; se ejecuto el ciclo longitud + 1 veces pero empezo con menos 1 asi que tengo - (longitud + 2) al negarlo y no sumarle nada le estoy restando 1 
				; puesto que en complemento a dos tengo que negar y sumar 1 para la conversion
		dec	ecx ; le resto el 1 que falta y ahora tengo la longitud
		xor rax,rax
		mov eax,ecx

		pop rbp
		ret  

		;este codigo lo encontre, entendi y modifique tratando de entender el uso de scasb me parecio una forma inteligente de hacerlo.

	;char *string_copiar( char *s )
	string_copiar:
		
		push rbp 
		mov rbp, rsp 
		push rbx
		push r12
		push r13
		sub rsp,8 ; pila alineada

		mov rbx, rdi ;rbx tiene el puntero al string
		call string_longitud
		mov r12, rax ; r12 tiene la longitud
		mov rdi, r12
		inc rdi
		call malloc
		mov r13, rax ; r13 tiene el puntero al string copia
		mov rcx, r12 ; preparo para el loop 
		inc rcx ; creo que asi copia el 0
		mov rdi, r13 ; mueve hasta aquie 
		mov rsi, rbx ; desde aqui
		cld
		rep movsb
		mov rax, r13; just in case 

		add rsp,8
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret

	;bool string_menor( char *s1, char *s2 )
	string_menor:
		;pasaje de parametros por rdi, rsi
		push rbp
		mov rbp, rsp
		push rbx
		push r12 
		push r13 
		push r14 ; pila alineada

		mov r12, rdi ;backup rdi
		mov r13, rsi ;backup rsi
		call string_longitud
		mov rbx, rax ; longitud 1 en rbx
		mov rdi, r13
		mov rcx, rbx ;seteo para ciclo
		mov r14, 0; indice 
		ciclo:
			xor rdi,rdi
			xor rsi,rsi
			mov dil, byte [r12 + r14]
			mov sil, byte [r13 + r14]
			cmp rdi,rsi
			jg terminar_falso
			jl terminar_verdadero
			inc r14
			loop ciclo
		mov rdi, r12 ; muevo string 1
		mov rsi, r13 ; muevo string 2
		call string_iguales ; me fijo que no sean iguales 
		cmp rax, TRUE 
		je terminar_falso ; si son iguales pongo falso
		terminar_verdadero:
		mov rax,TRUE ; como no son iguales pongo verdad
		jmp end
		end:
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret

		terminar_falso:
		mov rax, FALSE
		jmp end




		

