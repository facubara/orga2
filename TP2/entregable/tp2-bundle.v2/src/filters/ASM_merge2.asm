; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Merge 2                                    ;
;                                                                           ;
; ************************************************************************* ;

section .data
align 16
constante1: times 4 dd 1
mascaraexp: db  0xFF,0xFF,0x7F,0x80, 0,0,0,0, 0,0,0,0, 0,0,0,0 
mascaraFloat: dd 0xFFFFFFFF, 0, 0, 0
mascaraA: dd 0x0, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
mascara1: dd 1, 0, 0, 0
mascaraMover: db 0,0xff,0xff,0xff,0,0xff,0xff,0xff,0,0xff,0xff,0xff,0,0xff,0xff,0xff
section .text

; void ASM_merge2(uint32_t w, uint32_t h, uint8_t* data1, uint8_t* data2, float value)
global ASM_merge2
ASM_merge2:
  push rbp
  mov rbp, rsp
  push rbx
  push r12
  push r13
  push r14
  push r15
  sub rsp, 8

;Para pruebas aritmeticas--------------------------------------------------------------------
;	add rdx, rdx
;	sub rdx, rdx
;	add rdx, rdx
;	sub rdx, rdx
;	add rdx, rdx
;	sub rdx, rdx
;	add rdx, rdx
;	sub rdx, rdx
;	add rdx, rdx
;	sub rdx, rdx
;	add rdx, rdx
;	sub rdx, rdx
;	add rdx, rdx
;	sub rdx, rdx
;	add rdx, rdx
;	sub rdx, rdx
;--------------------------------------------------------------------------------------------

;Para pruebas de memoria---------------------------------------------------------------------
;	push rax
;	pop rax
;	push rax
;	pop rax
;	push rax
;	pop rax
;	push rax
;	pop rax
;	push rax
;	pop rax
;	push rax
;	pop rax
;	push rax
;	pop rax
;	push rax
;	pop rax
;--------------------------------------------------------------------------------------------

  ;rdi = ancho
  ;rsi = alto
  ;rdx = src1
  ;rcx = src2
  ;xmm0 = value
  xor rax, rax				
  xor rbx, rbx
  xor r9, r9
  pxor xmm12, xmm12
  movdqu xmm3, [mascaraexp]
  pand xmm0, [mascaraFloat] ; xmm0 = 0 | 0 | 0 | value
  movd eax, xmm0            ;eax = value            seeeeeeeemmmmmmmmmmmmmmmmmmmmmmm
  shr rax, 23              ;eax = exponente        00000000000000000000000seeeeeeee
  mov qword r10, 150        ;r10 = 150
  mov qword rbx, 150
  sub bl, al              ;rbx = 150 - exponente = "k" (o menos el exponente original + 23) ESTO NO ESTA EN EXCESO 127
  shl r10, 23              ;r10 = 150 en la posicion del exponente de un float en ieee754 (s = 0 mantisa = 0)
  
  ;rax sigue teniendo el exponente en al y el signo en ah

  movdqu xmm13, xmm0          ;xmm13 = xmm0	
  pand xmm13, [mascaraexp]    ;xmm13 = mantisa del float en el ultimo dword osea saco exponente
  movd xmm12, r10d            ;xmm12 = 150 en el lugar del exponente del primer dword
  pxor xmm13, xmm12           ;el float con la misma mantisa que value pero exponente 150, osea 150-127 = 23
  cvtps2dq xmm13, xmm13       ;value como int
  mov r9, rbx                 ;r9 = k float
  pxor xmm14, xmm14
  movd xmm14, r9d             ;xmm14 = 0 | 0 | 0 | k float
  mov r9, rbx   ;ACA SE LO PASO PARA EL SHIFT k
  xor r10, r10                ;r10 = 0
  inc r10                     ;r10 = 1
.cicloshift:
  cmp r9d, 0                   ;termine de shiftear?
  jz .finshift
  shl r10, 1
  dec r9
  jmp .cicloshift
   
