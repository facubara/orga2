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
mask360i: dd 360,360,360,360                           ;le
maskUnoi: dd 1,1,1,1                             ;le
mascara8: dd 0x0,0x0,0x0,0x0
maskUnof: dd 1.0,1.0,1.0,1.0
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


  xor r14, r14                         ;contador filas
  xor r15, r15                         ;contador columnas
  mov qword r12, rdi                   ;respaldo ancho en pixels
  mov qword r13, rsi                   ;respaldo alto
  mov qword rbx, rdx                   ;respaldo puntero a la imagen
  shufps xmm0, xmm0, 00000000b			;xmm0 = hh|hh|hh|hh
  movdqu xmm3, xmm0                    ;xmm3 = hh|hh|hh|hh (xmm0 se usa como parametro para rgbtohsl)
  shufps xmm1, xmm1, 01010101b			;xmm1 = ss|ss|ss|ss
  shufps xmm2, xmm2, 10101010b			;xmm2 = ll|ll|ll|ll
  
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

            movdqu xmm12, [r8]			;xmm12 = pi0_l | pi0_s | pi0_h | pi0_A

            add rbx, 4
            mov rdi, rbx               ;puntero al pixel
            mov rsi, r8                ;puntero a donde quiero que guarde p_l | p_s | p_h | p_a
            push r8
            sub rsp,8
            sub rsp,16
            movdqu [rsp], xmm3          ;push xmm3
            sub rsp,16
            movdqu [rsp], xmm1          ;push xmm1
            sub rsp,16
            movdqu [rsp], xmm2          ;push xmm2
            sub rsp,16
            movdqu [rsp], xmm12
            call rgbTOhsl              
            movdqu xmm12, [rsp]
            add rsp, 16
            movdqu xmm2, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm1, [rsp]          ;pop xmm1
            add rsp,16
            movdqu xmm3, [rsp]          ;pop xmm3
            add rsp,16
            add rsp,8
            pop r8

            movdqu xmm11, [r8]			;xmm11 = pi1_l | pi1_s | pi1_h | pi1_A

            add rbx, 4
            mov rdi, rbx               ;puntero al pixel
            mov rsi, r8                ;puntero a donde quiero que guarde p_l | p_s | p_h | p_a
            push r8
            sub rsp,8
            sub rsp,16
            movdqu [rsp], xmm3          ;push xmm3
            sub rsp,16
            movdqu [rsp], xmm1          ;push xmm1
            sub rsp,16
            movdqu [rsp], xmm2          ;push xmm2
            sub rsp,16
            movdqu [rsp], xmm12
            sub rsp, 16
            movdqu [rsp], xmm11
            call rgbTOhsl              
            movdqu xmm11, [rsp]
            add rsp, 16
            movdqu xmm12, [rsp]
            add rsp, 16
            movdqu xmm2, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm1, [rsp]          ;pop xmm1
            add rsp,16
            movdqu xmm3, [rsp]          ;pop xmm3
            add rsp,16
            add rsp,8
            pop r8

            movdqu xmm10, [r8]			;xmm10 = pi2_l | pi2_s | pi2_h | pi2_A

            add rbx, 4
            mov rdi, rbx               ;puntero al pixel
            mov rsi, r8                ;puntero a donde quiero que guarde p_l | p_s | p_h | p_a
            push r8
            sub rsp,8
            sub rsp,16
            movdqu [rsp], xmm3          ;push xmm3
            sub rsp,16
            movdqu [rsp], xmm1          ;push xmm1
            sub rsp,16
            movdqu [rsp], xmm2          ;push xmm2
            sub rsp,16
            movdqu [rsp], xmm12
            sub rsp, 16
            movdqu [rsp], xmm11
            sub rsp, 16
            movdqu [rsp], xmm10
            call rgbTOhsl
            movdqu xmm10, [rsp]
            add rsp, 16              
            movdqu xmm11, [rsp]
            add rsp, 16
            movdqu xmm12, [rsp]
            add rsp, 16
            movdqu xmm2, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm1, [rsp]          ;pop xmm1
            add rsp,16
            movdqu xmm3, [rsp]          ;pop xmm3
            add rsp,16
            add rsp,8
            pop r8

            sub rbx, 12
            
            movdqu xmm0, [r8]         ;xmm0 = pi_l | pi_s | pi_h | pi_A

