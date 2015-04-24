	; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion HSL 1                                      ;
;                                                                           ;
; ************************************************************************* ;
extern rgbTOhsl
extern hslTOrgb

section .data
mascara0: db 0,0,0,0,0,0,0,0,F,F,F,F,0,0,0,0
mascara1: db 0,0,0,0,F,F,F,F,0,0,0,0,0,0,0,0
mascara2: db F,F,F,F,0,0,0,0,0,0,0,0,0,0,0,0
mascara3: dd 0,0,360,0
mascara4: dd 0,1,0,0
mascara5: dd 1,0,0,0
mascara6: db F,F,F,F,0,0,0,0,F,F,F,F,F,F,F,F
mascara7: db 0,0,0,0,F,F,F,F,F,F,F,F,F,F,F,F
mascara8: db F,F,F,F,F,F,F,F,0,0,0,0,F,F,F,F
; void ASM_hsl1(uint32_t w, uint32_t h, uint8_t* data, float hh, float ss, float ll)
global ASM_hsl1
ASM_hsl1:
  ;rdi = ancho en pixels
  ;rsi = alto 
  ;rdx = puntero imagen
  ;xmm0 = hh
  ;xmm1 = ss
  ;xmm2 = ll

  ;ASUMO QUE xmm0,xmm1,xmm2 tienen basura ademas de hh ss y ll asi que los limpio
  ;tienen que quedar xmm0 = 0 | 0 | hh | 0   xmm1 = 0 | ss | 0 | 0  xmm2 = ll | 0 | 0 | 0

  push rbp
  mov rbp, rsp
  push rbx
  push r12
  push r13
  push r14                             
  push r15                             
  sub rsp, 8

  xor r14                              ;contador filas
  xor r15                              ;contador columnas
  mov qword r12, rdi                   ;respaldo ancho en pixels
  mov qword r13, rsi                   ;respaldo alto
  mov qword rbx, rdx                   ;respaldo puntero a la imagen
  pand xmm0, [mascara0]                ;xmm0 = 0 | 0 | hh | 0
  movdqu xmm3, xmm0                    ;xmm3 = 0 | 0 | hh | 0 (xmm0 se usa como parametro para rgbtohsl)
  pand xmm1, [mascara1]                ;xmm1 = 0 | ss | 0 | 0
  pand xmm2, [mascara2]                ;xmm2 = ll | 0 | 0 | 0
  movdqu xmm15, [mascara3]             ;xmm15 = 0 | 0 | 360 | 0    (en ints)
  movdqu xmm14, [mascara4]             ;xmm14 = 0 | 1 | 0 | 0      (en ints)
  movdqu xmm13, [mascara5]             ;xmm13 = 1 | 0 | 0 | 0      (en ints)
  cvtdq2ps xmm15, xmm15                ;xmm15 = 0 | 0 | 360 | 0    (en floats)
  cvtdq2ps xmm14, xmm14                ;xmm14 = 0 | 1 | 0 | 0      (en floats)
  cvtdq2ps xmm13, xmm13                ;xmm13 = 1 | 0 | 0 | 0      (en floats)
  

  ciclofilas:
     cmp r14,r13                       ;termine?
     jz .fin
     xor r15, r15                      ;reseteo contador columnas
          
       ciclocolumnas:
            cmp r12, r15               ;termine con la fila?
            jz .avanzo
            mov rdi, rbx
            pxor xmm0, xmm0
            call rgbTOhsl              ;xmm0 = pi_l | pi_s | pi_h | pi_A
            
            ;SUPONGO QUE NO HAY MANERA DE PROCESAR MAS PIXELS, SI LLAMO 4 veces a RGBTOHSL ES COMO SI PROCESARA DE A 1, 4 VECES
            
            ; h 
            addps xmm0, xmm3           ;xmm0 = pi_l | pi_s | pi_h + hh | pi_A                         
            ; s
            addps xmm0, xmm2           ;xmm0 = pi_l | pi_s + ss | pi_h + hh | pi_A
            ; l
            addps xmm0, xmm1           ;xmm0 = pi_l + ll | pi_s + ss | pi_h + hh | pi_A   (como floats)

            cvtps2dq xmm0, xmm0        ;xmm0 = pi_l + ll | pi_s + ss | pi_h + hh | pi_A   (como ints, para comparar)
            movdqu xmm5, xmm0

          
            ;COMPARACIONES SOBRE H
            ;h + hh = 360?
            pcmpeqd xmm5, [mascara3]   ;pi_h+hh = 360? todo lo demas quede en 0 probablemente
            movdqu xmm6, xmm5          
            pand xmm6, [mascara0]      ; xmm6 = 0 | 0 | h+hh = 360? | 0
            ;h + hh > 360?
            movdqu xmm5, xmm0
            pcmpgtd xmm5, [mascara3]   ;pi_h+hh > 360?
            movdqu xmm7, xmm5          
            pand xmm7, [mascara0]      ; xmm7 = 0 | 0 | h+hh > 360? | 0
            ;h + hh = 0?
            movdqu xmm5, xmm0
            pcmpeqd xmm5, [mascara8]   ;pi_h+hh = 0?
            movdqu xmm8, xmm5          
            pand xmm8, [mascara0]      ; xmm8 = 0 | 0 | h+hh= 0? | 0
            jz .sumo360
            ;h + hh > 0?
            movdqu xmm5, xmm0
            pcmpgtd xmm5, [mascara8]   ;pi_h+hh > 0?
            movdqu xmm9, xmm5          
            pand xmm9, [mascara0]      ; xmm9 = 0 | 0 | h+hh>0? | 0
            
            ;PARA SABER SI h+hh <0 me fijo si h+hh>0 y si h+hh=0, los sumo y despues hago un pnand para negar, si da 1s es que es menor, sino era o mayor o igual
            ;PARA SABER SI h+hh >= 360 me fijo si h+hh=360 y si h+hh>360, hago pxor entre eso y me fijo si da 1s es que es alguna de las dos opciones sino es menor
            pxor xmm6, xmm7
            pand xmm6, [mascara0]          ;CREO QUE NO ES NECESARIO 
            pand xmm6, [mascara3]      ;xmm6 = 0 | 0 | 360 si h+hh>=360, 0 sino | 0
            pxor xmm8, xmm9               
            pnand xmm8, xmm8
            pand xmm8, [mascara0]      ;xmm8 = 0 | 0 | h+hh<0? | 0
            pand xmm8, [mascara3]      ;xmm8 = 0 | 0 | 360 si h+hh<0, 0 sino | 0
            movdqu xmm5, xmm0          ;queda pi_h + hh
            
            ;AHORA APLICO LOS CAMBIOS A h
            psubd xmm0, xmm6           ;xmm6 = pi_l + ll | pi_s + ss | pi_h+hh - 360 si pi_h+hh>=360, pi_h+hh sino | pi_A
            paddd xmm0, xmm8           ;xmm6 = pi_l + ll | pi_s + ss | pi_h+hh +360 si pi_h+hh<0, pi_h+hh sino | pi_A

            ;ACLARO QUE SOLO PUEDE PASAR 1 CASO DE LOS 2 ANTERIORES, osea que o hago +360 o -360 o queda pi_h+hh

            ;COMPARACIONES SOBRE S
            ;s+ss = 1?
            movdqu xmm5, xmm0
            pcmpeqd xmm5, [mascara4]
            movdqu xmm6, xmm5
            pand xmm6, [mascara1]      ;xmm6 = 0 | s+ss = 1? | 0 | 0
            ;s+ss > 1?
            movdqu xmm5, xmm0
            pcmpgtd xmm5, [mascara4]
            movdqu xmm7, xmm5
            pand xmm7, [mascara1]      ;xmm7 = 0 | s+ss>1? | 0 | 0
            ;s+ss = 0?
            movdqu xmm5, xmm0
            pcmpeqd xmm5, [mascara6]
            movdqu xmm8, xmm5
            pand xmm8, [mascara1]      ;xmm8 = 0 | s+ss=0? | 0 | 0
            ;s+ss > 0?
            movdqu xmm5, xmm0
            pcmpgtd xmm5, [mascara6]
            movdqu xmm9, xmm5
            pand xmm9, [mascara1]      ;xmm9 = 0 | s+ss>0? | 0 | 0

            ;EL PROCEDIMIENTO ES BASICAMENTE IGUAL QUE PARA H+HH PERO CON OTROS VALORES
            
            pxor xmm6, xmm7
            pand xmm6, [mascara4]      ;xmm6 = 0 | 1 si pi_s+ss >= 1, 0 sino | 0 | 0
            pxor xmm8, xmm9
            ;pnand xmm8, xmm8           ;xmm8 = 0 | 1s si s+ss<0 0s sino | 0 | 0
            movdqu xmm10, xmm0
            pand xmm8, xmm10           ;xmm8 = 0 | pi_s+ss si s+ss>=0, 0 sino | 0 | 0         
            pand xmm10, [mascara6]     ;xmm10 = pi_l + ll | 0 | pi_h+hh | pi_A
            pxor xmm10, xmm6           ;xmm10 = pi_l + ll | 1 si s+ss>=1, 0 sino | 0 | 0
            pxor xmm10, xmm8           ;xmm10 = pi_l + ll | 1 si s+ss>=1, 0 si s+ss<0, pi_s+ss sino | pi_h + hh | pi_A
            pand xmm10, [mascara1]     ;xmm10 = 0 | 1 si s+ss>=1, 0 si s+ss<0, pi_s+ss sino | 0 | 0
            
            ;APLICO CAMBIOS
            pxor xmm0, xmm10

            ;COMPARACIONES SOBRE L
            ;l+ll = 1?
            movdqu xmm5, xmm0
            pcmpeqd xmm5, [mascara5]
            movdqu xmm6, xmm5
            pand xmm6, [mascara2]      ;xmm6 = l+ll=1? | 0 | 0 | 0
            ;l+ll > 1?
            movdqu xmm5, xmm0
            pcmpgtd xmm5, [mascara5]
            movdqu xmm7, xmm5
            pand xmm7, [mascara2]      ;xmm7 = l+ll>1? | 0 | 0 | 0
            ;l+ll = 0?
            movdqu xmm5, xmm0
            pcmpeqd xmm5, [mascara7]
            movdqu xmm8, xmm5
            pand xmm8, [mascara2]      ;xmm8 = l+ll=0? | 0 | 0 | 0
            ;l+ll > 0?
            movdqu xmm5, xmm0
            pcmpgtd xmm5, [mascara7]
            movdqu xmm9, xmm5
            pand xmm9, [mascara2]      ;xmm9 = l+ll>0? | 0 | 0 | 0
            
            pxor xmm6, xmm7
            pand xmm6, [mascara5]      ;xmm6 = 1 si pi_l+ll>= 1, 0 sino | 0 | 0 | 0
            pxor xmm8, xmm9             ;xmm8 = 1s si pi_l+11>=0, 0s sino | 0 | 0 | 0
            ;pnand xmm8, xmm8           ;xmm8 = 1s si pi_l+ll<0, 0s sino | 0 | 0 | 0
            movdqu xmm10, xmm0
            pand xmm8, xmm10           ;xmm8 = pi_l+ll si l+ll>=0, 0 sino | 0 | 0 | 0
            pand xmm10, [mascara7]     ;xmm10 = 0 | pi_s+ss | pi_h+hh | pi_A
            pxor xmm10, xmm6           ;xmm10 = 1 si l+ll>=1, 0 sino | pi_s+ss | pi_h+hh | pi_A
            pxor xmm10, xmm8           ;xmm10 = pi_l+ll si l+ll>=0, 1 si l+ll>=1, 0 sino | pi_s+ss | pi_h+hh | pi_A
            pand xmm10, [mascara2]

            ;APLICO CAMBIOS
            pxor xmm0, xmm10           ;ACA DEBERIA TENER YA EL VALOR FINAL DE XMM0
            cvtdq2ps xmm0, xmm0        ;paso a float para pasarlo como parametro a hslTOrgb
            mov rdi, rdx               ;paso direccion del pixel
            call hslTOrgb              
           
            ;ACA YA TERMINE DE PROCESAR ESE PIXEL Y SE INSERTA EN LA IMAGEN

            add rbx, 4                 ;paso al pixel siguiente
            inc r15                    ;procese un pixel mas
            

            .avanzo:
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
  

