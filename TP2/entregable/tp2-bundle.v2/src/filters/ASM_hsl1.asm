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
  push r14                             ;contador filas
  push r15                             ;contador columnas
  
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
            mov rdi, [rbx]
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

            ;h + hh = 360?
            .h:
            pcmpeqd xmm5, [mascara3]   ;pi_h+hh = 360? todo lo demas quede en 0 probablemente
            jz .resto360
            ;h + hh > 360?
            movdqu xmm5, xmm0
            pmcpgtd xmm5, [mascara3]   ;pi_h+hh > 360?
            jz .resto360
            ;h + hh = 0?
            movdqu xmm5, xmm0
            pcmpeqd xmm5, [mascara8]   ;pi_h+hh = 0?
            jz .sumo360
            ;h + hh > 0?
            movdqu xmm5, xmm0
            pmcpgtd xmm5, [mascara8]   ;pi_h+hh > 0?
            jz .sumo360
            movdqu xmm5, xmm0          ;queda pi_h + hh

            .resto360
             movdqu xmm5,xmm0  
             psubd xmm5, [mascara3]    ;pi_h+hh - 360
             jmp .s
           
            .sumo360
             movdqu xmm5,xmm0
             paddd xmm5, [mascara3]    ;pi_h+hh+360
             jmp .s
            
            .s:
           
            


       
     
  ret
  