;-----------------------------------------------------------------------------------------
;Hasta aca, tengo:
;;xmm12 = pi0_l | pi0_s | pi0_h | pi0_A
;;xmm11 = pi1_l | pi1_s | pi1_h | pi1_A
;;xmm10 = pi2_l | pi2_s | pi2_h | pi2_A
;;xmm0 = pi3_l | pi3_s | pi3_h | pi3_A
;-----------------------------------------------------------------------------------------

			movdqu xmm4, xmm12
			movdqu xmm5, xmm11
			shufps xmm4, xmm0, 01000001b	;xmm4 = H3|bla|bla|H0
			shufps xmm5, xmm10, 00010100b	;xmm5 = bla|H2|H1|bla
			blendps xmm4, xmm5, 00000110b	;xmm4 = H3|H2|H1|H0

			movdqu xmm5, xmm12
			movdqu xmm6, xmm11
			shufps xmm5, xmm0, 00000000b	;xmm4 = A3|bla|bla|A0
			shufps xmm6, xmm10, 00000000b	;xmm5 = bla|A2|A1|bla
			blendps xmm5, xmm5, 00000110b	;xmm4 = A3|A2|A1|A0

			movdqu xmm6, xmm12
			movdqu xmm7, xmm11
			shufps xmm6, xmm0, 10101010b	;xmm4 = S3|bla|bla|S0
			shufps xmm7, xmm10, 10101010b	;xmm5 = bla|S2|S1|bla
			blendps xmm6, xmm5, 00000110b	;xmm4 = S3|S2|S1|S0

			movdqu xmm7, xmm12
			movdqu xmm8, xmm11
			shufps xmm7, xmm0, 11111111b	;xmm4 = L3|bla|bla|L0
			shufps xmm8, xmm10, 11111111b	;xmm5 = bla|L2|L1|bla
			blendps xmm7, xmm5, 11111111b	;xmm4 = L3|L2|L1|L0

			movdqu xmm0, xmm4
			movdqu xmm10, xmm5
			movdqu xmm11, xmm6
			movdqu xmm12, xmm7
;-----------------------------------------------------------------------------------------
;Hasta aca, tengo:
;;xmm12 = L3|L2|L1|L0
;;xmm11 = S3|S2|S1|S0
;;xmm10 = A3|A2|A1|A0
;;xmm0 = H3|H2|H1|H0
;-----------------------------------------------------------------------------------------			

			call .hago_suma

;-----------------------------------------------------------------------------------------
;Hasta aca, tengo:
;;xmm12 = L3|L2|L1|L0
;;xmm11 = S3|S2|S1|S0
;;xmm10 = A3|A2|A1|A0
;;xmm0 = H3|H2|H1|H0
;pero todos sumaditos correctos y filtrados

;-----------------------------------------------------------------------------------------			
;---------------------------------------------------------------------------------------------

;REACOMODO EN xmm0, xmm10, xmm11 y xmm12 lo que hay en l=xmm6, s=xmm7, h=xmm9 y a=xmm11-------


; H3|H2|H1|H0
; S3|S2|S1|S0
; L3|L2|L1|L0
; A3|A2|A1|A0

; lsha

  movdqu xmm1, xmm12             ;xmm1 = l 
  movdqu xmm3, xmm0             ;xmm3 = h
  

  pslldq xmm1, 4          ;L2,L1,L0,0
  blendps xmm1, xmm11, 5         ;L2,S2,L0,S0

  pslldq xmm3, 4          ;h2,h1,h0,0
  blendps xmm3, xmm10, 5        ;h2,a2,h0,a0  

  movdqu xmm2, xmm3 

  shufps xmm2, xmm1, 01000100b  ;l0,s0,h0,a0
  shufps xmm3, xmm1, 11101110b  ;l2,s2,h2,a2



  movdqu xmm1, xmm12             ;xmm1 = l 
  movdqu xmm4, xmm0             ;xmm4 = h
  

  psrldq xmm1, 4          ;0,l3,l2,l1
  blendps xmm1, xmm11, 0xA       ;s3,l3,s1,l1

  psrldq xmm4, 4          ;0,h3,h2,h1
  blendps xmm4, xmm10, 0xA      ;a3,h3,a1,h1  

  movdqu xmm5, xmm4 

  shufps xmm4, xmm1, 00010001b  ;l1,s1,h1,a1
  shufps xmm5, xmm1, 10111011b  ;l3,s3,h3,a3

;------------------------------------------------------------------------------------------

  ;finalmente tengo mis pixeles asi p0 p1 p2 p3 xmm2 xmm4 xmm3 xmm5

	;Reordeno para que queden en los xmm libres que van a ser xmm0, xmm10, xmm11 y xmm12

  movdqu xmm12, xmm5						;l3,s3,h3,a3
  movdqu xmm10, xmm4						;l1,s1,h1,a1
  movdqu xmm11, xmm3						;l2,s2,h2,a2
  movdqu xmm0, xmm2							;l0,s0,h0,a0
	


            movdqu [r8], xmm0         ;a partir de la direccion indicada por rsi guardo el HSL ya procesado
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

            sub rsp,16
            movdqu [rsp], xmm12          ;push xmm2
            sub rsp,16
            movdqu [rsp], xmm10          ;push xmm2
            sub rsp,16
            movdqu [rsp], xmm11         ;push xmm2

            call hslTOrgb

            movdqu xmm11, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm10, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm12, [rsp]          ;pop xmm2
            add rsp,16


            movdqu xmm2, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm1, [rsp]          ;pop xmm1
            add rsp,16
            movdqu xmm3, [rsp]          ;pop xmm3
            add rsp,16
            add rsp,8
            pop r8              
           


            add rbx, 4
           movdqu [r8], xmm10         ;a partir de la direccion indicada por rsi guardo el HSL ya procesado
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

            sub rsp,16
            movdqu [rsp], xmm12          ;push xmm2
            sub rsp,16
            movdqu [rsp], xmm11         ;push xmm2

            call hslTOrgb

            movdqu xmm11, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm12, [rsp]          ;pop xmm2
            add rsp,16


            movdqu xmm2, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm1, [rsp]          ;pop xmm1
            add rsp,16
            movdqu xmm3, [rsp]          ;pop xmm3
            add rsp,16
            add rsp,8
            pop r8 




            add rbx, 4
           movdqu [r8], xmm11         ;a partir de la direccion indicada por rsi guardo el HSL ya procesado
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

            sub rsp,16
            movdqu [rsp], xmm12          ;push xmm2

            call hslTOrgb

            movdqu xmm12, [rsp]          ;pop xmm2
            add rsp,16


            movdqu xmm2, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm1, [rsp]          ;pop xmm1
            add rsp,16
            movdqu xmm3, [rsp]          ;pop xmm3
            add rsp,16
            add rsp,8
            pop r8     



            add rbx, 4
           movdqu [r8], xmm12         ;a partir de la direccion indicada por rsi guardo el HSL ya procesado
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
            add r15, 4                    ;procese un pixel mas
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
  

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
;--------------funcion que aplica el filtro, con sus mascaras-----------------------------
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------

.hago_suma:

	push rbp
	mov rbp, rsp
		
;-----------------------------------------------------------------------------------------
;Hasta aca, tengo:
;;xmm12 = L3|L2|L1|L0
;;xmm11 = S3|S2|S1|S0
;;xmm10 = A3|A2|A1|A0
;;xmm0 = H3|H2|H1|H0
;-----------------------------------------------------------------------------------------


			; h 
			;addps xmm0, xmm3           ;xmm0 = pi_l | pi_s | pi_h + hh | pi_A                         
    		; s
            ;addps xmm0, xmm2           ;xmm0 = pi_l | pi_s + ss | pi_h + hh | pi_A
            ; l
            ;addps xmm0, xmm1           ;xmm0 = pi_l + ll | pi_s + ss | pi_h + hh | pi_A   (como floats)

            addps xmm0, xmm3
            addps xmm11, xmm1
            addps xmm12, xmm2

            movdqu xmm15, xmm0         
            movdqu xmm14, xmm15 
            roundps xmm14, xmm14, 1

            cvttps2dq xmm0, xmm0        ;xmm0 =   (como ints, para comparar)
            cvtps2dq xmm14, xmm14       
            
