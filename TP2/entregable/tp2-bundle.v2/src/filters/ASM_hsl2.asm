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
mascara10: dd 0x0,0x0,0xFFFFFFFF,0x0
mascara11: dd 0x0,0xFFFFFFFF,0x0,0x0
mascara12: dd 0xFFFFFFFF,0x0,0x0,0x0
mascara13: dd 0xFFFFFFFF,0x0,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF
mascara14: dd 0xFFFFFFFF,0xFFFFFFFF,0x0,0xFFFFFFFF
mascara15: dd 0,1,0,0
mascara16; dd 0x0, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
mascara17: dd 0x0, 0x0, 0x0, -1.0
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
  pand xmm15, [mascara10]                  ;xmm15 = 0 | 0 | hh | 0
  movdqu xmm14, xmm1
  pand xmm14, [mascara11]                  ;xmm14 = 0 | ss | 0 | 0
  movdqu xmm13, xmm2 
  pand xmm13, [mascara12]                  ;xmm13 = ll | 0 | 0 | 0
  movq rbx, rdx                           ;respaldo imagen
 
   .ciclofilas:
     cmp r14,r13                       ;termine?
     jz .fin	
     xor r15, r15                      ;reseteo contador columnas
   

           .ciclocolumnas:
            cmp r12, r15                      ;termine con la fila?
            jz .avanzo
            movq xmm0, [rbx]                ;levanto 4 pixels xmm0 = 0 | 0 | p2 | p1
            movq xmm1, xmm0
            
            ;PIXEL 1

            punpcklbw xmm1, xmm12
            punpcklwd xmm1, xmm12             ; xmm1 = p1_b | p1_g | p1_r | p1_a
            call rgbAhsl
            
            ;ACA deberia tener en xmm1 = p1_l | p1_s | p1_h | p1_a
            movdqu xmm12, xmm1
            ;en xmm12 tengo el pixel 1
            
            ;PIXEL 2

            punpcklbw xmm1, xmm12
            punpckhwd xmm1, xmm12             ; xmm1 = p2_b | p2_g | p2_r | p2_a
            call rgbAhsl
            
            ;xmm1 = p2_l | p2_s | p2_h | p2_a
      
            ;APLICO SUMA A PIXEL 1
            ; h 
            addps xmm12, xmm15           ;xmm12 = pi_l | pi_s | pi_h + hh | pi_A                         
            ; s
            addps xmm12, xmm14           ;xmm12 = pi_l | pi_s + ss | pi_h + hh | pi_A
            ; l
            addps xmm12, xmm13           ;xmm12 = pi_l + ll | pi_s + ss | pi_h + hh | pi_A   (como floats)


            cvtps2dq xmm12, xmm12         ;xmm12 = pi_l + ll | pi_s + ss | pi_h + hh | pi_A   (como ints, para comparar)
            movdqu xmm5, xmm12

          

          
            ;COMPARACIONES SOBRE H
            ;h + hh = 360?
            pcmpeqd xmm5, [mascara7]   ;pi_h+hh = 360? todo lo demas quede en 0 probablemente
            movdqu xmm6, xmm5          
            pand xmm6, [mascara10]      ; xmm6 = 0 | 0 | h+hh = 360? | 0
            ;h + hh > 360?
            movdqu xmm5, xmm12
            pcmpgtd xmm5, [mascara7]   ;pi_h+hh > 360?
            movdqu xmm7, xmm5          
            pand xmm7, [mascara10]      ; xmm7 = 0 | 0 | h+hh > 360? | 0
            ;h + hh = 0?
            movdqu xmm5, xmm12
            pcmpeqd xmm5, [mascara14]   ;pi_h+hh = 0?
            movdqu xmm8, xmm5          
            pand xmm8, [mascara10]      ; xmm8 = 0 | 0 | h+hh= 0? | 0
            ;jz .sumo360
            ;h + hh > 0?
            movdqu xmm5, xmm12
            pcmpgtd xmm5, [mascara14]   ;pi_h+hh > 0?
            movdqu xmm9, xmm5          
            pand xmm9, [mascara10]      ; xmm9 = 0 | 0 | h+hh>0? | 0
            
            ;PARA SABER SI h+hh <0 me fijo si h+hh>0 y si h+hh=0, los sumo y despues hago un pnand para negar, si da 1s es que es menor, sino era o mayor o igual
            ;PARA SABER SI h+hh >= 360 me fijo si h+hh=360 y si h+hh>360, hago pxor entre eso y me fijo si da 1s es que es alguna de las dos opciones sino es menor
            pxor xmm6, xmm7
            pand xmm6, [mascara10]          ;CREO QUE NO ES NECESARIO 
            pand xmm6, [mascara7]      ;xmm6 = 0 | 0 | 360 si h+hh>=360, 0 sino | 0
            pxor xmm8, xmm9               
            pandn xmm8, xmm8
            pand xmm8, [mascara10]      ;xmm8 = 0 | 0 | h+hh<0? | 0
            pand xmm8, [mascara7]      ;xmm8 = 0 | 0 | 360 si h+hh<0, 0 sino | 0
            movdqu xmm5, xmm12          ;queda pi_h + hh
            
            ;AHORA APLICO LOS CAMBIOS A h
            psubd xmm12, xmm6           ;xmm6 = pi_l + ll | pi_s + ss | pi_h+hh - 360 si pi_h+hh>=360, pi_h+hh sino | pi_A
            paddd xmm12, xmm8           ;xmm6 = pi_l + ll | pi_s + ss | pi_h+hh +360 si pi_h+hh<0, pi_h+hh sino | pi_A

            ;ACLARO QUE SOLO PUEDE PASAR 1 CASO DE LOS 2 ANTERIORES, osea que o hago +360 o -360 o queda pi_h+hh

            ;COMPARACIONES SOBRE S
            ;s+ss = 1?
            movdqu xmm5, xmm12
            pcmpeqd xmm5, [mascara15]
            movdqu xmm6, xmm5
            pand xmm6, [mascara11]      ;xmm6 = 0 | s+ss = 1? | 0 | 0
            ;s+ss > 1?
            movdqu xmm5, xmm12
            pcmpgtd xmm5, [mascara15]
            movdqu xmm7, xmm5
            pand xmm7, [mascara11]      ;xmm7 = 0 | s+ss>1? | 0 | 0
            ;s+ss = 0?
            movdqu xmm5, xmm12
            pcmpeqd xmm5, [mascara6]
            movdqu xmm8, xmm5
            pand xmm8, [mascara11]      ;xmm8 = 0 | s+ss=0? | 0 | 0
            ;s+ss > 0?
            movdqu xmm5, xmm12
            pcmpgtd xmm5, [mascara6]
            movdqu xmm9, xmm5
            pand xmm9, [mascara11]      ;xmm9 = 0 | s+ss>0? | 0 | 0

            ;EL PROCEDIMIENTO ES BASICAMENTE IGUAL QUE PARA H+HH PERO CON OTROS VALORES
            
            pxor xmm6, xmm7
            pand xmm6, [mascara15]      ;xmm6 = 0 | 1 si pi_s+ss >= 1, 0 sino | 0 | 0
            pxor xmm8, xmm9
            ;pnand xmm8, xmm8           ;xmm8 = 0 | 1s si s+ss<0 0s sino | 0 | 0
            movdqu xmm10, xmm12
            pand xmm8, xmm10           ;xmm8 = 0 | pi_s+ss si s+ss>=0, 0 sino | 0 | 0         
            pand xmm10, [mascara13]     ;xmm10 = pi_l + ll | 0 | pi_h+hh | pi_A
            pxor xmm10, xmm6           ;xmm10 = pi_l + ll | 1 si s+ss>=1, 0 sino | 0 | 0
            pxor xmm10, xmm8           ;xmm10 = pi_l + ll | 1 si s+ss>=1, 0 si s+ss<0, pi_s+ss sino | pi_h + hh | pi_A
            pand xmm10, [mascara11]     ;xmm10 = 0 | 1 si s+ss>=1, 0 si s+ss<0, pi_s+ss sino | 0 | 0
            
            ;APLICO CAMBIOS
            pxor xmm12, xmm10

            ;COMPARACIONES SOBRE L
            ;l+ll = 1?
            movdqu xmm5, xmm12
            pcmpeqd xmm5, [mascara9]
            movdqu xmm6, xmm5
            pand xmm6, [mascara12]      ;xmm6 = l+ll=1? | 0 | 0 | 0
            ;l+ll > 1?
            movdqu xmm5, xmm12
            pcmpgtd xmm5, [mascara9]
            movdqu xmm7, xmm5
            pand xmm7, [mascara12]      ;xmm7 = l+ll>1? | 0 | 0 | 0
            ;l+ll = 0?
            movdqu xmm5, xmm12
            pcmpeqd xmm5, [mascara16]
            movdqu xmm8, xmm5
            pand xmm8, [mascara12]      ;xmm8 = l+ll=0? | 0 | 0 | 0
            ;l+ll > 0?
            movdqu xmm5, xmm12
            pcmpgtd xmm5, [mascara16]
            movdqu xmm9, xmm5
            pand xmm9, [mascara12]      ;xmm9 = l+ll>0? | 0 | 0 | 0
            
            pxor xmm6, xmm7
            pand xmm6, [mascara9]      ;xmm6 = 1 si pi_l+ll>= 1, 0 sino | 0 | 0 | 0
            pxor xmm8, xmm9             ;xmm8 = 1s si pi_l+11>=0, 0s sino | 0 | 0 | 0
            ;pnand xmm8, xmm8           ;xmm8 = 1s si pi_l+ll<0, 0s sino | 0 | 0 | 0
            movdqu xmm10, xmm12
            pand xmm8, xmm10           ;xmm8 = pi_l+ll si l+ll>=0, 0 sino | 0 | 0 | 0
            pand xmm10, [mascara16]     ;xmm10 = 0 | pi_s+ss | pi_h+hh | pi_A
            pxor xmm10, xmm6           ;xmm10 = 1 si l+ll>=1, 0 sino | pi_s+ss | pi_h+hh | pi_A
            pxor xmm10, xmm8           ;xmm10 = pi_l+ll si l+ll>=0, 1 si l+ll>=1, 0 sino | pi_s+ss | pi_h+hh | pi_A
            pand xmm10, [mascara12]

            ;APLICO CAMBIOS
            pxor xmm12, xmm10           ;ACA DEBERIA TENER YA EL VALOR FINAL DE XMM12
            cvtdq2ps xmm12, xmm12        ;paso a float para pasarlo como parametro a hslTOrgb

            
            ;ACA TERMINE CON EL PIXEL 1 LE FALTA PASAR A RGB NADA MAS

            ;APLICO SUMA A PIXEL 2
            ; h 
            addps xmm1, xmm15           ;xmm1 = pi_l | pi_s | pi_h + hh | pi_A                         
            ; s
            addps xmm1, xmm14           ;xmm1 = pi_l | pi_s + ss | pi_h + hh | pi_A
            ; l
            addps xmm1, xmm13           ;xmm1 = pi_l + ll | pi_s + ss | pi_h + hh | pi_A   (como floats)


            cvtps2dq xmm1, xmm1         ;xmm1 = pi_l + ll | pi_s + ss | pi_h + hh | pi_A   (como ints, para comparar)
            movdqu xmm5, xmm1

          

          
            ;COMPARACIONES SOBRE H
            ;h + hh = 360?
            pcmpeqd xmm5, [mascara7]   ;pi_h+hh = 360? todo lo demas quede en 0 probablemente
            movdqu xmm6, xmm5          
            pand xmm6, [mascara10]      ; xmm6 = 0 | 0 | h+hh = 360? | 0
            ;h + hh > 360?
            movdqu xmm5, xmm1
            pcmpgtd xmm5, [mascara7]   ;pi_h+hh > 360?
            movdqu xmm7, xmm5          
            pand xmm7, [mascara10]      ; xmm7 = 0 | 0 | h+hh > 360? | 0
            ;h + hh = 0?
            movdqu xmm5, xmm1
            pcmpeqd xmm5, [mascara14]   ;pi_h+hh = 0?
            movdqu xmm8, xmm5          
            pand xmm8, [mascara10]      ; xmm8 = 0 | 0 | h+hh= 0? | 0
            ;jz .sumo360
            ;h + hh > 0?
            movdqu xmm5, xmm1
            pcmpgtd xmm5, [mascara14]   ;pi_h+hh > 0?
            movdqu xmm9, xmm5          
            pand xmm9, [mascara10]      ; xmm9 = 0 | 0 | h+hh>0? | 0
            
            ;PARA SABER SI h+hh <0 me fijo si h+hh>0 y si h+hh=0, los sumo y despues hago un pnand para negar, si da 1s es que es menor, sino era o mayor o igual
            ;PARA SABER SI h+hh >= 360 me fijo si h+hh=360 y si h+hh>360, hago pxor entre eso y me fijo si da 1s es que es alguna de las dos opciones sino es menor
            pxor xmm6, xmm7
            pand xmm6, [mascara10]          ;CREO QUE NO ES NECESARIO 
            pand xmm6, [mascara7]      ;xmm6 = 0 | 0 | 360 si h+hh>=360, 0 sino | 0
            pxor xmm8, xmm9               
            pandn xmm8, xmm8
            pand xmm8, [mascara10]      ;xmm8 = 0 | 0 | h+hh<0? | 0
            pand xmm8, [mascara7]      ;xmm8 = 0 | 0 | 360 si h+hh<0, 0 sino | 0
            movdqu xmm5, xmm1          ;queda pi_h + hh
            
            ;AHORA APLICO LOS CAMBIOS A h
            psubd xmm1, xmm6           ;xmm1 = pi_l + ll | pi_s + ss | pi_h+hh - 360 si pi_h+hh>=360, pi_h+hh sino | pi_A
            paddd xmm1, xmm8           ;xmm1 = pi_l + ll | pi_s + ss | pi_h+hh +360 si pi_h+hh<0, pi_h+hh sino | pi_A

            ;ACLARO QUE SOLO PUEDE PASAR 1 CASO DE LOS 2 ANTERIORES, osea que o hago +360 o -360 o queda pi_h+hh

            ;COMPARACIONES SOBRE S
            ;s+ss = 1?
            movdqu xmm5, xmm1
            pcmpeqd xmm5, [mascara15]
            movdqu xmm6, xmm5
            pand xmm6, [mascara11]      ;xmm6 = 0 | s+ss = 1? | 0 | 0
            ;s+ss > 1?
            movdqu xmm5, xmm1
            pcmpgtd xmm5, [mascara15]
            movdqu xmm7, xmm5
            pand xmm7, [mascara11]      ;xmm7 = 0 | s+ss>1? | 0 | 0
            ;s+ss = 0?
            movdqu xmm5, xmm1
            pcmpeqd xmm5, [mascara6]
            movdqu xmm8, xmm5
            pand xmm8, [mascara11]      ;xmm8 = 0 | s+ss=0? | 0 | 0
            ;s+ss > 0?
            movdqu xmm5, xmm1
            pcmpgtd xmm5, [mascara6]
            movdqu xmm9, xmm5
            pand xmm9, [mascara11]      ;xmm9 = 0 | s+ss>0? | 0 | 0

            ;EL PROCEDIMIENTO ES BASICAMENTE IGUAL QUE PARA H+HH PERO CON OTROS VALORES
            
            pxor xmm6, xmm7
            pand xmm6, [mascara15]      ;xmm6 = 0 | 1 si pi_s+ss >= 1, 0 sino | 0 | 0
            pxor xmm8, xmm9
            ;pnand xmm8, xmm8           ;xmm8 = 0 | 1s si s+ss<0 0s sino | 0 | 0
            movdqu xmm10, xmm1
            pand xmm8, xmm10           ;xmm8 = 0 | pi_s+ss si s+ss>=0, 0 sino | 0 | 0         
            pand xmm10, [mascara13]     ;xmm10 = pi_l + ll | 0 | pi_h+hh | pi_A
            pxor xmm10, xmm6           ;xmm10 = pi_l + ll | 1 si s+ss>=1, 0 sino | 0 | 0
            pxor xmm10, xmm8           ;xmm10 = pi_l + ll | 1 si s+ss>=1, 0 si s+ss<0, pi_s+ss sino | pi_h + hh | pi_A
            pand xmm10, [mascara11]     ;xmm10 = 0 | 1 si s+ss>=1, 0 si s+ss<0, pi_s+ss sino | 0 | 0
            
            ;APLICO CAMBIOS
            pxor xmm1, xmm10

            ;COMPARACIONES SOBRE L
            ;l+ll = 1?
            movdqu xmm5, xmm1
            pcmpeqd xmm5, [mascara9]
            movdqu xmm6, xmm5
            pand xmm6, [mascara12]      ;xmm6 = l+ll=1? | 0 | 0 | 0
            ;l+ll > 1?
            movdqu xmm5, xmm1
            pcmpgtd xmm5, [mascara9]
            movdqu xmm7, xmm5
            pand xmm7, [mascara12]      ;xmm7 = l+ll>1? | 0 | 0 | 0
            ;l+ll = 0?
            movdqu xmm5, xmm1
            pcmpeqd xmm5, [mascara16]
            movdqu xmm8, xmm5
            pand xmm8, [mascara12]      ;xmm8 = l+ll=0? | 0 | 0 | 0
            ;l+ll > 0?
            movdqu xmm5, xmm1
            pcmpgtd xmm5, [mascara16]
            movdqu xmm9, xmm5
            pand xmm9, [mascara12]      ;xmm9 = l+ll>0? | 0 | 0 | 0
            
            pxor xmm6, xmm7
            pand xmm6, [mascara9]      ;xmm6 = 1 si pi_l+ll>= 1, 0 sino | 0 | 0 | 0
            pxor xmm8, xmm9             ;xmm8 = 1s si pi_l+11>=0, 0s sino | 0 | 0 | 0
            ;pnand xmm8, xmm8           ;xmm8 = 1s si pi_l+ll<0, 0s sino | 0 | 0 | 0
            movdqu xmm10, xmm1
            pand xmm8, xmm10           ;xmm8 = pi_l+ll si l+ll>=0, 0 sino | 0 | 0 | 0
            pand xmm10, [mascara16]     ;xmm10 = 0 | pi_s+ss | pi_h+hh | pi_A
            pxor xmm10, xmm6           ;xmm10 = 1 si l+ll>=1, 0 sino | pi_s+ss | pi_h+hh | pi_A
            pxor xmm10, xmm8           ;xmm10 = pi_l+ll si l+ll>=0, 1 si l+ll>=1, 0 sino | pi_s+ss | pi_h+hh | pi_A
            pand xmm10, [mascara12]

            ;APLICO CAMBIOS
            pxor xmm1, xmm10           ;ACA DEBERIA TENER YA EL VALOR FINAL DE XMM12
            cvtdq2ps xmm1, xmm1        ;paso a float para pasarlo como parametro a hslTOrgb
            
            

 

