; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 2                                     ;
;                                                                           ;
; ************************************************************************* ;
extern malloc
extern free
section .data
constante: times 4 dd 9
section .text
; void ASM_blur2( uint32_t w, uint32_t h, uint8_t* data )
global ASM_blur2
ASM_blur2:
    
    ;rdi = ancho
    ;rsi = alto
    ;rdx = src
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
 
    xor r12, r12    ;contador filas
    xor r13, r13    ;contador columnas
    xor r14, r14
    xor r15, r15
    xor r8, r8
    xor r9, r9
    xor rbx, rbx 
    pxor xmm1, xmm1
    pxor xmm2, xmm2
    pxor xmm3, xmm3
    pxor xmm4, xmm4
    pxor xmm5, xmm5
    pxor xmm6, xmm6
    pxor xmm7, xmm7
    pxor xmm8, xmm8
    pxor xmm9, xmm9
    pxor xmm10, xmm10
    mov qword r9, rdi 
    shl r9, 2                   ;cantidad de bytes por fila, suponiendo que venia en pixels
    mov qword r10, r9
    mov qword rax, r9
    mul rsi                    ;pixels en cada fila * cant filas = tamaño imagen
    mov qword rdi, rax
    mov qword r9, rdi           ;respaldo ancho imagen
    mov qword r8, rsi           ;respaldo altura
    call malloc                 ;pido memoria para la copia de la imagen
    mov qword rcx, rax
    mov qword r11, rdx
    .ciclocopia:
    cmp r15, r9               ;termine de copiar?
    jz .fincopia
    mov byte r14, [rdx]
    mov byte [rax], r14b
    inc r15                           ;copio lo que estaba en la imagen
    inc rdx
    inc rax
    jmp .ciclocopia
  .fincopia:                         ;tengo en rcx el puntero a la nueva imagen copiada
    mov qword rdx, r11               ;reestablezco el puntero en el inicio de la imagen original
    mov qword rsi, r8                ;reestablezco cantidad de filas
    sub r8, 2                    ;filas -2 para saber si estoy en borde despues 
    mov qword r10, r9                ;r10 = cantidad de pixels por fila
    sub r10, 2                       ;para saber si estoy en el borde
   shl r9, 2                     ;cantidad de bytes por fila, suponiendo que venia en pixels
   ;mov qword r10, r9
   ;sub r10, 8                           ;cantidad de bytes por fila - 8 para saber si estoy en el borde
    mov qword r11, r9                ;voy a usar r11 para moverme por src
    movdqu xmm14, [constante]
    mov rax, rcx
 
  .ciclofila:
     cmp r12, 2          ;fila < 2?
     jl .avanzofila
     cmp r12, r8         ;fila >= cantfilas - 2?
     jge .avanzofila 
     xor rbx, rbx        ;reseto contador columnas
     cmp r12, rsi
     jz .fin
  .ciclocolumna:
      movdqu xmm0, [rcx] 
      cmp rbx, 2         ;columna <2?
      jl .dosalfinal      ;dejo los 2 primeros pixels como estaban
      cmp rbx, r10       ;columna >= tamaño col -2 ?
      jge .dosalprincipio ;los ultimos pixels quedan como estaban
      jmp .primeros
      .dosalfinal:
           
           mov qword r14, 1      ;seteo caso
           movdqu xmm1, xmm0
           punpcklbw xmm1, xmm15
           punpcklwd xmm1, xmm15
           
           movdqu xmm2, xmm0
           punpcklbw xmm2, xmm15
           punpckhwd xmm2, xmm15

           ;dejo pixel 1 y 2 como estaban
           jmp .ultimos

      .dosalprincipio:

           mov qword r14, 2      ;seteo caso
           movdqu xmm3, xmm0
           punpckhbw xmm3, xmm15
           punpcklwd xmm3, xmm15
           
           movdqu xmm4, xmm0
           punpckhbw xmm4, xmm15
           punpckhwd xmm4, xmm15
           ;dejo pixel 3 y 4 como estaban
           jmp .primeros
                               .primeros:
                                ; PROCESO P1
				movdqu xmm1,xmm0
				punpcklbw xmm1,xmm15
				punpcklwd xmm1,xmm15
				;cvtdq2ps xmm1,xmm1			; xmm1 = p1_b | p1_g | p1_r | p1_a  (como floats)
				;cvttps2dq xmm1,xmm1			; paso a int truncado
				

                                ; "LOS DE ARRIBA"
				mov r11,rcx
				sub r11,r9					; le resto src_row_size ahora estoy en la fila i-1	
				sub r11,4					; corro j 1 lugar
				
				movdqu xmm2,[r11]
				punpcklbw xmm2,xmm15
				punpcklwd xmm2,xmm15
				;cvtdq2ps xmm2,xmm2			; xmm2 = componentes del px de (i-1,j-1) (como floats)
				;cvttps2dq xmm2,xmm2			; paso a int truncado
				
				mov r11,rcx
				sub r11,r9					; pongo r11 en la fila anterior
	
				movdqu xmm3,[r11]
				punpcklbw xmm3,xmm15
				punpcklwd xmm3,xmm15
				;cvtdq2ps xmm3,xmm3			; xmm3 = componentes del px de (i-1,j) (como floats)
				;cvttps2dq xmm3,xmm3			; paso a int truncado
				
				mov r11,rcx
				sub r11, r9                              ;fila anterior
                                add r11, 4                               ;pixel siguiente

				movdqu xmm4,[r11]
				punpcklbw xmm4,xmm15
				punpcklwd xmm4,xmm15
				;cvtdq2ps xmm4,xmm4			; xmm4 = componentes del px de (i-1,j+1) (como floats)
				;cvttps2dq xmm4,xmm4			; paso a int truncado
				
				mov r11,rcx                              ;misma fila
                                sub r11, 4                               ;pixel anterior
				
				
				movdqu xmm5,[r11]
				punpcklbw xmm5,xmm15
				punpcklwd xmm5,xmm15
				;cvtdq2ps xmm5,xmm5			; xmm5 = componentes del px de (i,j-1) (como floats)
				;cvttps2dq xmm5,xmm5			; paso a int truncado

                                mov r11, rcx                            ;misma fila
                                add r11, 4                              ;pixel siguiente

                                movdqu xmm6,[r11]
				punpcklbw xmm6,xmm15
				punpcklwd xmm6,xmm15
				;cvtdq2ps xmm6,xmm6			; xmm6 = componentes del px de (i,j+1) (como floats)
				;cvttps2dq xmm6,xmm6			; paso a int truncado

                                mov r11, rcx                            ;misma fila
                                add r11, r9                             ;fila siguiente
                                sub r11, 4                              ;pixel anterior

                                movdqu xmm7,[r11]
				punpcklbw xmm7,xmm15
				punpcklwd xmm7,xmm15
				;cvtdq2ps xmm7,xmm7			; xmm7 = componentes del px de (i+1,j-1) (como floats)
				;cvttps2dq xmm7,xmm7			; paso a int truncado

                                mov r11, rcx				;misma fila
                                add r11, r9				;fila siguiente mismo pixel
                                
                                movdqu xmm8,[r11]
				punpcklbw xmm8,xmm15
				punpcklwd xmm8,xmm15
				;cvtdq2ps xmm8,xmm8			; xmm8 = componentes del px de (i+1,j) (como floats)
				;cvttps2dq xmm8,xmm8			; paso a int truncado

                                mov r11, rcx				;misma fila
                                add r11, r9				;fila siguiente
                                add r11, 4				;pixel siguiente
                                
                                movdqu xmm9,[r11]
				punpcklbw xmm9,xmm15
				punpcklwd xmm9,xmm15
				;cvtdq2ps xmm9,xmm9			; xmm9 = componentes del px de (i+1,j+1) (como floats)
				;cvttps2dq xmm9,xmm9			; paso a int truncado

                                ;ACA YA TENGO LA MATRIZ ARMADA
                                
                               
                                paddd xmm1, xmm2
				paddd xmm1, xmm3
				paddd xmm1, xmm4
				paddd xmm1, xmm5
				paddd xmm1, xmm6
				paddd xmm1, xmm7
			        paddd xmm1, xmm8
				paddd xmm1, xmm9

                                ;paddusb xmm0, xmm1
                                ;paddusb xmm1, xmm2
				;paddusb xmm1, xmm3
				;paddusb xmm1, xmm4
				;paddusb xmm1, xmm5
				;paddusb xmm1, xmm6
				;paddusb xmm1, xmm7
				;paddusb xmm1, xmm8
				;paddusb xmm1, xmm9
				;ACA ESTA LA SUMA EN INT
                                cvtdq2ps xmm1, xmm1
                                divps xmm1, xmm14                ;divido por 9
                                cvtps2dq xmm1, xmm1              ;paso a int


                                ;PROCESO PIXEL 2
                                movdqu xmm2, xmm0
                                punpcklbw xmm2,xmm15
				punpckhwd xmm2,xmm15
				;cvtdq2ps xmm2,xmm2			; xmm2 = p2_b | p2_g | p2_r | p2_a  (como floats)

                                mov r11,rcx
				sub r11,r9					; le resto src_row_size ahora estoy en la fila i-1	
				sub r11,4					; corro j 1 lugar
				
				movdqu xmm3,[r11]
				punpcklbw xmm3,xmm15
				punpckhwd xmm3,xmm15
				;cvtdq2ps xmm3,xmm3			; xmm3 = componentes del px2 de (i-1,j-1) (como floats)
				;cvttps2dq xmm3,xmm3			; paso a int truncado

				mov r11,rcx
				sub r11,r9					; pongo r11 en la fila anterior
	
				movdqu xmm4,[r11]
				punpcklbw xmm4,xmm15
				punpckhwd xmm4,xmm15
				;cvtdq2ps xmm4,xmm4			; xmm4 = componentes del px2 de (i-1,j) (como floats)
				;cvttps2dq xmm4,xmm4			; paso a int truncado

                                mov r11,rcx
				sub r11, r9                              ;fila anterior
                                add r11, 4                               ;pixel siguiente

				movdqu xmm5,[r11]
				punpcklbw xmm5,xmm15
				punpckhwd xmm5,xmm15
				;cvtdq2ps xmm5,xmm5			; xmm5 = componentes del px2 de (i-1,j+1) (como floats)
				;cvttps2dq xmm5,xmm5			; paso a int truncado
				
				mov r11,rcx                              ;misma fila
                                sub r11, 4                               ;pixel anterior
				
				
				movdqu xmm6,[r11]
				punpcklbw xmm6,xmm15
				punpckhwd xmm6,xmm15
				;cvtdq2ps xmm6,xmm5			; xmm6 = componentes del px2 de (i,j-1) (como floats)
				;cvttps2dq xmm6,xmm6			; paso a int truncado

				mov r11, rcx                            ;misma fila
                                add r11, 4                              ;pixel siguiente

                                movdqu xmm7,[r11]
				punpcklbw xmm7,xmm15
				punpckhwd xmm7,xmm15
				;cvtdq2ps xmm7,xmm7			; xmm7 = componentes del px de (i,j+1) (como floats)
				;cvttps2dq xmm7,xmm7			; paso a int truncado

                                mov r11, rcx                            ;misma fila
                                add r11, r9                             ;fila siguiente
                                sub r11, 4                              ;pixel anterior

                                movdqu xmm8,[r11]
				punpcklbw xmm8,xmm15
				punpckhwd xmm8,xmm15
				;cvtdq2ps xmm8,xmm8			; xmm8 = componentes del px de (i+1,j-1) (como floats)
				;cvttps2dq xmm8,xmm8			; paso a int truncado

                                mov r11, rcx				;misma fila
                                add r11, r9				;fila siguiente mismo pixel
                                
                                movdqu xmm9,[r11]
				punpcklbw xmm9,xmm15
				punpckhwd xmm9,xmm15
				;cvtdq2ps xmm9,xmm9			; xmm9 = componentes del px de (i+1,j) (como floats)
				;cvttps2dq xmm9,xmm9			; paso a int truncado

                                mov r11, rcx				;misma fila
                                add r11, r9				;fila siguiente
                                add r11, 4				;pixel siguiente
                                
                                movdqu xmm10,[r11]
				punpcklbw xmm10,xmm15
				punpckhwd xmm10,xmm15
				;cvtdq2ps xmm10,xmm5			; xmm10 = componentes del px de (i+1,j+1) (como floats)
				;cvttps2dq xmm10,xmm10			; paso a int truncado

                                paddd xmm2, xmm3
				paddd xmm2, xmm4
				paddd xmm2, xmm5
				paddd xmm2, xmm6
				paddd xmm2, xmm7
				paddd xmm2, xmm8
			        paddd xmm2, xmm9
				paddd xmm2, xmm10
                                
                                cvtdq2ps xmm2, xmm2
                                divps xmm2, xmm14
                                cvtps2dq xmm2, xmm2

                                cmp qword r14, 2
                                jz .empaqueto


                              .ultimos:
                                ;PROCESO PIXEL 3
                                movdqu xmm3, xmm0
                                punpckhbw xmm3,xmm15
				punpcklwd xmm3,xmm15
				;cvtdq2ps xmm3,xmm3			; xmm2 = p2_b | p2_g | p2_r | p2_a  (como floats)

                                mov r11,rcx
				sub r11,r9					; le resto src_row_size ahora estoy en la fila i-1	
				sub r11,4					; corro j 1 lugar
				
				movdqu xmm4,[r11]
				punpckhbw xmm4,xmm15
				punpcklwd xmm4,xmm15
				;cvtdq2ps xmm4,xmm4			; xmm4 = componentes del px2 de (i-1,j-1) (como floats)
				;cvttps2dq xmm4,xmm4			; paso a int truncado

				mov r11,rcx
				sub r11,r9					; pongo r11 en la fila anterior
	
				movdqu xmm5,[r11]
				punpckhbw xmm5,xmm15
				punpcklwd xmm5,xmm15
				;cvtdq2ps xmm5,xmm5			; xmm5 = componentes del px2 de (i-1,j) (como floats)
				;cvttps2dq xmm5,xmm5			; paso a int truncado

                                mov r11,rcx
				sub r11, r9                              ;fila anterior
                                add r11, 4                               ;pixel siguiente

				movdqu xmm6,[r11]
				punpckhbw xmm6,xmm15
				punpcklwd xmm6,xmm15
				;cvtdq2ps xmm6,xmm6			; xmm6 = componentes del px2 de (i-1,j+1) (como floats)
				;cvttps2dq xmm6,xmm6			; paso a int truncado
				
				mov r11,rcx                              ;misma fila
                                sub r11, 4                               ;pixel anterior
				
				
				movdqu xmm7,[r11]
				punpckhbw xmm7,xmm15
				punpcklwd xmm7,xmm15
				;cvtdq2ps xmm7,xmm7			; xmm7 = componentes del px2 de (i,j-1) (como floats)
				;cvttps2dq xmm7,xmm7			; paso a int truncado

				mov r11, rcx                            ;misma fila
                                add r11, 4                              ;pixel siguiente

                                movdqu xmm8,[r11]
				punpckhbw xmm8,xmm15
				punpcklwd xmm8,xmm15
				;cvtdq2ps xmm8,xmm8			; xmm8 = componentes del px de (i,j+1) (como floats)
				;cvttps2dq xmm8,xmm8			; paso a int truncado

                                mov r11, rcx                            ;misma fila
                                add r11, r9                             ;fila siguiente
                                sub r11, 4                              ;pixel anterior

                                movdqu xmm9,[r11]
				punpckhbw xmm9,xmm15
				punpcklwd xmm9,xmm15
				;cvtdq2ps xmm9,xmm9			; xmm9 = componentes del px de (i+1,j-1) (como floats)
				;cvttps2dq xmm9,xmm9			; paso a int truncado

                                mov r11, rcx				;misma fila
                                add r11, r9				;fila siguiente mismo pixel
                                
                                movdqu xmm10,[r11]
				punpckhbw xmm10,xmm15
				punpcklwd xmm10,xmm15
				;cvtdq2ps xmm10,xmm10			; xmm10 = componentes del px de (i+1,j) (como floats)
				;cvttps2dq xmm10,xmm10			; paso a int truncado

                                mov r11, rcx				;misma fila
                                add r11, r9				;fila siguiente
                                add r11, 4				;pixel siguiente
                                
                                movdqu xmm11,[r11]
				punpckhbw xmm11,xmm15
				punpcklwd xmm11,xmm15
				;cvtdq2ps xmm11,xmm5			; xmm11 = componentes del px de (i+1,j+1) (como floats)
				;cvttps2dq xmm11,xmm11			; paso a int truncado

                                paddd xmm3, xmm4
				paddd xmm3, xmm5
				paddd xmm3, xmm6
				paddd xmm3, xmm7
				paddd xmm3, xmm8
				paddd xmm3, xmm9
			        paddd xmm3, xmm10
				paddd xmm3, xmm11
                                
                                cvtdq2ps xmm3, xmm3
                                divps xmm3, xmm14
                                cvtps2dq xmm3, xmm3



                                 ;PROCESO PIXEL 4
                                movdqu xmm4, xmm0
                                punpckhbw xmm4,xmm15
				punpckhwd xmm4,xmm15
				;cvtdq2ps xmm4,xmm4			; xmm4 = p2_b | p2_g | p2_r | p2_a  (como floats)

                                mov r11,rcx
				sub r11,r9					; le resto src_row_size ahora estoy en la fila i-1	
				sub r11,4					; corro j 1 lugar
				
				movdqu xmm5,[r11]
				punpckhbw xmm5,xmm15
				punpckhwd xmm5,xmm15
				;cvtdq2ps xmm5,xmm5			; xmm5 = componentes del px2 de (i-1,j-1) (como floats)
				;cvttps2dq xmm5,xmm5			; paso a int truncado

				mov r11,rcx
				sub r11,r9					; pongo r11 en la fila anterior
	
				movdqu xmm6,[r11]
				punpckhbw xmm6,xmm15
				punpckhwd xmm6,xmm15
				;cvtdq2ps xmm6,xmm6			; xmm6 = componentes del px2 de (i-1,j) (como floats)
				;cvttps2dq xmm6,xmm6			; paso a int truncado

                                mov r11,rcx
				sub r11, r9                              ;fila anterior
                                add r11, 4                               ;pixel siguiente

				movdqu xmm7,[r11]
				punpckhbw xmm7,xmm15
				punpckhwd xmm7,xmm15
				;cvtdq2ps xmm7,xmm7			; xmm7 = componentes del px2 de (i-1,j+1) (como floats)
				;cvttps2dq xmm7,xmm7			; paso a int truncado
				
				mov r11,rcx                              ;misma fila
                                sub r11, 4                               ;pixel anterior
				
				
				movdqu xmm8,[r11]
				punpckhbw xmm8,xmm15
				punpckhwd xmm8,xmm15
				;cvtdq2ps xmm8,xmm8			; xmm8 = componentes del px2 de (i,j-1) (como floats)
				;cvttps2dq xmm8,xmm8			; paso a int truncado

				mov r11, rcx                            ;misma fila
                                add r11, 4                              ;pixel siguiente

                                movdqu xmm9,[r11]
				punpckhbw xmm9,xmm15
				punpckhwd xmm9,xmm15
				;cvtdq2ps xmm9,xmm9			; xmm9 = componentes del px de (i,j+1) (como floats)
				;cvttps2dq xmm9,xmm9			; paso a int truncado

                                mov r11, rcx                            ;misma fila
                                add r11, r9                             ;fila siguiente
                                sub r11, 4                              ;pixel anterior

                                movdqu xmm10,[r11]
				punpckhbw xmm10,xmm15
				punpckhwd xmm10,xmm15
				;cvtdq2ps xmm10,xmm10			; xmm10 = componentes del px de (i+1,j-1) (como floats)
				;cvttps2dq xmm10,xmm10			; paso a int truncado

                                mov r11, rcx				;misma fila
                                add r11, r9				;fila siguiente mismo pixel
                                
                                movdqu xmm11,[r11]
				punpckhbw xmm11,xmm15
				punpckhwd xmm11,xmm15
				;cvtdq2ps xmm11,xmm11			; xmm11 = componentes del px de (i+1,j) (como floats)
				;cvttps2dq xmm11,xmm11			; paso a int truncado

                                mov r11, rcx				;misma fila
                                add r11, r9				;fila siguiente
                                add r11, 4				;pixel siguiente
                                
                                movdqu xmm12,[r11]
				punpckhbw xmm12,xmm15
				punpckhwd xmm12,xmm15
				;cvtdq2ps xmm12,xmm5			; xmm12 = componentes del px de (i+1,j+1) (como floats)
				;cvttps2dq xmm12,xmm12			; paso a int truncado

                                paddd xmm4, xmm5
				paddd xmm4, xmm6
				paddd xmm4, xmm7
				paddd xmm4, xmm8
				paddd xmm4, xmm9
				paddd xmm4, xmm10
			        paddd xmm4, xmm11
				paddd xmm4, xmm12
                                
                                cvtdq2ps xmm4, xmm4
                                divps xmm4, xmm14
                                cvtps2dq xmm4, xmm4
                         
                         ;xmm1 = p1_b | p1_g | p1_r | p1_a
                         ;xmm2 = p2_b | p2_g | p2_r | p2_a
		         ;xmm3 = p3_b | p3_g | p3_r | p3_a
			 ;xmm4 = p4_b | p4_g | p4_r | p4_a

                         ;TODO YA PROCESADO COMO SE DEBE
                         ;EMPAQUETO

                       .empaqueto:
                         packusdw xmm1, xmm2
                         packusdw xmm3, xmm4
                         packusdw xmm1, xmm3
                         ;COLOCO

                         movdqu [rdx], xmm1
                         xor r14, r14                      ;reseteo casos
                         add rdx, 16                       ;copie 4 pixel mas a la original
                         add rcx, 16                       ;copie 4 pixel mas de la copia
                         add rbx, 4
                         cmp r10, rbx                     ;termine con la fila?
                         jz .avanzofila
                         jmp .ciclocolumna
                       .avanzofila:
                         inc r12 
                         jmp .ciclofila
                         
                           

.fin:
  mov qword rdi, rax
  call free                    ;libero la memoria de la imagen copia
  add rsp, 8
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret
