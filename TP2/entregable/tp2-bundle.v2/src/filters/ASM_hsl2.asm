; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion HSL 2                                      ;
;                                                                           ;
; ************************************************************************* ;

section .data
mascara0: dd 0xFFFFFFFF, 0x0, 0x0, 0x0           ;le
mascara1: dd 60.0, 0x0, 0x0, 0x0                 ;le
mascara2: dd 510.0, 0x0, 0x0, 0x0                  ;le
mascara3: dd 0x0, 0x0, 0x0, 255.0001             ;le
mascara4: dd 6.0, 0x0, 0x0, 0x0                  ;le
mascara5: dd 2.0, 0x0, 0x0, 0x0                  ;le
mascara6: dd 4.0, 0x0, 0x0, 0x0                  ;le
mascara7: dd 0x0, 360.0, 0x0, 0x0                ;le
mascara8: dd 0x0, 0x0, 0x0, 2.0                  ;le
mascara9: dd 0x0, 0x0, 0x0, 1.0                  ;le
mascara10: dd 0x0,0xFFFFFFFF,0x0,0x0             ;le
mascara11: dd 0x0,0x0,0xFFFFFFFF,0x0             ;le
mascara12: dd 0x0,0x0,0x0,0xFFFFFFFF             ;le
mascara13: dd 0xFFFFFFFF,0xFFFFFFFF,0x0,0xFFFFFFFF      ;le
mascara14: dd 0xFFFFFFFF,0x0,0xFFFFFFFF,0xFFFFFFFF      ;le
mascara15: dd 0,0,1,0
mascara16: dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x0   ;le
mascara17: dd -1.0, 0x0, 0x0, 0x0                     ;le
mascara18: dd 0, 255.0, 255.0, 255.0,                  ;le
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
  add rsp, 8
  
  pxor xmm12, xmm12              
  mov r12, rdi                            ;cantidad pixels por fila
  xor r13, r13                            ;contador filas
  mov r14, rsi                            ; r14 = cantidad filas
  xor r15, r15                            ;contador columnas
  movdqu xmm15, xmm0
  pand xmm15, [mascara10]                  ;xmm15 = 0 | 0 | hh | 0
  movdqu xmm14, xmm1
  pand xmm14, [mascara11]                  ;xmm14 = 0 | ss | 0 | 0
  movdqu xmm13, xmm2 
  pand xmm13, [mascara12]                  ;xmm13 = ll | 0 | 0 | 0
  mov rbx, rdx                           ;respaldo imagen
 
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
            cvtdq2ps xmm12, xmm12        ;paso a float para pasarlo como parametro a hslArgb

            
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
            pxor xmm1, xmm10           ;ACA DEBERIA TENER YA EL VALOR FINAL DE PIXEL 2
            cvtdq2ps xmm1, xmm1        ;paso a float para pasarlo como parametro a hslArgb
            call hslArgb               ;xmm11 = el pixel 2 que pase como parametro ahora en RGB
            movdqu xmm1, xmm12         ; xmm1 = p1_l | p1_s | p1_h | p1_a
            movdqu xmm12, xmm11        ; xmm12 = p2_b | p2_g | p2_r | p2_a
            call hslArgb               ;xmm11 = pixel 1 que pase como parametro ahora en RGB
            
            ;EMPAQUETO
            pxor xmm1, xmm1
            packusdw xmm11, xmm12
            packuswb xmm11, xmm1
            ;en xmm11 = 0 | 0 | p2 | p1  ya procesados y todo bonito
            ;INSERTO
            movq [rbx], xmm11
            
            add r15, 2               ;procese 2 pixels
            add rbx, 2               ;me muevo 2 pixels en la imagen
            jmp .ciclocolumnas


           .avanzo:
               inc r13              ;procese 1 fila mas
               jmp .ciclofilas

            
            
            

 

.fin:
  sub rsp, 8
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret
  

;rgbAhsl (*src, *float dst)
rgbAhsl:
; aca me llega en xmm1 un pixel con cada uno de los a r g b ocupando dw 

            movdqu xmm2, xmm1
            psrldq xmm2, 4                    
            pand xmm2, [mascara0]             ; xmm2 = 0 | 0 | 0 |  p1_r
            movdqu xmm3, xmm1
            psrldq xmm3, 8
            pand xmm3, [mascara0]             ; xmm3 = 0 | 0 | 0 | p1_g
            movdqu xmm4, xmm1
            psrldq xmm4, 12
            pand xmm4, [mascara0]             ; xmm4 = 0 | 0 | 0 | p1_b

;hasta aca prepare los pixeles 

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
            cvtdq2ps xmm7, xmm7                ; xmm7 = 0 | 0 | 0 | d (en floats)

;xmm2,3,4 r g b respectivamente xmm5 tiene max xmm6 tiene el min xmm7 tiene la d 
            pxor xmm8, xmm8
            ptest xmm7, xmm8                  ; d = 0?
            jz .h 
            ;CALCULO H
          
            ;G-B
            movdqu xmm8, xmm3
            psubd xmm8, xmm4                 ; xmm8 = 0 | 0 | 0 | g-b
            cvtdq2ps xmm8, xmm8               ; xmm8 = 0 | 0 | 0 | g-b (en floats)
            divps xmm8, xmm7                  ; xmm8 = 0 | 0 | 0 | (g-b)/d
            addps xmm8, [mascara4]            ; xmm8 = 0 | 0 | 0 | (g-b)/d + 6
            mulps xmm8, [mascara1]            ; xmm8 = 0 | 0 | 0 | ((g-b)/d + 6) * 60 

            ;B-R
            movdqu xmm9, xmm4
            psubd xmm9, xmm2                 ; xmm9 = 0 | 0 | 0 | b-r
            cvtdq2ps xmm9, xmm9               ; xmm9 = 0 | 0 | 0 | b-r (en floats)
            divps xmm9, xmm7                  ; xmm9 = 0 | 0 | 0 | (b-r)/d
            addps xmm9, [mascara5]            ; xmm9 = 0 | 0 | 0 | (b-r)/d + 2
            mulps xmm9, [mascara1]            ; xmm9 = 0 | 0 | 0 | ((b-r)/d + 2) * 60 

            ;R-G
            movdqu xmm10, xmm2
            psubd xmm10, xmm3                 ; xmm10 = 0 | 0 | 0 | r-g
            cvtdq2ps xmm10, xmm10              ; xmm10 = 0 | 0 | 0 | r-g (en floats)
            divps xmm10, xmm7                  ; xmm10 = 0 | 0 | 0 | (r-g)/d
            addps xmm10, [mascara6]            ; xmm10 = 0 | 0 | 0 | (r-g)/d + 4
            mulps xmm10, [mascara1]            ; xmm10 = 0 | 0 | 0 | ((r-g)/d + 4) * 60 

            movdqu xmm11, xmm5
            pcmpeqd xmm11, xmm2                ; xmm11 = 0 | 0 | 0 | max= r?
            pand xmm8, xmm11                   ; xmm8 = 0 | 0 | 0 | ((g-b)/d + 6) * 60 SI MAX = R SINO 0

            movdqu xmm11, xmm5
            pcmpeqd xmm11, xmm3                 ; xmm11 = 0 | 0 | 0 | max= g?
            pand xmm9, xmm11                   ; xmm9 = 0 | 0 | 0 | ((b-r)/d + 2) * 60 SI MAX = G SINO 0

            movdqu xmm11, xmm5
            pcmpeqd xmm11, xmm4                ; xmm11 = 0 | 0 | 0 | max= b?
            pand xmm10, xmm11                  ; xmm10 = 0 | 0 | 0 | ((r-g)/d + 4) * 60 SI MAX = B SINO 0

