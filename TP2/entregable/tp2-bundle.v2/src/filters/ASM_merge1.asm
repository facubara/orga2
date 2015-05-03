; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Merge 1                                    ;
;                                                                           ;
; ************************************************************************* ;

section .data
align 16
constante1: times 4 dd 1
mascara: dd 0xFFFFFFFF, 0x0, 0x0, 0x0
mascara1: dd 1.0, 0, 0, 0
section .text

; void ASM_merge1(uint32_t w, uint32_t h, uint8_t* data1, uint8_t* data2, float value)
global ASM_merge1
ASM_merge1:
;MODIFICA data1
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
  pxor xmm13, xmm13
  movdqu xmm13, xmm0                      ;xmm13 = 0 | 0 | 0 | value
  pand xmm13, [mascara]
  shufps xmm13, xmm13, 1h              ;xmm13 = value | value | value | 0
  addps xmm13, [mascara1]              ;xmm13 = value | value | value | 1.0       (floats)
  ;shufps xmm0, xmm0, 0h                 ;xmm0 = value | value | value | value
  movdqu xmm0, xmm13                   ;xmm0 = value | value | value | 1.0
  mov r12, rdi              ;cant pixels por fila
  mov r13, rsi              ;r13 = cant filas
  xor r14, r14              ;contador filas
  xor r15, r15              ;contador pixels
  mov r8, rdx               ;imagen 1
  mov r9, rcx               ;imagen 2
  pxor xmm15, xmm15
  movdqu xmm14, [mascara1]              ;xmm14 = 0 | 0 | 0 | 1.0
  shufps xmm14, xmm14, 0h               ;xmm14 = 1.0 | 1.0 | 1.0 | 1.0    (floats)
  ;cvtdq2ps xmm14, xmm14                    ;paso a float
  subps xmm14, xmm0                       ;xmm14 = 1.0 - value | 1.0 - value | 1.0 - value | 0 (en floats)
  
  .ciclofilas:
   cmp r14, r13
   jz .fin
   xor r15, r15                         ;reseto pixels por fila     
        .ciclocolumnas:
          ;SRC1
          movdqu xmm1, [r8]                   ; xmm1 = src1(i,j+0)| src1(i,j+1) | src1(i,j+2) | src1(i,j+3)
          
          ;PIXEL src1 1

          movdqu xmm2,xmm1
	  punpcklbw xmm2,xmm15
	  punpcklwd xmm2,xmm15
	  cvtdq2ps xmm2,xmm2			; xmm2 = p1_b | p1_g | p1_r | p1_a  (como floats)

          ;PIXEL src1 2

          movdqu xmm3,xmm1
	  punpcklbw xmm3,xmm15
	  punpckhwd xmm3,xmm15
	  cvtdq2ps xmm3,xmm3			; xmm3 = p2_b | p2_g | p2_r | p2_a  (como floats)

          ;PIXEL src1 3

          movdqu xmm4,xmm1
	  punpckhbw xmm4,xmm15
	  punpcklwd xmm4,xmm15
	  cvtdq2ps xmm4,xmm4			; xmm4 = p3_b | p3_g | p3_r | p3_a  (como floats)

          ;PIXEL src1 4

          movdqu xmm5,xmm1
	  punpckhbw xmm5,xmm15
	  punpckhwd xmm5,xmm15
	  cvtdq2ps xmm5,xmm5			; xmm5 = p4_b | p4_g | p4_r | p4_a  (como floats)

          ;SRC2
          movdqu xmm6, [r9]                  ; xmm6 = src2(i,j+0)| src2(i,j+1) | src2(i,j+2) | src2(i,j+3)


          ;PIXEL src2 1

          movdqu xmm7,xmm6
	  punpcklbw xmm7,xmm15
	  punpcklwd xmm7,xmm15
	  cvtdq2ps xmm7,xmm7			; xmm7 = p1_b | p1_g | p1_r | p1_a  (como floats)

          ;PIXEL src2 2

          movdqu xmm8,xmm6
	  punpcklbw xmm8,xmm15
	  punpckhwd xmm8,xmm15
	  cvtdq2ps xmm8,xmm8			; xmm8 = p2_b | p2_g | p2_r | p2_a  (como floats)

          ;PIXEL src2 3

          movdqu xmm9,xmm6
	  punpckhbw xmm9,xmm15
	  punpcklwd xmm9,xmm15
	  cvtdq2ps xmm9,xmm9			; xmm9 = p3_b | p3_g | p3_r | p3_a  (como floats)

          ;PIXEL src2 4

          movdqu xmm10,xmm6
	  punpckhbw xmm10,xmm15
	  punpckhwd xmm10,xmm15
	  cvtdq2ps xmm10,xmm10			; xmm10 = p4_b | p4_g | p4_r | p4_a  (como floats)

          ;HASTA ACA TENGO TODO ARMADITO
          ;SUMO CON FLOATS
          mulps xmm2, xmm0                      ;xmm2 src1 = p1_b * value| p1_g * value| p1_r * value| p1_a * 1 (como floats)
          mulps xmm7, xmm14                     ;xmm7 src2 = p1_b * (1 - value)| p1_g * (1 - value)| p1_r * (1 - value)| p1_a * (1 - 1) (como floats)
          addps xmm2, xmm7                      ;xmm2 = value * m1[j][i][k] + (1 - value ) * m2[j][i][k]

          mulps xmm3, xmm0                      ;xmm3 src1 = p2_b * value| p2_g * value| p2_r * value| p2_a * 1 (como floats)
          mulps xmm8, xmm14                     ;xmm8 src2 = p2_b * (1 - value)| p2_g * (1 - value)| p2_r * (1 - value)| p2_a * (1 - 1) (como floats)
          addps xmm3, xmm8                      ;xmm3 = value * m1[j][i+1][k] + (1 - value ) * m2[j][i+1][k]

          mulps xmm4, xmm0                      ;xmm4 src1 = p3_b * value| p3_g * value| p3_r * value| p3_a * 1 (como floats)
          mulps xmm9, xmm14                     ;xmm9 src2 = p3_b * (1 - value)| p3_g * (1 - value)| p3_r * (1 - value)| p3_a * (1 - 1) (como floats)
          addps xmm4, xmm9                      ;xmm4 = value * m1[j][i+2][k] + (1 - value ) * m2[j][i+2][k]

          mulps xmm5, xmm0                      ;xmm5 src1 = p4_b * value| p4_g * value| p4_r * value| p4_a * 1 (como floats)
          mulps xmm10, xmm14                    ;xmm10 src2 = p4_b * (1 - value)| p4_g * (1 - value)| p4_r * (1 - value)| p4_a * (1 - 1) (como floats)
          addps xmm5, xmm10                     ;xmm5 = value * m1[j][i+3][k] + (1 - value ) * m2[j][i+3][k]
          ;LA COMPONENTE A SE MANTIENE IGUAL QUE EN M1, PORQUE 1 - 1 = 0
          ;PASO A INT

          cvttps2dq xmm2, xmm2                   ;xmm2 en int
          cvttps2dq xmm3, xmm3                   ;xmm3 en int
          cvttps2dq xmm4, xmm4                   ;xmm4 en int
          cvttps2dq xmm5, xmm5                   ;xmm5 en int

          ;EMPAQUETO

          packusdw xmm2, xmm3
	  packusdw xmm4, xmm5
	  packuswb xmm2, xmm4                   
          
          ;COLOCO

          movdqu [r8], xmm2                     ;coloco
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
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp         
  ret
