	; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion HSL 1                                      ;
;                                                                           ;
; ************************************************************************* ;
extern rgbTOhsl
extern hslTOrgb
extern malloc
extern free
section .data
align 16
maskHH: dd 0x0,0xFFFFFFFF,0x0,0x0              ;le
maskSS: dd 0x0,0x0,0xFFFFFFFF,0x0              ;le
maskLL: dd 0x0,0x0,0x0,0xFFFFFFFF              ;le
mask360i: dd 0,360,0,0                           ;le
maskSSUnoi: dd 0,0,1,0                             ;le
maskLLunoi: dd 0,0,0,1                             ;le
mascara6: dd 0xFFFFFFFF,0xFFFFFFFF,0x0,0xFFFFFFFF   ;le
mascara7: dd 0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0x0   ;le
mascara8: dd 0xFFFFFFFF,0x0,0xFFFFFFFF,0xFFFFFFFF
maskSSUnof: dd 0.0,0.0,1.0,0.0
maskLLUnof: dd 0.0,0.0,0.0,1.0
section .text
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


  xor r14, r14                         ;contador filas
  xor r15, r15                         ;contador columnas
  mov qword r12, rdi                   ;respaldo ancho en pixels
  mov qword r13, rsi                   ;respaldo alto
  mov qword rbx, rdx                   ;respaldo puntero a la imagen
  pslldq xmm0,4
  pand xmm0, [maskHH]                ;xmm0 = 0 | 0 | hh | 0
  movdqu xmm3, xmm0                    ;xmm3 = 0 | 0 | hh | 0 (xmm0 se usa como parametro para rgbtohsl)
  pslldq xmm1,8
  pand xmm1, [maskSS]                ;xmm1 = 0 | ss | 0 | 0
  pslldq xmm2,12
  pand xmm2, [maskLL]                ;xmm2 = ll | 0 | 0 | 0
  ;movdqu xmm15, [mask360i]            ;xmm15 = 0 | 0 | 360 | 0    (en ints)
  ;movdqu xmm14, [maskSSUnoi]            ;xmm14 = 0 | 1 | 0 | 0      (en ints)
  ;movdqu xmm13, [maskLLunoi]            ;xmm13 = 1 | 0 | 0 | 0      (en ints)
  ;cvtdq2ps xmm15, xmm15               ;xmm15 = 0 | 0 | 360 | 0    (en floats)
  ;cvtdq2ps xmm14, xmm14               ;xmm14 = 0 | 1 | 0 | 0      (en floats)
  ;cvtdq2ps xmm13, xmm13               ;xmm13 = 1 | 0 | 0 | 0      (en floats)
  mov qword rdi, 16                    ;pido 16 bytes para guardar HSL
  sub rsp,16
  movdqu [rsp], xmm3                    ;push xmm3
  sub rsp,16
  movdqu [rsp], xmm1                    ;push xmm1
  sub rsp,16
  movdqu [rsp], xmm2                    ;push xmm2
  call malloc                       ;rax = puntero a la direccion donde voy a guardar HSL
  mov r8, rax                          ;r8 = puntero a la memoria reservada para HSL
  movdqu xmm2, [rsp]                    ;pop xmm2
  add rsp,16
  movdqu xmm1, [rsp]                    ;pop xmm1
  add rsp,16
  movdqu xmm3, [rsp]                    ;pop xmm3
  add rsp,16
  .ciclofilas:
     cmp r14,r13                       ;termine?
     jz .fin	
     xor r15, r15                      ;reseteo contador columnas
          
       .ciclocolumnas:
            cmp r12, r15               ;termine con la fila?
            jz .avanzo
            mov rdi, rbx               ;puntero al pixel
            ;pxor xmm0, xmm0
            mov rsi, r8                ;puntero a donde quiero que guarde p_l | p_s | p_h | p_a
            push r8
            sub rsp,8
            sub rsp,16
            movdqu [rsp], xmm3          ;push xmm3
            sub rsp,16
            movdqu [rsp], xmm1          ;push xmm1
            sub rsp,16
            movdqu [rsp], xmm2          ;push xmm2
            call rgbTOhsl              ;xmm0 = pi_l | pi_s | pi_h | pi_A
            movdqu xmm2, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm1, [rsp]          ;pop xmm1
            add rsp,16
            movdqu xmm3, [rsp]          ;pop xmm3
            add rsp,16
            add rsp,8
            pop r8
            
            movdqu xmm0, [r8]         ;xmm0 = pi_l | pi_s | pi_h | pi_A
            ;SUPONGO QUE NO HAY MANERA DE PROCESAR MAS PIXELS, SI LLAMO 4 veces a RGBTOHSL ES COMO SI PROCESARA DE A 1, 4 VECES
            ; h 
            addps xmm0, xmm3           ;xmm0 = pi_l | pi_s | pi_h + hh | pi_A                         
            ; s
            addps xmm0, xmm2           ;xmm0 = pi_l | pi_s + ss | pi_h + hh | pi_A
            ; l
            addps xmm0, xmm1           ;xmm0 = pi_l + ll | pi_s + ss | pi_h + hh | pi_A   (como floats)

            movdqu xmm15, xmm0         ;backup xmm0 para futura suma o resta 
            movdqu xmm14, xmm15 
            roundps xmm14, xmm14, 1

            cvttps2dq xmm0, xmm0        ;xmm0 = pi_l + ll | pi_s + ss | pi_h + hh | pi_A   (como ints, para comparar)
            cvtps2dq xmm14, xmm14       
            

          
            ;COMPARACIONES SOBRE H
            ;h + hh = 360?
            movdqu xmm5, xmm0
            pcmpeqd xmm5, [mask360i]   ;pi_h+hh = 360? todo lo demas quede en 0 probablemente
            movdqu xmm6, xmm5          
            pand xmm6, [maskHH]      ; xmm6 = 0 | 0 | h+hh = 360? | 0
            ;h + hh > 360?
            movdqu xmm5, xmm0
            pcmpgtd xmm5, [mask360i]   ;pi_h+hh > 360?
            movdqu xmm7, xmm5          
            pand xmm7, [maskHH]      ; xmm7 = 0 | 0 | h+hh > 360? | 0
            ;h + hh = 0?
            movdqu xmm5, xmm14
            pcmpeqd xmm5, [mascara8]   ;pi_h+hh = 0?
            movdqu xmm8, xmm5          
            pand xmm8, [maskHH]      ; xmm8 = 0 | 0 | h+hh= 0? | 0
            ;jz .sumo360
            ;h + hh > 0?
            movdqu xmm5, xmm14
            pcmpgtd xmm5, [mascara8]   ;pi_h+hh > 0?
            movdqu xmm9, xmm5          
            pand xmm9, [maskHH]      ; xmm9 = 0 | 0 | h+hh>0? | 0
            
            ;PARA SABER SI h+hh <0 me fijo si h+hh>0 y si h+hh=0, los sumo y despues hago un pnand para negar, si da 1s es que es menor, sino era o mayor o igual
            ;PARA SABER SI h+hh >= 360 me fijo si h+hh=360 y si h+hh>360, hago pxor entre eso y me fijo si da 1s es que es alguna de las dos opciones sino es menor
            pxor xmm6, xmm7
            pand xmm6, [maskHH]          ;CREO QUE NO ES NECESARIO 
            pand xmm6, [mask360i]      ;xmm6 = 0 | 0 | 360 si h+hh>=360, 0 sino | 0
            pxor xmm8, xmm9               
            pxor xmm8, [maskHH]      ;xmm8 = 0 | 0 | h+hh<0? | 0
            ;pand xmm8, [maskHH]     ;xmm8 = 0 | 0 | h+hh<0? | 0
            pand xmm8, [mask360i]      ;xmm8 = 0 | 0 | 360 si h+hh<0, 0 sino | 0
            
            ;AHORA APLICO LOS CAMBIOS A h
            cvtdq2ps xmm6,xmm6         ;convierto a float xmm6
            cvtdq2ps xmm8,xmm8         ;convierto a float xmm8

            psubd xmm15, xmm6           ;xmm6 = pi_l + ll | pi_s + ss | pi_h+hh - 360 si pi_h+hh>=360, pi_h+hh sino | pi_A
            paddd xmm15, xmm8           ;xmm6 = pi_l + ll | pi_s + ss | pi_h+hh +360 si pi_h+hh<0, pi_h+hh sino | pi_A
            
            ;ACLARO QUE SOLO PUEDE PASAR 1 CASO DE LOS 2 ANTERIORES, osea que o hago +360 o -360 o queda pi_h+hh

            ;COMPARACIONES SOBRE S
            ;s+ss = 1?
            movdqu xmm5, xmm0
            pcmpeqd xmm5, [maskSSUnoi]
            movdqu xmm6, xmm5
            pand xmm6, [maskSS]      ;xmm6 = 0 | s+ss = 1? | 0 | 0
            ;s+ss > 1?
            movdqu xmm5, xmm0
            pcmpgtd xmm5, [maskSSUnoi]
            movdqu xmm7, xmm5
            pand xmm7, [maskSS]      ;xmm7 = 0 | s+ss>1? | 0 | 0
            ;s+ss = 0?
            movdqu xmm5, xmm14
            pcmpeqd xmm5, [mascara6]
            movdqu xmm8, xmm5
            pand xmm8, [maskSS]      ;xmm8 = 0 | s+ss=0? | 0 | 0
            ;s+ss > 0?
            movdqu xmm5, xmm14
            pcmpgtd xmm5, [mascara6]
            movdqu xmm9, xmm5
            pand xmm9, [maskSS]      ;xmm9 = 0 | s+ss>0? | 0 | 0

            ;EL PROCEDIMIENTO ES BASICAMENTE IGUAL QUE PARA H+HH PERO CON OTROS VALORES
            
            pxor xmm6, xmm7             ;xmm6 = 0 |  pi_s+ss >= 1?| 0 | 0
            movdqu xmm13, xmm6          ;xmm13 = xmm6
            pand xmm6, [maskSSUnof]     ;xmm6 = 0|1.0 si pi_s+ss >= 1? sino 0|0|0 
            pandn xmm13, xmm15          ;xmm13 = pi_l + ll | 0 si pi_s+ss >= 1? s+ss si no | CORRECTOHH | pi_A   (como floats)
            pxor xmm13, xmm6            ;xmm13 = pi_l + ll | 1.0 si pi_s+ss >= 1? s+ss si no | CORRECTOHH | pi_A   (como floats)

            pxor xmm8, xmm9             ;xmm8 = 0 |  pi_s+ss >= 0?| 0 | 0
            pxor xmm8, [mascara6]       ;xmm8 = TRUE |  pi_s+ss >= 0?| TRUE | TRUE
            pand xmm13, xmm8            ;xmm13 = pi_l + ll | 1.0 (si pi_s+ss >= 1? y pi_s+ss >= 0?), s+ss si(si pi_s+ss < 1? y pi_s+ss >= 0?), 0 sino | CORRECTOHH | pi_A   (como floats)
            

            ; pxor xmm8, xmm9            ;xmm8 = 0 | 1 si pi_s+ss >= 0, 0 sino | 0 | 0
            ; ;pnand xmm8, xmm8                                                                         ;xmm8 = 0 | 1s si s+ss<0 0s sino | 0 | 0
            ; movdqu xmm10, xmm0
            ; pand xmm8, xmm10           ;xmm8 = 0 | pi_s+ss si s+ss>=0, 0 sino | 0 | 0         
            ; pand xmm10, [mascara6]     ;xmm10 = pi_l + ll | 0 | pi_h+hh | pi_A
            ; pxor xmm10, xmm6           ;xmm10 = pi_l + ll | 1 si s+ss>=1, 0 sino | 0 | 0
            ; pxor xmm10, xmm8           ;xmm10 = pi_l + ll | 1 si s+ss>=1, 0 si s+ss<0, pi_s+ss sino | pi_h + hh | pi_A
            ; pand xmm10, [maskSS]     ;xmm10 = 0 | 1 si s+ss>=1, 0 si s+ss<0, pi_s+ss sino | 0 | 0
            
            ;APLICO CAMBIOS
            movdqu xmm15, xmm13         ;;xmm13 = pi_l + ll | CORRECTOSS| CORRECTOHH | pi_A   (como floats)

            ;COMPARACIONES SOBRE L
            ;l+ll = 1?
            movdqu xmm5, xmm0
            pcmpeqd xmm5, [maskLLunoi]
            movdqu xmm6, xmm5
            pand xmm6, [maskLL]      ;xmm6 = l+ll=1? | 0 | 0 | 0
            ;l+ll > 1?
            movdqu xmm5, xmm0
            pcmpgtd xmm5, [maskLLunoi]
            movdqu xmm7, xmm5
            pand xmm7, [maskLL]      ;xmm7 = l+ll>1? | 0 | 0 | 0
            ;l+ll = 0?
            movdqu xmm5, xmm14
            pcmpeqd xmm5, [mascara7]
            movdqu xmm8, xmm5
            pand xmm8, [maskLL]      ;xmm8 = l+ll=0? | 0 | 0 | 0
            ;l+ll > 0?
            movdqu xmm5, xmm14
            pcmpgtd xmm5, [mascara7]
            movdqu xmm9, xmm5
            pand xmm9, [maskLL]      ;xmm9 = l+ll>0? | 0 | 0 | 0
            

            pxor xmm6, xmm7             ;xmm6 = pi_l+ll >= 1? | 0 | 0 | 0
            movdqu xmm13, xmm6          ;xmm13 = xmm6
            pand xmm6, [maskLLUnof]     ;xmm6 = 1.0 si pi_l+ll >= 1? sino 0|0|0|0 
            pandn xmm13, xmm15          ;xmm13 = 0 si pi_l+ll >= 1? l+ll si no  | CORRECTOSS | CORRECTOHH | pi_A   (como floats)
            pxor xmm13, xmm6            ;xmm13 = 1.0 si pi_l+ll >= 1? l+ll si no | CORRECTOSS | CORRECTOHH | pi_A   (como floats)

            pxor xmm8, xmm9             ;xmm8 = pi_l+ll >= 0? | 0 | 0 | 0
            pxor xmm8, [mascara7]       ;xmm8 = |  pi_s+ss >= 0?|TRUE | TRUE | TRUE
            pand xmm13, xmm8            ;xmm13 = 1.0 (si pi_l+ll >= 1? y pi_l+ll >= 0?), l+ll si(si pi_l+ll < 1? y pi_l+ll >= 0?), 0 sino | CORRECTOSS | CORRECTOHH | pi_A   (como floats)


            ;pxor xmm6, xmm7
            ;pand xmm6, [maskLLunoi]      ;xmm6 = 1 si pi_l+ll>= 1, 0 sino | 0 | 0 | 0
            ;pxor xmm8, xmm9             ;xmm8 = 1s si pi_l+11>=0, 0s sino | 0 | 0 | 0
            ;pnand xmm8, xmm8           ;xmm8 = 1s si pi_l+ll<0, 0s sino | 0 | 0 | 0
            ;movdqu xmm10, xmm0
            ;pand xmm8, xmm10           ;xmm8 = pi_l+ll si l+ll>=0, 0 sino | 0 | 0 | 0
            ;pand xmm10, [mascara7]     ;xmm10 = 0 | pi_s+ss | pi_h+hh | pi_A
            ;pxor xmm10, xmm6           ;xmm10 = 1 si l+ll>=1, 0 sino | pi_s+ss | pi_h+hh | pi_A
            ;pxor xmm10, xmm8           ;xmm10 = pi_l+ll si l+ll>=0, 1 si l+ll>=1, 0 sino | pi_s+ss | pi_h+hh | pi_A
            ;pand xmm10, [maskLL]

            ;APLICO CAMBIOS
             movdqu xmm15, xmm13         ;;xmm13 = CORRECTOSLL | CORRECTOSS| CORRECTOHH | pi_A   (como floats)
            ;cvtdq2ps xmm0, xmm0        ;paso a float para pasarlo como parametro a hslTOrgb
            movdqu [r8], xmm15         ;a partir de la direccion indicada por rsi guardo el HSL ya procesado
            ;mov rdi, rdx               ;paso direccion del pixel
            mov rdi, r8               ;paso la dir del pixel en HSL
            mov rsi, rbx               ;paso la dir para que almacene el pixel convertido en RGB
            push r8;
            sub rsp,8
            sub rsp,16
            movdqu [rsp], xmm3          ;push xmm3
            sub rsp,16
            movdqu [rsp], xmm1          ;push xmm1
            sub rsp,16
            movdqu [rsp], xmm2          ;push xmm2
            call hslTOrgb
            movdqu xmm2, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm1, [rsp]          ;pop xmm1
            add rsp,16
            movdqu xmm3, [rsp]          ;pop xmm3
            add rsp,16
            add rsp,8
            pop r8              
           
            ;ACA YA TERMINE DE PROCESAR ESE PIXEL Y SE INSERTA EN LA IMAGEN

            add rbx, 4                 ;paso al pixel siguiente
            inc r15                    ;procese un pixel mas
            jmp .ciclocolumnas
            

            .avanzo:
              inc r14
              jmp .ciclofilas
            
            
            
          
            
 
            
.fin:
  mov rdi, r8
  call free                     ;libero los 16 bytes
  add rsp, 8
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret
  