;aca no hice else if sino if solo, xmm8, xmm9, xmm10 contienen los posibles resultados
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
            
            
            pandn xmm11, [mascara0]            ; xmm11 = 0 | 0 | 0 | not(max = min)
            ;pandn xmm11, xmm11                 ; xmm11 = 0 | 0 | 0 | not(max = min)
            pslldq xmm11, 4                    ; xmm11 = 0 | 0 | not(max = min) | 0
            pxor xmm11, [mascara0]             ; xmm11 = 0 | 0 | not(max = min) | 1s


           .hfin:
            
            ;ACA xmm8, xmm9, xmm10 quedan libres
            pand xmm1, xmm11                  ; xmm1 = 0 | 0 | h | p1_a  O 0 | 0 | 0 | p1_a (si h = 0 )
            movdqu xmm8, xmm1

            pcmpeqd xmm8, [mascara7]          ; xmm8 = 0 | 0 | h=360? | p1_a

            movdqu xmm9, xmm1                 ; xmm9 = 0 | 0 | h | p1_a

            ;idem arriba 

            pcmpgtd xmm9, [mascara7]          ; xmm9 = 0 | 0 | h>360? | basura
            pxor xmm9, xmm8                   ; xmm9 = 0 | 0 | h>=360? | basura
            pand xmm9, [mascara7]             ; xmm9 = 0 | 0 | 360 si h>=360 0 sino | 0
            subps xmm1, xmm9                  ; xmm1 = 0 | 0 | h | p1_a
            
            ;YA CALCULE H

            ;CALCULO L

            movdqu xmm8, xmm5
            paddd xmm8, xmm6                 ; xmm8 = 0 | 0 | 0 | max + min
            cvtdq2ps xmm8, xmm8

            divps xmm8, [mascara2]           ; xmm8 = 0 | 0 | 0 | (max + min) / 510 (float)
            pslldq xmm8, 8                   ; xmm8 = 0 | l | 0 | 0
            pxor xmm1, xmm8                  ; xmm1 = 0 | l | h | p1_a

            ;CALCULO S

            pslldq xmm8, 4                   ; xmm8 = l | 0 | 0 | 0    (float)
            mulps xmm8, [mascara8]           ; xmm8 = l*2 | 0 | 0 | 0 (float)
            subps xmm8, [mascara9]           ; xmm8 = l*2-1 | 0 | 0 | 0 (float)

            ;no lo creo segun lo que entendi funciona con la fpu y modifica stack 0 asi q probablemente uses max de nuevo
            ;la de max me gusto, en una linea andeas 0x7fff (reseteo el signo)

            fabs                             ; no se bien comom funciona pero supongamos que deja fabs xmm8
            pslldq xmm7, 12                  ; xmm7 = d | 0 | 0 | 0
            divps xmm7, xmm8                 ; xmm7 = d /fabs(l*2-1) | 0 | 0 | 0
            divps xmm7, [mascara3]           ; xmm7 = d / fabs (l*2-1) / 255.0001 | 0 | 0 | 0 (float)
         
            pcmpeqd xmm5, xmm6               ; xmm5 = 0 | 0 | 0 | max = min?

            ;probablemente el mismo error que antes  con respecto al not 
            ;creo q la idea es q si max = min? true pasa el valor si  no es 0 
            ; por lo tanto esa linea de pandn no es necesaria

            pandn xmm5, xmm5                 ; xmm5 = 0 | 0 | 0 | not (max = min?)
            pslldq xmm5, 12                  ; xmm5 = not (max = min?) | 1s | 1s | 1s
            
            pxor xmm1, xmm7            
            pand xmm1, xmm5                  ; xmm1 = p1_l | p1_s | p1_h | p1_a
            
            ;PIXEL 1 PASADO A HSL
            ret
            .h0:

            movdq xmm11, [mascara0]                      ; xmm11 = 0 | 0 | 0 | 1s 
            jmp .hfin 
              