;-----------------------------------------------------------------------------------------
;Hasta aca, tengo:
;;xmm12 = L3+ll|L2+ll|L1+ll|L0+ll
;;xmm11 = S3+ss|S2+ss|S1+ss|S0+ss
;;xmm10 = A3|A2|A1|A0
;;xmm0 = H3+hh|H2+hh|H1+hh|H0+hh ints redondeo normal
;xmm15= H3+hh|H2+hh|H1+hh|H0+hh
;xmm14= H3+hh|H2+hh|H1+hh|H0+hh  redondeo hacia abajo
;-----------------------------------------------------------------------------------------
          
            ;COMPARACIONES SOBRE H
            ;h + hh = 360?

            movdqu xmm5, xmm0
            pcmpeqd xmm5, [mask360i]   ;pi_h+hh = 360? todo lo demas quede en 0 probablemente
            movdqu xmm6, xmm5          

            ;h + hh > 360?

            movdqu xmm5, xmm0
            pcmpgtd xmm5, [mask360i]   ;pi_h+hh > 360?
            movdqu xmm7, xmm5          

            ;h<<<<< + hh = 0?

            movdqu xmm5, xmm14
            pcmpeqd xmm5, [mascara8]   ;pi_h+hh = 0?
            movdqu xmm8, xmm5          
            ;jz .sumo360
            ;h + hh > 0?

            movdqu xmm5, xmm14
            pcmpgtd xmm5, [mascara8]   ;pi_h+hh > 0?
            movdqu xmm9, xmm5          
            
            ;PARA SABER SI h+hh <0 me fijo si h+hh>0 y si h+hh=0, los sumo y despues hago un pnand para negar, si da 1s es que es menor, sino era o mayor o igual
            ;PARA SABER SI h+hh >= 360 me fijo si h+hh=360 y si h+hh>360, hago pxor entre eso y me fijo si da 1s es que es alguna de las dos opciones sino es menor

            pxor xmm6, xmm7
            pand xmm6, [mask360i]      ;xmm6 = 0 | 0 | 360 si h+hh>=360, 0 sino | 0
            pxor xmm8, xmm9               
            pandn xmm8, [mask360i]      ;xmm8 = 0 | 0 | 360 si h+hh<0, 0 sino | 0
            
            ;AHORA APLICO LOS CAMBIOS A h
            cvtdq2ps xmm6,xmm6         ;convierto a float xmm6
            cvtdq2ps xmm8,xmm8         ;convierto a float xmm8

            subps xmm15, xmm6           ;xmm6 = pi_l + ll | pi_s + ss | pi_h+hh - 360 si pi_h+hh>=360, pi_h+hh sino | pi_A
            addps xmm15, xmm8           ;xmm6 = pi_l + ll | pi_s + ss | pi_h+hh +360 si pi_h+hh<0, pi_h+hh sino | pi_A
            movdqu xmm0, xmm15
            ;ACLARO QUE SOLO PUEDE PASAR 1 CASO DE LOS 2 ANTERIORES, osea que o hago +360 o -360 o queda pi_h+hh

            movdqu xmm15, xmm11         
            movdqu xmm14, xmm15 
            roundps xmm14, xmm14, 1

            cvttps2dq xmm11, xmm11        ;xmm0 =   (como ints, para comparar)
            cvtps2dq xmm14, xmm14       