.finshift: 
  ;r10 = 2^k
  movd xmm12, r10d           ;xmm12 = 0 | 0 | 0 | 2^k
  psubd xmm12, xmm13         ;xmm12 =  0 | 0 | 0 | 2^k - value  (como ints)
  pshufd xmm12, xmm12, 0h   ;xmm12 = 2^k - value | 2^k - value | 2^k - value | 2^k - value (como ints)
  pand xmm12, [mascaraA]    ;xmm12 = 2^k - value | 2^k - value | 2^k - value | 0 (como ints)
  ;pxor xmm12, [mascara1]    ;xmm12 = 2^k - value | 2^k - value | 2^k - value | 1 (como ints)
  pshufd xmm13, xmm13, 0h   ;xmm13 = value | value | value | value (como ints)
  pand xmm13, [mascaraA]    ;xmm13 = value | value | value | 0 (como ints)
  pxor xmm13, [mascara1]    ;xmm13 = value | value | value | 1 (como ints)
  mov r12, rdi              ;cant pixels por fila
  mov r13, rsi              ;r13 = cant filas
  xor r14, r14              ;contador filas
  xor r15, r15              ;contador pixels
  mov r8, rdx
  mov r9, rcx
  pxor xmm15, xmm15
  movdqu xmm12, [mascaraMover]

  
  .ciclofilas:
   cmp r14, r13
   jz .fin
   xor r15, r15                         ;reseto pixels por fila     
        .ciclocolumnas:
          ;SRC1
          movdqu xmm1, [r8]                     ; xmm1 = src1(i,j+0)| src1(i,j+1) | src1(i,j+2) | src1(i,j+3)
          
          ;PIXEL src1 1

          movdqu xmm2,xmm1
	  punpcklbw xmm2,xmm15
	  punpcklwd xmm2,xmm15                  ;xmm2 = p1_b | p1_g | p1_r | p1_a  (como ints)
	  

          ;PIXEL src1 2

          movdqu xmm3,xmm1
	  punpcklbw xmm3,xmm15
	  punpckhwd xmm3,xmm15                  ;xmm3 = p2_b | p2_g | p2_r | p2_a  (como ints)
	   

          ;PIXEL src1 3

          movdqu xmm4,xmm1
	  punpckhbw xmm4,xmm15
	  punpcklwd xmm4,xmm15                  ;xmm3 = p3_b | p3_g | p3_r | p3_a  (como ints)
	  
          ;PIXEL src1 4

          movdqu xmm5,xmm1
	  punpckhbw xmm5,xmm15
	  punpckhwd xmm5,xmm15   	        ; xmm5 = p4_b | p4_g | p4_r | p4_a  (como ints)

          ;SRC2
          movdqu xmm6, [r9]                     ; xmm6 = src2(i,j+0)| src2(i,j+1) | src2(i,j+2) | src2(i,j+3)


          ;PIXEL src2 1

          movdqu xmm7,xmm6
	  punpcklbw xmm7,xmm15
	  punpcklwd xmm7,xmm15                  ; xmm7 = p1_b | p1_g | p1_r | p1_a  (como ints)

          ;PIXEL src2 2

          movdqu xmm8,xmm6
	  punpcklbw xmm8,xmm15
	  punpckhwd xmm8,xmm15                  ; xmm8 = p2_b | p2_g | p2_r | p2_a  (como ints)

          ;PIXEL src2 3

          movdqu xmm9,xmm6
	  punpckhbw xmm9,xmm15
	  punpcklwd xmm9,xmm15                  ; xmm9 = p3_b | p3_g | p3_r | p3_a  (como ints)

          ;PIXEL src2 4

          movdqu xmm10,xmm6
	  punpckhbw xmm10,xmm15
	  punpckhwd xmm10,xmm15			; xmm10 = p4_b | p4_g | p4_r | p4_a  (como ints)

          ;HASTA ACA TENGO TODO ARMADITO
          ;SUMO CON INTS

          ;tengo en xmm12 = 2^k - value | 2^k - value | 2^k - value | 0 (como ints)
          ;tengo en xmm13 = value | value | value | 1 (como ints)


          pmulld xmm2, xmm13                     ;xmm2 src1 = p1_b * value| p1_g * value| p1_r * value| p1_a * 1 (como ints)
          psrld xmm2, xmm14                      ; eso lo divide por 2^k 
          movdqu xmm11, xmm7                     ;xmm11 = p1_b | p1_g | p1_r | p1_a  (como ints)
          pmulld xmm7, xmm13                     ;xmm7 src21 = p1_b * value | p1_g * value | p1_r * value | p1_a * 1
          psrld xmm7, xmm14                      ;xmm7= xmm7/2^k
          psubd xmm11, xmm7                       ;xmm11 = p1_b - p1_b*value/2^k... | p1_a - p1_a*value/2^k 
          movdqu xmm7, xmm11 
          paddd xmm2, xmm7                       ;xmm2 = value * m1[j][i][k] + (1 - value ) * m2[j][i][k]

          pmulld xmm3, xmm13                      ;xmm3 src1 = p2_b * value| p2_g * value| p2_r * value| p2_a * 1 (como ints)
          psrld xmm3, xmm14                       ; eso lo divide por 2^k
          movdqu xmm11, xmm8                     ;xmm11 = p2_b | p2_g | p2_r | p2_a 
          pmulld xmm8, xmm13                     ;xmm8 src2 = p2_b * value| p2_g * value| p2_r *value| p2_a * 1 (como ints)
          psrld xmm8, xmm14                      ;xmm8 = xmm8/2^k
          psubd xmm11, xmm8                       ;xmm11 = p2_b - p2_b*value/2^k .... | p2_a - p2_a*value/2^k
          movdqu xmm8, xmm11                 
          paddd xmm3, xmm8                       ;xmm3 = value * m1[j][i+1][k] + (1 - value ) * m2[j][i+1][k]

          pmulld xmm4, xmm13                      ;xmm4 src1 = p3_b * value| p3_g * value| p3_r * value| p3_a * 1 (como ints)
          psrld xmm4, xmm14                       ; eso lo divide por 2^k
          movdqu xmm11, xmm9                     ;xmm11 = p3_b | p3_g | p3_r | p3_a
          pmulld xmm9, xmm13                     ;xmm9 = p3_b * value | p3_g * value | p3_r * value | p3_a * 1 
          psrld xmm9, xmm14                      ;xmm9 = xmm9/2^k
          psubd xmm11, xmm9                       ;xmm9 = p3_b - p3_b *value/2^k... | p3_a - p3_a*value/2^k
          movdqu xmm9, xmm11                   
          paddd xmm4, xmm9                       ;xmm4 = value * m1[j][i+2][k] + (1 - value ) * m2[j][i+2][k]

          pmulld xmm5, xmm13                      ;xmm5 src1 = p4_b * value| p4_g * value| p4_r * value| p4_a * 1 (como ints)
          psrld xmm5, xmm14                       ; eso lo divide por 2^k
          movdqu xmm11, xmm10                    ;xmm11 = p4_b | p4_g | p4_r | p4_a
          pmulld xmm10, xmm13                    ;xmm10= p4_b * value | p4_g * value | p4_r * value | p4_a * 1 
          psrld xmm10, xmm14                     ;xmm10 = xmm10/2^k
          psubd xmm11, xmm10                      ;xmm10 = p4_b - p4_b * value/2^k | ... p4_a  - p4_a*value/2^k
          movdqu xmm10, xmm11
          paddd xmm5, xmm10                      ;xmm5 = value * m1[j][i+3][k] + (1 - value ) * m2[j][i+3][k]

          ;YA MULTIPLIQUE, AHORA EMPAQUETO Y SUMO
          ;EMPAQUETO

        packusdw xmm2, xmm3
	  	  packusdw xmm4, xmm5
	  	  packuswb xmm2, xmm4                
           
          ;COLOCO
          mov rdi, r8
          maskmovdqu xmm2, xmm12                     ;coloco
          add r15, 4                            ;copie 4 pixels mas
          add r8, 16                            ;me muevo en src1
          add r9, 16                            ;me muevo en src2
          cmp r12, r15                          ;termine con la fila?
          jz .cambiofila
          jmp .ciclocolumnas
          

          .cambiofila:
            inc r14
            jmp .ciclofilas

  .fin:
  add rsp, 8
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp         
  ret