;hslArgb ( *float src, *dst)
hslArgb:

        ;xmm12 = p_l | p_s | p_h | p_a
        ;fmod(h/60, 2) es hacer h/60 - ((h/60)/2)
        ;esto es casi cierto te falta el *2 osea fmod(x,y)= x - truncar(x/y)*y

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
; hasta aca prepare los pixeles xmm(2,3,4,12)->(l s h a) en ese orden.
        ;CALCULO C

        movdqu xmm11, xmm2      ; xmm11 = 0 | 0 | 0 | p1_l    (respaldo para calcular m)

        mulps xmm2, [mascara5]   ; xmm2 = 0 | 0 | 0 | p1_l * 2
        addps xmm2, [mascara17]  ; xmm2 = 0 | 0 | 0 | (p1_l * 2) -1  SUME UN -1 (supongo que cuenta como restar)
        ;USAR PSIGN
        ;CALCULO FABS((p1_l *2) -1)  = max ( ((p1_l *2) -1) , - ((p1_l *2) -1))
        movdqu xmm5, xmm2        ; xmm5 = 0 | 0 | 0 | (p1_l *2) -1
        mulps xmm5, [mascara17]  ; xmm5 = 0 | 0 | 0 | (p1_l *2) -1                       TENDRIA QUE SER UN ADDPS? SINO ESTOY MULTIPLICANDO POR -1
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

        ;aca falto multiplicar por lo que puse arriba

        subps xmm5, xmm8           ;xmm5 = 0 | 0 | 0 | fmod( p1_h / 60.0, 2.0)
        addps xmm5, [mascara17]    ;xmm5 = 0 | 0 | 0 | fmod( p1_h / 60.0, 2.0) -1.0
        ;FALTA ALGO PARA FMOD TENDRIA QUE SER p1_h/60 - p1_h/60/2 * p1_h/60
        movdqu xmm8, [mascara9]
        psrldq xmm8, 12            ;xmm8 = 0 | 0 | 0 | 1.0
        subps xmm8, xmm5           ;xmm8 = 0 | 0 | 0 | 1.0 - fmod( p1_h / 60.0, 2.0) -1.0
        mulps xmm8, xmm6           ;xmm8 = 0 | 0 | 0 | X
        
        ;CALCULO M

        movdqu xmm5, xmm6          ; xmm5 = 0 | 0 | 0 | C
        divps xmm5, [mascara5]     ; xmm5 = 0 | 0 | 0 | C/2

        ; aca xmm2 me parece que lo backupeaste en xmm11 y dsp lo modificas
        ;osea falto restaurarlo

        subps xmm2, xmm5           ; xmm2 = 0 | 0 | 0 | M

        ;xmm6 = 0 | 0 | 0 | C   xmm8 = 0 | 0 | 0 | X    xmm2 = 0 | 0 | 0 | M
        ;XMMS LIBRES : xmm5, xmm3, xmm7, xmm10, xmm11
        pslldq xmm8, 4             ; xmm8 = 0 | 0 | X | 0
        pxor xmm8, xmm6            ; xmm8 = 0 | 0 | X | C

        ;AHORA xmm6 ESTA LIBRE

        shufps xmm4, xmm4, 0h      ; xmm4 = h | h | h | h         para las comparaciones
        movdqu xmm9, [mascara1]    ; xmm9 = 0 | 0 | 0 | 60.0   para ir sumando
        shufps xmm9, xmm9, 0h      ; xmm9 = 60.0 | 60.0 | 60.0 | 60.0
        pxor xmm10, xmm10          ; xmm10 = 0 | 0 | 0 | 0
        cmpps xmm10, xmm4, 010b     ; xmm10 = 0<= h? | 0<= h? | 0<= h? | 0<=h?
        
        ;VOY A USAR XMM11 PARA GUARDAR EL RESULTADO DE TODAS ESTAS COMPARACIONES
        ;CREO QUE POR COMO LO HAGO NO SE PISAN LOS VALORES

        ;aca si se pisa todo porque los casos son no disjuntos por ejem sea h = 70
        ; h es mayor a 0 y mayor a 60 y el resto de los casos no importan
        ;pero entonces en xmm11 tengo primero x|0|c|0 y a eso le hago un or con
        ;c|x|0|0 imaginate c = 0x0001 y x = 0x0010 el or me deja 0x0011|x|c|0 tiene sentido? 

        ; P = p_b | p_g | p_r | p_a
        ;si 0<=h <60 P = X | 0 | C | 0
        shufps xmm6, xmm8, 01100010b        ; 01 es pongo X, 10 es pongo 0, 00 es pongo C y 10 es pongo 0
        pand xmm10, xmm6                    ; si 0<= h entonces xmm10 = X | 0 | C | 0, sino xmm10 = 0 | 0 | 0 | 0
        movdqu xmm11, xmm10                 ; pongo resultado en xmm11
        ;si 60<=h P = C | 0 | X | 0
        ;pxor xmm10, xmm10                   ; xmm10 = 0 | 0 | 0 | 0
        ;addps xmm10, xmm9                   ; xmm10 = 60.0 | 60.0 | 60.0 | 60.0
        movdqu xmm10, xmm9                   ; xmm10 = 60.0 | 60.0 | 60.0 | 60.0
        cmpps xmm10, xmm4, 010b             ; xmm10 = 60.0 <= h? | 60.0 <= h? | 60.0 <= h? | 60.0 <= h?
        shufps xmm6, xmm8, 00100110b        ; 00 es pongo C, 10 es pongo 0, 01 es pongo X, 10 es pongo 0
        pand xmm10, xmm6                    ; si 60.0<= h entonces xmm10 = C | 0 | X | 0 sino xmm10 = 0 | 0 | 0 | 0
        pxor xmm11, xmm10                   ; acumulo res
        ;si 120<=h P = C | X | 0 | 0        
        movdqu xmm10, xmm9                   ; xmm10 = 60.0 | 60.0 | 60.0 | 60.0
        addps xmm10, xmm9                    ; xmm10 = 120.0 | 120.0 | 120.0 | 120.0
        ;movdqu xmm10, xmm9                   ; xmm10 = 120.0 | 120.0 | 120.0 | 120.0
        cmpps xmm10, xmm4, 010b              ; xmm10 = 120<= h? | 120<= h? | 120<= h? | 120<= h?
        shufps xmm6, xmm8, 00011010b         ; 00 es pongo C, 01 es pongo X, 10 es pongo 0, 10 es pongo
        pand xmm10, xmm6                     ; si 120.0 <= h entonces xmm10 = C | X | 0 | 0, sino 0s
        pxor xmm11, xmm10                    ; acumulo res
        ;si 180<=h P = X | C | 0 | 0
        movdqu xmm10, xmm9                   ; xmm10 = 60.0 | 60.0 | 60.0 | 60.0
        addps xmm10, xmm9
        addps xmm10, xmm9                    ; xmm10 = 180.0 | 180.0 | 180.0 | 180.0
        cmpps xmm10, xmm4, 010b              ; xmm10 = 180.0 <= h? | 180.0 <= h? | 180.0 <= h? | 180.0 <= h?
        shufps xmm6, xmm8, 01001010b         ; 01 es pongo X, 00 es pongo C, 10 es pongo 0, 10 es pongo 0
        pand xmm10, xmm6                     ; si 180.0 <= h entonces xmm10 = X | C | 0 | 0, sino 0s
        pxor xmm11, xmm10                    ; acumulo res
        ;si 240<=h P = 0 | C | X | 0
        movdqu xmm10, xmm9                   ; xmm10 = 60.0 | 60.0 | 60.0 | 60.0
        addps xmm10, xmm9
        addps xmm10, xmm9
        addps xmm10, xmm9                    ; xmm10 = 240.0 | 240.0 | 240.0 | 240.0
        cmpps xmm10, xmm4, 010b              ; xmm10 = 240.0<=h? | 240.0<=h? | 240.0<=h? | 240.0<=h?
        shufps xmm6, xmm8, 10000110b          ; 10 es pongo 0, 00 es pongo C, 01 es pongo X, 10 es pongo 0
        pand xmm10, xmm6                     ; si 240.0 <=h entonces xmm10 = 0 | C | X | 0, sino 0s
        pxor xmm11, xmm10                    ; acumulo res
        ;si 300<=h P = 0 | X | C | 0
        movdqu xmm10, xmm9                   ; xmm10 = 60.0 | 60.0 | 60.0 | 60.0
        addps xmm10, xmm9
        addps xmm10, xmm9 
        addps xmm10, xmm9
        addps xmm10, xmm9                    ; xmm10 = 300.0 | 300.0 | 300.0 | 300.0
        cmpss xmm10, xmm4, 010b              ; xmm10 = 300.0<=h? | 300.0<=h? | 300.0<=h? | 300.0<=h?
        shufps xmm6, xmm8, 10010010b          ; 10 es pongo 0, 01 es pongo X, 00 es pongo C, 10 es pongo 0
        pand xmm10, xmm6                     ; si 300.0 <= h entonces xmm10 = 0 | X | C | 0 sino 0s
        pxor xmm11, xmm10                    ; acumulo res

        ;ACA YA TENGO EN XMM11 CASI RGB, me falta a cada componente sumarle M y multiplicar por 255
        shufps xmm2, xmm2, 01h                ; xmm2 = M | M | M | 0   ACA CONFIO UN POQUITO EN QUE LO DEJA ASI
        addps xmm11, xmm2                    ; xmm11 = b+m | g+m | r+m | 0
        mulps xmm11, [mascara18]             ; xmm11 = (b+m)*255 | (g+m)*255 | (r+m)*255 | 0
        cvtps2dq xmm11, xmm11                ; xmm11 = p_b | p_g | p_r | 0
        pxor xmm11, xmm12                    ; xmm11 = p_b | p_g | p_r | p_a
        
        ;TERMINE DE PASAR A RGB

ret
        
        
          




         


        








