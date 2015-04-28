; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion HSL 2                                      ;
;                                                                           ;
; ************************************************************************* ;

section .data
mascara0: dd 0x0, 0x0, 0x0, 0xFFFFFFFF
mascara1: dd 0x0, 0x0, 0x0, 60.0
mascara2: dd 0x0, 0x0, 0x0, 510
mascara3: dd 255.0001, 0x0, 0x0, 0x0
mascara4: dd 0x0, 0x0, 0x0, 6.0
mascara5; dd 0x0, 0x0, 0x0, 2.0
mascara6: dd 0x0, 0x0, 0x0, 4.0
mascara7: dd 0x0, 0x0, 360, 0x0
mascara8: dd 2.0, 0x0, 0x0, 0x0
mascara9: dd 1.0, 0x0, 0x0, 0x0
;mascara10; dd 0x0, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
;mascara10: dd 0xFFFFFFFF, 0x0, 0x0, 0x0
section .text
; void ASM_hsl2(uint32_t w, uint32_t h, uint8_t* data, float hh, float ss, float ll)
global ASM_hsl2
ASM_hsl2:

  ;rdi = ancho en pixels
  ;rsi = altura (cant filas)
  ;rdx = puntero imagen
  ;xmm0 = hh
  ;xmm1 = ss
  ;xmm2 = ll

  push rbp
  mov rbp, rsp
  push rbx
  push r12
  push r13
  push r14
  push r15
  
  pxor xmm12, xmm12              
  xor r12, r12                            ;contador filas
  xor r13, r13                            ;contador columnas
  xor r14, r14
  xor r15, r15
  movdqu xmm15, xmm0
  pand xmm15, [mascara0]                  ;xmm15 = 0 | 0 | 0 | hh
  movdqu xmm14, xmm1
  pand xmm14, [mascara0]                  ;xmm14 = 0 | 0 | 0 | ss
  movdqu xmm13, xmm2 
  pand xmm13, [mascara0]                  ;xmm13 = 0 | 0 | 0 | ll
  movq rbx, rdx                           ;respaldo imagen
 
   .ciclofilas:
     cmp r14,r13                       ;termine?
     jz .fin	
     xor r15, r15                      ;reseteo contador columnas
   

           .ciclocolumnas:
            cmp r12, r15                      ;termine con la fila?
            jz .avanzo
            movdqu xmm0, [rbx]                ;levanto 4 pixels xmm0 = p4 | p3 | p2 | p1
            movdqu xmm1, xmm0
            
            ;PIXEL 1

            punpcklbw xmm1, xmm12
            punpcklwd xmm1, xmm12             ; xmm1 = p1_b | p1_g | p1_r | p1_a
            movdqu xmm2, xmm1
            psrldq xmm2, 4                    
            pand xmm2, [mascara0]             ; xmm2 = 0 | 0 | 0 |  p1_r
            movdqu xmm3, xmm1
            psrldq xmm3, 8
            pand xmm3, [mascara0]             ; xmm3 = 0 | 0 | 0 | p1_g
            movdqu xmm4, xmm1
            psrldq xmm4, 12
            pand xmm4, [mascara0]             ; xmm4 = 0 | 0 | 0 | p1_b

            ;BUSCO MAXIMO
            movdqu xmm5, xmm2                 ; xmm5 = 0 | 0 | 0 | p1_r
            pmaxud xmm5, xmm3                 ; xmm5 = 0 | 0 | 0 | max(p1_r, p1_g)
            pmaxud xmm5, xmm4                 ; xmm5 = 0 | 0 | 0 | max(p1_r, p1_g, p1_b)

            ;BUSCO MINIMO
            movdqu xmm6, xmm2                 ; xmm6 = 0 | 0 | 0 | p1_r
            pminud xmm6, xmm3                 ; xmm6 = 0 | 0 | 0 | min(p1_r, p1_g)
            pminud xmm6, xmm4                 ; xmm6 = 0 | 0 | 0 | min(p1_r, p1_g, p1_b)

            ;CALCULO D

            movdqu xmm7, xmm5
            psubd xmm7, xmm6                  ; xmm7 = 0 | 0 | 0 | d = max(b,g,r) - min(b,g,r)
            cvtdq2ps xmm7 xmm7                ; xmm7 = 0 | 0 | 0 | d (en floats)

            ;CALCULO H
          
            ;G-B
            movdqu xmm8, xmm3
            psubd, xmm8, xmm4                 ; xmm8 = 0 | 0 | 0 | g-b
            cvtdq2ps xmm8, xmm8               ; xmm8 = 0 | 0 | 0 | g-b (en floats)
            divps xmm8, xmm7                  ; xmm8 = 0 | 0 | 0 | (g-b)/d
            addps xmm8, [mascara4]            ; xmm8 = 0 | 0 | 0 | (g-b)/d + 6
            mulps xmm8, [mascara1]            ; xmm8 = 0 | 0 | 0 | ((g-b)/d + 6) * 60 

            ;B-R
            movdqu xmm9, xmm4
            psubd, xmm9, xmm2                 ; xmm9 = 0 | 0 | 0 | b-r
            cvtdq2ps xmm9, xmm9               ; xmm9 = 0 | 0 | 0 | b-r (en floats)
            divps xmm9, xmm7                  ; xmm9 = 0 | 0 | 0 | (b-r)/d
            addps xmm9, [mascara5]            ; xmm9 = 0 | 0 | 0 | (b-r)/d + 2
            mulps xmm9, [mascara1]            ; xmm9 = 0 | 0 | 0 | ((b-r)/d + 2) * 60 

            ;R-G
            movdqu xmm10, xmm2
            psubd, xmm10, xmm3                 ; xmm10 = 0 | 0 | 0 | r-g
            cvtdq2ps xmm10, xmm10              ; xmm10 = 0 | 0 | 0 | r-g (en floats)
            divps xmm10, xmm7                  ; xmm10 = 0 | 0 | 0 | (r-g)/d
            addps xmm10, [mascara6]            ; xmm10 = 0 | 0 | 0 | (r-g)/d + 4
            mulps xmm10, [mascara1]            ; xmm10 = 0 | 0 | 0 | ((r-g)/d + 4) * 60 

            movdqu xmm11, xmm5
            pcmpeqd xmm11, xmm2                ; xmm11 = 0 | 0 | 0 | max= r?
            pand xmm8, xmm11                   ; xmm8 = 0 | 0 | 0 | ((g-b)/d + 6) * 60 SI MAX = R SINO 0

            movdqu xmm11, xmm5
            pcmeqd xmm11, xmm3                 ; xmm11 = 0 | 0 | 0 | max= g?
            pand xmm9, xmm11                   ; xmm9 = 0 | 0 | 0 | ((b-r)/d + 2) * 60 SI MAX = G SINO 0

            movdqu xmm11, xmm5
            pcmpeqd xmm11, xmm4                ; xmm11 = 0 | 0 | 0 | max= b?
            pand xmm10, xmm11                  ; xmm10 = 0 | 0 | 0 | ((r-g)/d + 4) * 60 SI MAX = B SINO 0

            ;pxor xmm1, xmm1;                   
            ;movdqu xmm1, xmm8
            ;pxor xmm1, xmm9
            ;pxor xmm1, xmm10                   

            movdqu xmm11, xmm8
            pxor xmm11, xmm9
            pxor xmm11, xmm10
            pslldq xmm11, 4                    ; xmm11 = 0 | 0 | rdo comparacion max = r, g o b | 0
            pand xmm1, [mascara0]              ; xmm1 = 0 | 0 | 0 | p1_a
            pxor xmm1, xmm11                   ; xmm1 = 0 | 0 | rdo comparacion max = r, g o b | p1_a

            movdqu xmm11, xmm5                 ; xmm11 = 0 | 0 | 0 | max
            pcmpeqd xmm11, xmm6                ; xmm11 = 0 | 0 | 0 | max = min?
            pandn xmm11, xmm11                 ; xmm11 = 0 | 0 | 0 | not(max = min)
            pslldq xmm11, 4                    ; xmm11 = 0 | 0 | not(max = min) | 0
            pxor xmm11, [mascara0]             ; xmm11 = 0 | 0 | not(max = min) | 1s

            ;ACA xmm8, xmm9, xmm10 quedan libres
            pand xmm1, xmm11                  ; xmm1 = 0 | 0 | h | p1_a
            movdqu xmm8, xmm1
            pcmpeqd xmm8, [mascara7]          ; xmm8 = 0 | 0 | h=360? | p1_a

            movdqu xmm9, xmm1                 ; xmm9 = 0 | 0 | h | p1_a
            pcmpgtd xmm9, [mascara7]          ; xmm9 = 0 | 0 | h>360? | basura
            pxor xmm9, xmm8                   ; xmm9 = 0 | 0 | h>=360? | basura
            pand xmm9, [mascara7]             ; xmm9 = 0 | 0 | 360 si h>=360 0 sino | 0
            cvtdq2ps xmm9, xmm9               ; convierto a float
            subps xmm1, xmm9                  ; xmm1 = 0 | 0 | h | p1_a
            
            ;YA CALCULE H

            ;CALCULO L

            movdqu xmm8, xmm5
            paddd xmm8, xmm6                 ; xmm8 = 0 | 0 | 0 | max + min
            cvtdq2ps xmm8, xmm8
            divps xmm8, [mascara2]           ; xmm8 = 0 | 0 | 0 | (max + min) / 510 (float)
            pslldq xmm8, 8                   ; xmm8 = 0 | l | 0 | 0
            pxor xmm1, xmm8                  ; xmm8 = 0 | l | h | p1_a

            ;CALCULO S

            pslldq xmm8, 4                   ; xmm8 = l | 0 | 0 | 0    (float)
            mulps xmm8, [mascara8]           ; xmm8 = l*2 | 0 | 0 | 0 (float)
            subps xmm8, [mascara9]           ; xmm8 = l*2-1 | 0 | 0 | 0 (float)
            fabs                             ; no se bien comom funciona pero supongamos que deja fabs xmm8
            pslldq xmm7, 12                  ; xmm7 = d | 0 | 0 | 0
            divps xmm7, xmm8                 ; xmm7 = d /fabs(l*2-1) | 0 | 0 | 0
            divps xmm7, [mascara3]           ; xmm7 = d / fabs (l*2-1) / 255.0001 | 0 | 0 | 0 (float)
         
            pcmpeqd xmm5, xmm6               ; xmm5 = 0 | 0 | 0 | max = min?
            pandn xmm5, xmm5                 ; xmm5 = 0 | 0 | 0 | not (max = min?)
            pslldq xmm5, 12                  ; xmm5 = not (max = min?) | 1s | 1s | 1s
            
            pxor xmm1, xmm7            
            pand xmm1, xmm5                  ; xmm1 = p1_l | p1_s | p1_h | p1_a
            
            ;PIXEL 1 PASADO A HSL



 

.fin:
  ret
  

