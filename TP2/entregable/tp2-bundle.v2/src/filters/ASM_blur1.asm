; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 1                                     ;
;                                                                           ;
; ************************************************************************* ;
extern malloc
section .data
constante: times 4 dd 9
section .text
; void ASM_blur1( uint32_t w, uint32_t h, uint8_t* data )
global ASM_blur1
ASM_blur1:
    
    ;rdi = ancho
    ;rsi = alto
    ;rdx = src
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    xor r12, r12    ;contador filas
    xor r13, r13    ;contador columnas
    xor r14, r14
    xor r15, r15
    xor r8, r8
    xor r9, r9
    pxor xmm0, xmm0
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
    mov qword r9, rdi           ;respaldo tamaño imagen
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
    mov qword r9, rdi 
    shl r9, 2                     ;cantidad de bytes por fila, suponiendo que venia en pixels
    mov qword r10, r9
    sub r10, 2                           ;cantidad de bytes por fila - 2 para saber si estoy en el borde
    mov qword r11, r9                ;voy a usar r11 para moverme por src
    movdqu xmm14, [constante]         ;xmm14 = 9 | 9 | 9 | 9 
    cvtdq2ps xmm14, xmm14             ;xmm14 = 9 | 9 | 9 | 9 (en float)
 
  .ciclofila:
     cmp r12, 2          ;fila < 2?
     jl .avanzofila
     cmp r12, r8         ;fila >= cantfilas - 2?
     jge .avanzofila 
     xor r9, r9          ;reseto contador columnas
     cmp r12, rsi
     jz .fin
  .ciclocolumna:
      cmp r13, 2         ;columna <2?
      jl .avanzocol      ;dejo el pixel como estaba
      cmp r13, r10       ;columna >= tamaño col -2 ?
      jge .avanzocol     ;dejo el pixel como estaba
      movd xmm0, [rcx]

        ;MOVD MUEVE EXACTAMENTE 4 BYTES, OSEA UN PIXEL A LA PARTE BAJA DE XMM0
                                ; PROCESO P1
				;movd xmm1,xmm0
                                movd xmm1, [rcx]
				punpcklbw xmm1,xmm15
				punpcklwd xmm1,xmm15
				;cvtdq2ps xmm1,xmm1			; xmm1 = p1_b | p1_g | p1_r | p1_a  (como floats)
				;cvttps2dq xmm1,xmm1			; paso a int truncado
				

                                ; "LOS DE ARRIBA"
				mov r11,rcx
				sub r11,r9					; le resto src_row_size ahora estoy en la fila i-1	
				sub r11,4					; corro j 1 lugar
				
				movd xmm2,[r11]
				punpcklbw xmm2,xmm15
				punpcklwd xmm2,xmm15
				;cvtdq2ps xmm2,xmm2			; xmm2 = componentes del px de (i-1,j-1) (como floats)
				;cvttps2dq xmm2,xmm2			; paso a int truncado
				
				mov r11,rcx
				sub r11,r9					; pongo r11 en la fila anterior
	
				movd xmm3,[r11]
				punpcklbw xmm3,xmm15
				punpcklwd xmm3,xmm15
				;cvtdq2ps xmm3,xmm3			; xmm3 = componentes del px de (i-1,j) (como floats)
				;cvttps2dq xmm3,xmm3			; paso a int truncado
				
				mov r11,rcx
				sub r11, r9                              ;fila anterior
                                add r11, 4                               ;pixel siguiente

				movd xmm4,[r11]
				punpcklbw xmm4,xmm15
				punpcklwd xmm4,xmm15
				;cvtdq2ps xmm4,xmm4			; xmm4 = componentes del px de (i-1,j+1) (como floats)
				;cvttps2dq xmm4,xmm4			; paso a int truncado
				
				mov r11,rcx                              ;misma fila
                                sub r11, 4                               ;pixel anterior
				
				
				movd xmm5,[r11]
				punpcklbw xmm5,xmm15
				punpcklwd xmm5,xmm15
				;cvtdq2ps xmm5,xmm5			; xmm5 = componentes del px de (i,j-1) (como floats)
				;cvttps2dq xmm5,xmm5			; paso a int truncado

                                mov r11, rcx                            ;misma fila
                                add r11, 4                              ;pixel siguiente

                                movd xmm6,[r11]
				punpcklbw xmm5,xmm15
				punpcklwd xmm5,xmm15
				;cvtdq2ps xmm5,xmm5			; xmm5 = componentes del px de (i,j+1) (como floats)
				;cvttps2dq xmm5,xmm5			; paso a int truncado

                                mov r11, rcx                            ;misma fila
                                add r11, r9                             ;fila siguiente
                                sub r11, 4                              ;pixel anterior

                                movd xmm7,[r11]
				punpcklbw xmm5,xmm15
				punpcklwd xmm5,xmm15
				;cvtdq2ps xmm5,xmm5			; xmm5 = componentes del px de (i+1,j-1) (como floats)
				;cvttps2dq xmm5,xmm5			; paso a int truncado

                                mov r11, rcx				;misma fila
                                add r11, r9				;fila siguiente mismo pixel
                                
                                movd xmm8,[r11]
				punpcklbw xmm5,xmm15
				punpcklwd xmm5,xmm15
				;cvtdq2ps xmm5,xmm5			; xmm5 = componentes del px de (i+1,j) (como floats)
				;cvttps2dq xmm5,xmm5			; paso a int truncado

                                mov r11, rcx				;misma fila
                                add r11, r9				;fila siguiente
                                add r11, 4				;pixel siguiente
                                
                                movd xmm9,[r11]
				punpcklbw xmm5,xmm15
				punpcklwd xmm5,xmm15
				;cvtdq2ps xmm5,xmm5	  ;xmm5 = componentes del px de (i+1,j+1) (como floats)
				;cvttps2dq xmm5,xmm5			; paso a int truncado
				

                                ;ACA YA TENGO LA MATRIZ ARMADA
                                
                                ;paddd xmm0, xmm1
                                paddd xmm1, xmm2
				paddd xmm1, xmm3
				paddd xmm1, xmm4
				paddd xmm1, xmm5
				paddd xmm1, xmm6
				paddd xmm1, xmm7
			        paddd xmm1, xmm8
				paddd xmm1, xmm9

                                ;SUMO CON INTS Y DESPUES CONVIERTO A FLOAT PARA DIVIDIR

                                ;addps xmm0, xmm1
                                ;addps xmm0, xmm2
				;addps xmm0, xmm3
				;addps xmm0, xmm4
				;addps xmm0, xmm5
				;addps xmm0, xmm6
				;addps xmm0, xmm7
				;addps xmm0, xmm8
				;addps xmm0, xmm9
				;ACA ESTA LA SUMA EN float en xmm0
                                cvtdq2ps xmm1, xmm1
                                divps xmm1, xmm14                ;divido por 9
                                cvtps2dq xmm1, xmm1              ;paso a int

                         ;COLOCO

                         movd [rdx], xmm1
                         pxor xmm1, xmm1
                         pxor xmm0, xmm0
                       .avanzocol:
                         add rdx, 4                       ;copie 1 pixel mas a la original
                         add rcx, 4                       ;copie 1 pixel mas de la copia
                         inc r9
                         cmp r10, r9                      ;termine con la fila?
                         jz .avanzofila
                         jmp .ciclocolumna
                       .avanzofila:
                         inc r12 
                         jmp .ciclofila
                         
                           

.fin:
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp
  ret