;-----------------------------------------------------------------------------------------
;Hasta aca, tengo:
;;xmm12 = L3+ll|L2+ll|L1+ll|L0+ll
;;xmm11 = S3+ss|S2+ss|S1+ss|S0+ss
;;xmm10 = A3|A2|A1|A0
;;xmm0 = h3correcto|h2correcto|h1correcto|h0correcto ints redondeo normal
;xmm15= S3+ss|S2+ss|S1+ss|S0+ss
;xmm14= S3+ss|S2+ss|S1+ss|S0+ss  redondeo hacia abajo
;-----------------------------------------------------------------------------------------



            ;COMPARACIONES SOBRE S
            ;s+ss = 1?

            movdqu xmm5, xmm11
            pcmpeqd xmm5, [maskUnoi]
            movdqu xmm6, xmm5

            ;s+ss > 1?

            movdqu xmm5, xmm11
            pcmpgtd xmm5, [maskUnoi]
            movdqu xmm7, xmm5

            ;s+ss = 0?

            movdqu xmm5, xmm14
            pcmpeqd xmm5, [mascara8]
            movdqu xmm8, xmm5
            
            ;s+ss > 0?

            movdqu xmm5, xmm14
            pcmpgtd xmm5, [mascara8]
            movdqu xmm9, xmm5

            ;EL PROCEDIMIENTO ES BASICAMENTE IGUAL QUE PARA H+HH PERO CON OTROS VALORES
            
            pxor xmm6, xmm7             ;xmm6 = 0 |  pi_s+ss >= 1?| 0 | 0
            movdqu xmm13, xmm6          ;xmm13 = xmm6
            pand xmm6, [maskUnof]     ;xmm6 = 0|1.0 si pi_s+ss >= 1? sino 0|0|0 
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
            movdqu xmm11, xmm13         ;;xmm13 = pi_l + ll | CORRECTOSS| CORRECTOHH | pi_A   (como floats)

            movdqu xmm15, xmm12         
            movdqu xmm14, xmm15 
            roundps xmm14, xmm14, 1

            cvttps2dq xmm12 xmm12        ;xmm0 =   (como ints, para comparar)
            cvtps2dq xmm14, xmm14       

;-----------------------------------------------------------------------------------------
;Hasta aca, tengo:
;;xmm12 = L3+ll|L2+ll|L1+ll|L0+ll
;;xmm11 = s3correcto|s2correcto|s1correcto|s0correcto
;;xmm10 = A3|A2|A1|A0
;;xmm0 = h3correcto|h2correcto|h1correcto|h0correcto
;xmm15= S3+ss|S2+ss|S1+ss|S0+ss
;xmm14= S3+ss|S2+ss|S1+ss|S0+ss  redondeo hacia abajo
;-----------------------------------------------------------------------------------------



            ;COMPARACIONES SOBRE L
            ;l+ll = 1?

            movdqu xmm5, xmm0
            pcmpeqd xmm5, [maskUnoi]
            movdqu xmm6, xmm5
 
            ;l+ll > 1?

            movdqu xmm5, xmm0
            pcmpgtd xmm5, [maskUnoi]
            movdqu xmm7, xmm5
 
            ;l+ll = 0?

            movdqu xmm5, xmm14
            pcmpeqd xmm5, [mascara8]
            movdqu xmm8, xmm5

            ;l+ll > 0?

            movdqu xmm5, xmm14
            pcmpgtd xmm5, [mascara8]
            movdqu xmm9, xmm5
            

            pxor xmm6, xmm7             ;xmm6 = pi_l+ll >= 1? | 0 | 0 | 0
            movdqu xmm13, xmm6          ;xmm13 = xmm6
            pand xmm6, [maskUnof]     ;xmm6 = 1.0 si pi_l+ll >= 1? sino 0|0|0|0 
            pandn xmm13, xmm15          ;xmm13 = 0 si pi_l+ll >= 1? l+ll si no  | CORRECTOSS | CORRECTOHH | pi_A   (como floats)
            pxor xmm13, xmm6            ;xmm13 = 1.0 si pi_l+ll >= 1? l+ll si no | CORRECTOSS | CORRECTOHH | pi_A   (como floats)

            pxor xmm8, xmm9             ;xmm8 = pi_l+ll >= 0? | 0 | 0 | 0
            pxor xmm8, [mascara8]       ;xmm8 = |  pi_s+ss >= 0?|TRUE | TRUE | TRUE
            pand xmm13, xmm8            ;xmm13 = 1.0 (si pi_l+ll >= 1? y pi_l+ll >= 0?), l+ll si(si pi_l+ll < 1? y pi_l+ll >= 0?), 0 sino | CORRECTOSS | CORRECTOHH | pi_A   (como floats)

            ;APLICO CAMBIOS
             movdqu xmm12, xmm13         ;;xmm13 = CORRECTOSLL | CORRECTOSS| CORRECTOHH | pi_A   (como floats)

	pop rbp
	ret
	