.fin:
  ret
  

;rgbAhsl (*src, *float dst)
rgbAhsl:

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

   

ret

;hslArgb ( *float src, *dst)
hslArgb:

        ;xmm12 = p_l | p_s | p_h | p_a
        ;fmod(h/60, 2) es hacer h/60 - ((h/60)/2)

        movdqu xmm2, xmm12 
        psrldq xmm2, 12      
        pand xmm2, [mascara0]   ; xmm2 = 0 | 0 | 0 | p1_l
        movdqu xmm3, xmm12
        psrldq xmm3, 8       
        pand xmm3, [mascara0]   ; xmm3 = 0 | 0 | 0 | p1_s
        movdqu xmm4, xmm12
        psrldq xmm4, 4
        pand xmm4, [mascara0]   ; xmm4 = 0 | 0 | 0 | p1_h
        pand xmm12, [mascara0]  ; xmm12 = 0 | 0 | 0 | p1_a

        ;CALCULO C

        movdqu xmm11, xmm2      ; xmm11 = 0 | 0 | 0 | p1_l    (respaldo para calcular m)

        mulps xmm2, [mascara5]   ; xmm2 = 0 | 0 | 0 | p1_l * 2
        addps xmm2, [mascara17]  ; xmm2 = 0 | 0 | 0 | (p1_l * 2) -1  SUME UN -1 (supongo que cuenta como restar)
        
        ;CALCULO FABS((p1_l *2) -1)  = max ( ((p1_l *2) -1) , - ((p1_l *2) -1))
        movdqu xmm5, xmm2        ; xmm5 = 0 | 0 | 0 | (p1_l *2) -1
        mulps xmm5, [mascara17]  ; xmm5 = 0 | 0 | 0 | (p1_l *2) -1
        maxps xmm5, xmm2         ; xmm5 = 0 | 0 | 0 | fabs((p1_l *2) -1)

        movdqu xmm6, [mascara9]  ; xmm6 = 1.0 | 0 | 0 | 0
        psrldq xmm6, 12          ; xmm6 = 0 | 0 | 0 | 1.0
        subps xmm6, xmm5         ; xmm6 = 0 | 0 | 0 | 1.0 - fabs((p1_l *2) -1)
        mulps xmm6, xmm3         ; xmm6 = 0 | 0 | 0 | (1.0 - fabs((p1_l *2) - 1 ) * p1_s

        ; xmm6 = 0 | 0 | 0 | C
        ;XMM5 queda libre
        ;CALCULO X
        ;CALCULO FMOD( p1_h / 60.0, 2.0)
        movdqu xmm5, xmm4
        divps xmm5, [mascara1]     ;xmm5 = 0 | 0 | 0 | p1_h / 60.0
        movdqu xmm7, xmm5          ;xmm7 = 0 | 0 | 0 | p1_h / 60.0
        divps xmm7, [mascara5]     ;xmm7 = 0 | 0 | 0 | (p1_h / 60.0) /2.0
        roundps xmm8, xmm7, 1      ;xmm7 = 0 | 0 | 0 | (p1_h / 60.0) /2.0 redondeado hacia abajo (el 1 indica redondeo hacia abajo)
        subps xmm5, xmm8           ;xmm5 = 0 | 0 | 0 | fmod( p1_h / 60.0, 2.0)
        addps xmm5, [mascara17]    ;xmm5 = 0 | 0 | 0 | fmod( p1_h / 60.0, 2.0) -1.0
        movdqu xmm8, [mascara9]
        psrldq xmm8, 12            ;xmm8 = 0 | 0 | 0 | 1.0
        subps xmm8, xmm5           ;xmm8 = 0 | 0 | 0 | 1.0 - fmod( p1_h / 60.0, 2.0) -1.0
        




         


        








