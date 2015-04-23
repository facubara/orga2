; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Merge 2                                    ;
;                                                                           ;
; ************************************************************************* ;

section .data
align 16
constante1: times 4 dd 1

section .text

; void ASM_merge2(uint32_t w, uint32_t h, uint8_t* data1, uint8_t* data2, float value)
global ASM_merge2
ASM_merge2:
  push rbp
  mov rbp, rsp
  push r12
  push r13
  push r14
  push r15


  ;rdi = ancho
  ;rsi = alto
  ;rdx = src1
  ;rcx = src2
  ;xmm0 = value
  shufps xmm0, xmm0, 0h                 ;xmm0 = value | value | value | value
  cvtps2dq xmm0, xmm0                   ;xmm0 = value | value | value | value  (en ints)
  mov r12, rdi              ;cant pixels por fila
  mov r13, rsi              ;r13 = cant filas
  xor r14, r14              ;contador filas
  xor r15, r15              ;contador pixels
  mov r8, rdx
  mov r9, rcx
  pxor xmm15, xmm15
  movdqu xmm14, [constante1]              ;xmm14 = 1 | 1 | 1 | 1
  psubd xmm14, xmm0                       ;xmm14 = 1 - value | 1 - value | 1 - value | 1 - value (en ints)
  
  .ciclofilas
   cmp r14, r13
   jz .fin
   xor r15, r15                         ;reseto pixels por fila     
        .ciclocolumnas
          ;SRC1
          movdqu xmm1, [r8]                     ; xmm1 = src1(i,j+0)| src1(i,j+1) | src1(i,j+2) | src1(i,j+3)
          
          ;PIXEL src1 1

          movdqu xmm2,xmm1
	  punpcklbw xmm2,xmm15
	  punpcklwd xmm2,xmm15                  ;xmm5 = p1_b | p1_g | p1_r | p1_a  (como ints)
	  

          ;PIXEL src1 2

          movdqu xmm3,xmm1
	  punpcklbw xmm3,xmm15
	  punpcklwd xmm3,xmm15                  ;xmm5 = p2_b | p2_g | p2_r | p2_a  (como ints)
	   

          ;PIXEL src1 3

          movdqu xmm4,xmm1
	  punpcklbw xmm4,xmm15
	  punpcklwd xmm4,xmm15                  ;xmm5 = p3_b | p3_g | p3_r | p3_a  (como ints)
	  
          ;PIXEL src1 4

          movdqu xmm5,xmm1
	  punpcklbw xmm5,xmm15
	  punpcklwd xmm5,xmm15   	        ; xmm5 = p4_b | p4_g | p4_r | p4_a  (como ints)

          ;SRC2
          movdqu xmm6, [r9]                     ; xmm6 = src2(i,j+0)| src2(i,j+1) | src2(i,j+2) | src2(i,j+3)


          ;PIXEL src2 1

          movdqu xmm7,xmm6
	  punpcklbw xmm7,xmm15
	  punpcklwd xmm7,xmm15                  ; xmm7 = p1_b | p1_g | p1_r | p1_a  (como ints)

          ;PIXEL src2 2

          movdqu xmm8,xmm6
	  punpcklbw xmm8,xmm15
	  punpcklwd xmm8,xmm15                  ; xmm8 = p2_b | p2_g | p2_r | p2_a  (como ints)

          ;PIXEL src2 3

          movdqu xmm9,xmm6
	  punpcklbw xmm9,xmm15
	  punpcklwd xmm9,xmm15                  ; xmm9 = p3_b | p3_g | p3_r | p3_a  (como ints)

          ;PIXEL src2 4

          movdqu xmm10,xmm6
	  punpcklbw xmm10,xmm15
	  punpcklwd xmm10,xmm15			; xmm10 = p4_b | p4_g | p4_r | p4_a  (como ints)

          ;HASTA ACA TENGO TODO ARMADITO
          ;SUMO CON FLOATS
          pmuldq xmm2, xmm0                      ;xmm2 src1 = p1_b * value| p1_g * value| p1_r * value| p1_a * value (como ints)
          pmuldq xmm7, xmm14                     ;xmm7 src2 = p1_b * (1 - value)| p1_g * (1 - value)| p1_r * (1 - value)| p1_a * (1 - value) (como ints)
          paddd xmm2, xmm7                       ;xmm2 = value * m1[j][i][k] + (1 - value ) * m2[j][i][k]

          pmuldq xmm3, xmm0                      ;xmm3 src1 = p2_b * value| p2_g * value| p2_r * value| p2_a * value (como ints)
          pmuldq xmm8, xmm14                     ;xmm8 src2 = p2_b * (1 - value)| p2_g * (1 - value)| p2_r * (1 - value)| p2_a * (1 - value) (como ints)
          paddd xmm3, xmm8                       ;xmm3 = value * m1[j][i+1][k] + (1 - value ) * m2[j][i+1][k]

          pmuldq xmm4, xmm0                      ;xmm4 src1 = p3_b * value| p3_g * value| p3_r * value| p3_a * value (como ints)
          pmuldq xmm9, xmm14                     ;xmm9 src2 = p3_b * (1 - value)| p3_g * (1 - value)| p3_r * (1 - value)| p3_a * (1 - value) (como ints)
          paddd xmm4, xmm9                       ;xmm4 = value * m1[j][i+2][k] + (1 - value ) * m2[j][i+2][k]

          pmuldq xmm5, xmm0                      ;xmm5 src1 = p4_b * value| p4_g * value| p4_r * value| p4_a * value (como ints)
          pmuldq xmm10, xmm14                    ;xmm10 src2 = p4_b * (1 - value)| p4_g * (1 - value)| p4_r * (1 - value)| p4_a * (1 - value) (como ints)
          paddd xmm5, xmm10                      ;xmm5 = value * m1[j][i+3][k] + (1 - value ) * m2[j][i+3][k]


          ;EMPAQUETO

          packusdw xmm2, xmm3
	  packusdw xmm4, xmm5
	  packuswb xmm2, xmm4                   
          
          ;COLOCO

          movdqu [r8], xmm2                     ;coloco
          add r15, 4                            ;copie 4 pixels mas
          cmp r12, r15                          ;termine con la fila?
          jz .cambiofila
          add r8, 16                            ;me muevo en src1
          add r9, 16                            ;me muevo en src2
          jmp .ciclocolumnas
          

          .cambiofila
            inc r14
            jmp .ciclofilas

  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp         
  ret
