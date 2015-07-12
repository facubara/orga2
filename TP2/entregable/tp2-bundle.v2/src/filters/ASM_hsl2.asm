; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion HSL 2                                      ;
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
Maskshuffle:  db 0,4,8,12,1,5,9,13,2,6,10,14,3,7,11,15
mascara255.cerosyuno: dd 255.0001 , 255.0001 , 255.0001 , 255.0001             ;le
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


global ASM_hsl2
global hago_suma
global rgbTOhsl_asm
global hslTOrgb_asm

ASM_hsl2:
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

  .ciclofilas:
     cmp r14,r13                       ;termine?
     jz .fin    
     xor r15, r15                      ;reseteo contador columnas
          
       .ciclocolumnas:
            cmp r12, r15               ;termine con la fila?
            jz .avanzo

			movdqu xmm0, [rbx]			;xmm0 -> p3|p2|p1|p0
 
            sub rsp,16
            movdqu [rsp], xmm3          ;push xmm3
            sub rsp,16
            movdqu [rsp], xmm1          ;push xmm1
            sub rsp,16
            movdqu [rsp], xmm2          ;push xmm2
            ;call rgbTOhsl              ;xmm0 = pi_l | pi_s | pi_h | pi_A

			call rgbTOhsl_asm

            movdqu xmm2, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm1, [rsp]          ;pop xmm1
            add rsp,16
            movdqu xmm3, [rsp]          ;pop xmm3
            add rsp,16
            
			;Ahora tengo

			;xmm0  -> l3,s3,h3,a3
			;xmm10 -> l1,s1,h1,a1
			;xmm11 -> l2,s2,h2,a2
			;xmm12 -> l0,s0,h0,a0
            
			;call hago_suma
			
			movdqu xmm15, xmm0									;ESTA LINEA ES PARA TESTS, DESPUES SE BORRA

			;en xmm15 tengo el pixel resultado
						
			sub rsp,16
            movdqu [rsp], xmm3          ;push xmm3
            sub rsp,16
            movdqu [rsp], xmm1          ;push xmm1
            sub rsp,16
            movdqu [rsp], xmm2          ;push xmm2
			
			call hslTOrgb_asm
            
            movdqu xmm2, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm1, [rsp]          ;pop xmm1
            add rsp,16
            movdqu xmm3, [rsp]          ;pop xmm3
            add rsp,16
						
			movdqu xmm0, xmm11			;xmm0 -> l2,s2,h2,a2
			movd xmm11, eax
			pslldq xmm11, 4				;xmm11 -> basura|basura|p3 procesado|0
						
			;call hago_suma

			movdqu xmm15, xmm0									;ESTA LINEA ES PARA TESTS, DESPUES SE BORRA

			;en xmm15 tengo el pixel resultado
						
			sub rsp,16
            movdqu [rsp], xmm3          ;push xmm3
            sub rsp,16
            movdqu [rsp], xmm1          ;push xmm1
            sub rsp,16
            movdqu [rsp], xmm2          ;push xmm2
			
			call hslTOrgb_asm
            
            movdqu xmm2, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm1, [rsp]          ;pop xmm1
            add rsp,16
            movdqu xmm3, [rsp]          ;pop xmm3
            add rsp,16
						
			movdqu xmm0, xmm10			;xmm0 -> l1,s1,h1,a1
			movd xmm11, eax
			pslldq xmm11, 4				;xmm11 -> basura|p3 procesado|p2 procesado|0

			;call hago_suma
			
			movdqu xmm15, xmm0									;ESTA LINEA ES PARA TESTS, DESPUES SE BORRA

			;en xmm15 tengo el pixel resultado
						
			sub rsp,16
            movdqu [rsp], xmm3          ;push xmm3
            sub rsp,16
            movdqu [rsp], xmm1          ;push xmm1
            sub rsp,16
            movdqu [rsp], xmm2          ;push xmm2
			
			call hslTOrgb_asm
            
            movdqu xmm2, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm1, [rsp]          ;pop xmm1
            add rsp,16
            movdqu xmm3, [rsp]          ;pop xmm3
            add rsp,16
						
			movdqu xmm0, xmm12			;xmm0 -> l0,s0,h0,a0
			movd xmm11, eax
			pslldq xmm11, 4				;xmm11 -> p3 procesado|p2 procesado|p1 procesado|0

			;call hago_suma
			
			movdqu xmm15, xmm0									;ESTA LINEA ES PARA TESTS, DESPUES SE BORRA

			;en xmm15 tengo el pixel resultado
						
			sub rsp,16
            movdqu [rsp], xmm3          ;push xmm3
            sub rsp,16
            movdqu [rsp], xmm1          ;push xmm1
            sub rsp,16
            movdqu [rsp], xmm2          ;push xmm2
			
			call hslTOrgb_asm
            
            movdqu xmm2, [rsp]          ;pop xmm2
            add rsp,16
            movdqu xmm1, [rsp]          ;pop xmm1
            add rsp,16
            movdqu xmm3, [rsp]          ;pop xmm3
            add rsp,16
						
			movd xmm11, eax				;xmm11 -> p3 procesado|p2 procesado|p1 procesado|p0 procesado
					
			movdqu [rbx], xmm11

            ;ACA YA TERMINE DE PROCESAR ESE PIXEL Y SE INSERTA EN LA IMAGEN

            add rbx, 16                ;paso a los 4 pixeles siguientes
            add r15, 4                 ;procese 4 pixeles mas
            jmp .ciclocolumnas
            

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
  
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
;------------------funcion rgb->hsl con sus mascaras ------------------------------------------
;----------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------


rgbTOhsl_asm:

  push rbp
  mov rbp, rsp

;bgra

;xmm0 -> p3|p2|p1|p0

  pshufb xmm0, [Maskshuffle]    ;xmm0 -> b3,b2,b1,b0|g3,g2,g1,g0|r3,r2,r1,r0|a3,a2,a1,a0
  movdqu xmm1, xmm0
  pxor xmm3, xmm3

  punpcklbw xmm0, xmm3          ; xmm0 -> r3,r2|r1,r0|a3,a2|a1,a0
  punpckhbw xmm1, xmm3          ; xmm1 -> b3,b2|b1,b0|g3,g2|g1,g0

  movdqu xmm2, xmm1
	movdqu xmm11, xmm0

  punpckhwd xmm0, xmm3          ; xmm0 -> r3|r2|r1|r0
  punpcklwd xmm1, xmm3          ; xmm1 -> g3|g2|g1|g0
  punpckhwd xmm2, xmm3          ; xmm2 -> b3|b2|b1|b0
  punpcklwd xmm11, xmm3         ; xmm11 -> a3|a2|a1|a0

  movdqu xmm3, xmm0
  movdqu xmm4, xmm0

  pmaxud xmm3, xmm1
  pmaxud xmm3, xmm2             ; xmm3 -> cmax3|cmax2|cmax1|cmax0

  pminud xmm4, xmm1
  pminud xmm4, xmm2             ; xmm4 -> cmin3|cmin2|cmac1|cmax0

  movdqu xmm5, xmm3

  psubd xmm5, xmm4              ; xmm5 -> d3 | d2 |d1 | d0


  ;Calculo de L

  movdqu xmm6, xmm3
  paddd xmm6, xmm4              ; xmm6 -> (cmax+cmin)3|...|(cmax+cmin)0
  mov r9d, 510
  pxor xmm7, xmm7
  movd xmm7, r9d
  pshufd xmm7, xmm7, 0          ; xmm7 -> 510|510|510|510

  cvtdq2ps xmm7, xmm7
  cvtdq2ps xmm6, xmm6

  divps xmm6, xmm7              ; xmm6 -> (cmax+cmin)_3 /510 |...|(cmax+cmin)_0 /510
                                ; xmm6 -> L3|L2|L1|L0

  ;Calculo de S 

  pcmpeqd xmm7, xmm7            ; xmm7 -> todos unos
  movdqu xmm8, xmm3
  pcmpeqd xmm8, xmm4            ; xmm8 -> cmax3 = cmin3?|...|cmax0 = cmin0?
  pandn xmm8, xmm7              ; xmm8 -> not(cmax3 = cmin3?)...|not(cmax0 = cmin0?)

  movdqu xmm7, xmm6             ; xmm7 -> L3|L2|L1|L0
  addps xmm7, xmm7              ; xmm7 -> 2*L3|2*L2|2*L1|2*L0
 
  mov r9d, 1
  pxor xmm15, xmm15
  movd xmm15, r9d
  pshufd xmm15, xmm15, 0        ; xmm15 -> 1|1|1|1
  movdqu xmm9, xmm15
  cvtdq2ps xmm9, xmm9           ; xmm9 -> 1.0|1.0|1.0|1.0
  
  subps xmm7, xmm9              ; xmm9 -> 2*L3 - 1 | 2*L2 - 1 | 2*L1 - 1 | 2*L0 - 1
  pxor xmm10, xmm10
  subps xmm10, xmm7
  maxps xmm7, xmm10             ; xmm7 -> fabs(2*L3 - 1) |...| fabs( 2*L0 - 1)

  subps xmm9, xmm7              ; xmm9 -> 1 - fabs(2*L3 - 1) |...| 1 - fabs( 2*L0 - 1)

  movdqu xmm7, xmm5             ; xmm7 -> d3 | d2 |d1 | d0
  cvtdq2ps xmm7, xmm7           ; xmm7 -> d3.0 | d2.0 |d1.0 | d0.0
  divps xmm7, xmm9              ; xmm7 -> d / (1 - fabs(2*L3 - 1)) |...| d/ (1 - fabs( 2*L0 - 1))
  movdqu xmm9, [mascara255.cerosyuno]
  divps xmm7, xmm9              ; xmm9 -> d / (1 - fabs(2*L3 - 1)) / 255.0001|...| d/ (1 - fabs( 2*L0 - 1)) / 255.0001

  pand xmm7,xmm8                ; xmm7 -> S3| S2| S1| S0

  ;Calculo de H

  pcmpeqd xmm8, xmm8            ; xmm8 -> todos unos
  movdqu xmm9, xmm3
  pcmpeqd xmm9, xmm4            ; xmm9 -> cmax3 = cmin3?|...|cmax0 = cmin0?

  movdqu xmm10, xmm5
  psubd xmm10, xmm15            ; xmm10 -> d3-1 | d2-1 |d1-1 | d0-1
  pabsd xmm10, xmm10            ; xmm10 -> abs(d3-1) |...| abs(d0-1)
  paddd xmm10, xmm15            ; xmm10 -> d3 si cmax !=cmin, sino 2 |...| d0 si cmax !=cmin, sino 2 

  cvtdq2ps xmm10, xmm10        ; xmm10 -> d3 si cmax !=cmin, sino 2 |...| d0 si cmax !=cmin, sino 2 (floats)

  ;La razón para estos cuatro anteriores renglones, es que como d va a dividir, si es 0 me va a hacer explotar todo, entonces, si es cero-> basura, sino lo que quiero


  movdqu xmm12, xmm0
  movdqu xmm13, xmm1
  movdqu xmm14, xmm2

  psubd xmm12, xmm1
  psubd xmm13, xmm2
  psubd xmm14, xmm0

  cvtdq2ps xmm12, xmm12          ;xmm12 = r-g|..|r-g
  cvtdq2ps xmm13, xmm13          ;xmm13 = g-b|..|g-b
  cvtdq2ps xmm14, xmm14          ;xmm14 = b-r|..|b-r  

  divps xmm12, xmm10             ;xmm12 = r-g/d|..|r-g/d 
  divps xmm13, xmm10             ;xmm13 = g-b/d|..|g-b/d
  divps xmm14, xmm10             ;xmm14 = b-r/d|..|b-r/d

  paddd xmm15, xmm15             
  cvtdq2ps xmm15, xmm15          ;xmm15 = 2.0|..|2.0
  addps xmm14, xmm15             ;xmm14 = (b-r/d)+2|..|(b-r/d)+2

  movdqu xmm4, xmm15

  addps xmm15,xmm15              ;xmm15 = 4.0|..|4.0
  addps xmm12,xmm15              ;xmm12 = (r-g/d)+4|..|(r-g/d)+4

  addps xmm15,xmm4
  addps xmm13,xmm15              ;xmm13 = (g-b/d)+6|..|(g-b/d)+6

  mov r9d, 60
  pxor xmm15, xmm15
  movd xmm15, r9d
  pshufd xmm15, xmm15, 0        
  cvtdq2ps xmm15, xmm15         ; xmm15 = 60.0|60.0|60.0|60.0


  mulps xmm12, xmm15             ;xmm12 = 60 *((r-g/d)+4)|..|60 * ((r-g/d)+4)
  mulps xmm13, xmm15             ;xmm13 = 60 *((g-b/d)+6)|..|60 * ((g-b/d)+6)
  mulps xmm14, xmm15             ;xmm14 = 60 * ((b-r/d)+2)|..|60 * ((b-r/d)+2)

  ; libres xmm15 , xmm4 , xmm5 , xmm10, xmm15

  pcmpeqd xmm0, xmm3            ; xmm0 -> cmax3 = r?|...| cmax0 = r?
  pcmpeqd xmm2, xmm3            ; xmm2 -> cmax3 = b?|...| cmax0 = b?

  movdqu xmm10, xmm0

  pandn xmm10, xmm1             ; xmm10 -> not(cmax3 = r?) and cmax3 = g?|...|not(cmax0 = r?) and  cmax0 = g?

  movdqu xmm4, xmm0
  pandn xmm4, xmm2
  pandn xmm1, xmm4              ; xmm1 -> not(cmax3 = g?) and not(cmax3 = r?) and cmax3 = b?|...|not(cmax0 = g?) and not(cmax0 = r?) and  cmax0 = b?

  pand xmm13, xmm0              ; xmm13 -> if xmm0, then xmm13, else 0
  pand xmm14, xmm10             ; xmm14 -> if xmm10, then xmm14, else 0
  pand xmm12, xmm1              ; xmm12 -> if xmm1, then xmm12, else 0

  ;Solo uno de los 4 dwords no va a ser cero, por como esta (ver enunciado para entender bien), por eso puedo sumarlos.

  addps xmm13, xmm14
  addps xmm13, xmm12

  pandn xmm9, xmm13             ; xmm9 -> H3|H2|H1|H0 sin ver lo del 360

  mov r9d, 360
  pxor xmm15, xmm15
  movd xmm15, r9d
  pshufd xmm15, xmm15, 0        
  cvtdq2ps xmm15, xmm15         ; xmm15 -> 360.0|360.0|360.0|360.0

  movdqu xmm13, xmm15
  pcmpgtd xmm13, xmm9           ; xmm13 -> 360 > H3?|...|360 > H0?
  pandn xmm13, xmm15            ; xmm13 -> 360.0 si 360 <= H3, 0 sino|...|360.0 si 360 <= H0, 0 sino

  subps xmm9, xmm13             ; xmm9 -> H3|H2|H1|H0

  ;REACOMODO EN xmm0, xmm10, xmm11 y xmm12 lo que hay en l=xmm6, s=xmm7, h=xmm9 y a=xmm11


; H3|H2|H1|H0
; S3|S2|S1|S0
; L3|L2|L1|L0
; A3|A2|A1|A0

; lsha

  movdqu xmm1, xmm6             ;xmm1 = l 
  movdqu xmm3, xmm9             ;xmm3 = h
  

  pslldq xmm1, 4          ;L2,L1,L0,0
  blendps xmm1, xmm7, 5         ;L2,S2,L0,S0

  pslldq xmm3, 4          ;h2,h1,h0,0
  blendps xmm3, xmm11, 5        ;h2,a2,h0,a0  

  movdqu xmm2, xmm3 

  shufps xmm2, xmm1, 01000100b  ;l0,s0,h0,a0
  shufps xmm3, xmm1, 11101110b  ;l2,s2,h2,a2



  movdqu xmm1, xmm6             ;xmm1 = l 
  movdqu xmm4, xmm9             ;xmm4 = h
  

  psrldq xmm1, 4          ;0,l3,l2,l1
  blendps xmm1, xmm7, 0xA       ;s3,l3,s1,l1

  psrldq xmm4, 4          ;0,h3,h2,h1
  blendps xmm4, xmm11, 0xA      ;a3,h3,a1,h1  

  movdqu xmm5, xmm4 

  shufps xmm4, xmm1, 00010001b  ;l1,s1,h1,a1
  shufps xmm5, xmm1, 10111011b  ;l3,s3,h3,a3

  ;finalmente tengo mis pixeles asi p0 p1 p2 p3 xmm2 xmm4 xmm3 xmm5

	;Reordeno para que queden en los xmm libres que van a ser xmm0, xmm10, xmm11 y xmm12

  movdqu xmm0, xmm5						;l3,s3,h3,a3
  movdqu xmm10, xmm4						;l1,s1,h1,a1
  movdqu xmm11, xmm3						;l2,s2,h2,a2
  movdqu xmm12, xmm2						;l0,s0,h0,a0
	
  pop rbp
  ret

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
;--------------funcion que aplica el filtro, con sus mascaras-----------------------------
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------

hago_suma:

	push rbp
	mov rbp, rsp
		
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

            ;h<<<<< + hh = 0?

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

            subps xmm15, xmm6           ;xmm6 = pi_l + ll | pi_s + ss | pi_h+hh - 360 si pi_h+hh>=360, pi_h+hh sino | pi_A
            addps xmm15, xmm8           ;xmm6 = pi_l + ll | pi_s + ss | pi_h+hh +360 si pi_h+hh<0, pi_h+hh sino | pi_A
            
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

            ;APLICO CAMBIOS
             movdqu xmm15, xmm13         ;;xmm13 = CORRECTOSLL | CORRECTOSS| CORRECTOHH | pi_A   (como floats)

	pop rbp
	ret
	
;------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------
;--------------------------------funcion rgb to hsl con sus mascaras ----------------------------
;-------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------


;Falta hacer esta, toma las cosas por xmm15, y no toca los xmm0, xmm10, xmm11 y xmm12


hslTOrgb_asm: 

;me entra por xmm15 lsha
;debo devolver por eax bgra
;no puedo usar xmm0,xmm10,xmm11 ni xmm12




push rbp
mov rbp,rsp



; Calculo de c -------------------------------------------------------------------------------
movdqu xmm1, xmm15
addps xmm1,xmm1						;xmm1 -> 2*l|basura|basura|basura

mov r9d, 1
movd xmm2, r9d
pshufd xmm2, xmm2, 0
cvtdq2ps xmm2, xmm2					;xmm2 -> 1.0|..|1.0
movdqu xmm4, xmm2

subps xmm1, xmm2					;xmm1 -> 2*l -1| basura|basura|basura
pxor xmm3,xmm3 						
subps xmm3, xmm1
maxps xmm1, xmm3					;xmm1 -> fabs(2*l - 1)|basura|basura|basura

subps xmm4,xmm1						;xmm4 -> 1-abs(2*l - 1)|basura|basura|basura

movdqu xmm1, xmm15
pslldq xmm1, 4						;xmm1 -> s|h|a|0

mulps xmm4, xmm1					;xmm4 -> s*(1-abs(2*l - 1))|basura|basura|basura

pshufd xmm4, xmm4, 0xff				;xmm4 -> c|c|c|c
;-------------------------------------------------------------------------------------------
;en xmm4 esta c|c|c|c|
;en xmm15 esta lsha
;resto utilizable salvo xmm0, xmm10, xmm11 y xmm12
;-------------------------------------------------------------------------------------------

;calculo de x ------------------------------------------------------------------------------

movdqu xmm1, xmm15
mov r9d, 60
movd xmm2, r9d
pshufd xmm2, xmm2, 0
cvtdq2ps xmm2, xmm2					;xmm2 -> 60.0|..|60.0

divps xmm1,xmm2						;xmm1 -> basura|basura|h/60.0|basura
movdqu xmm3, xmm1

;fmod(x,y) = x - (roundps para abajo(divps(x, y)) * y)

mov r9d, 2
movd xmm2, r9d
pshufd xmm2, xmm2, 0
cvtdq2ps xmm2, xmm2					;xmm2 -> 2.0|..|2.0

divps xmm3, xmm2
roundps xmm3, xmm3, 1				;roundps para abajo(divps(x, y))
mulps xmm3, xmm2					;(roundps para abajo(divps(x, y)) * y)

subps xmm1, xmm3					;x - (roundps para abajo(divps(x, y)) * y) = fmod(x,y) 
									;xmm1 -> basura|basura|fmod(h/60.0 , 2)|basura


mov r9d, 2
movd xmm2, r9d
pshufd xmm2, xmm2, 0
cvtdq2ps xmm2, xmm2					;xmm2 -> 2.0|..|2.0

subps xmm1, xmm2					;xmm1 -> basura|basura|fmod(h/60.0 , 2) -1|basura
pxor xmm3,xmm3 						
subps xmm3, xmm1
maxps xmm1, xmm3					;xmm1 -> basura|basura|fabs(fmod(h/60.0 , 2) -1)|basura

subps xmm2,xmm1						;xmm1 -> basura|basura|1-fabs(fmod(h/60.0 , 2) -1)|basura

mulps xmm2, xmm4					;xmm1 -> basura|basura|c*(1-fabs(fmod(h/60.0 , 2) -1))|bas

shufps xmm2, xmm2, 01010101b		;xmm2 -> x|x|x|x

;-------------------------------------------------------------------------------------------
;en xmm4 esta c|c|c|c|
;en xmm2 esta x|x|x|x
;en xmm15 esta lsha
;resto utilizable salvo xmm0, xmm10, xmm11 y xmm12
;-------------------------------------------------------------------------------------------

;calculo de m ------------------------------------------------------------------------------

movdqu xmm1, xmm4

mov r9d, 2
movd xmm3, r9d
pshufd xmm3, xmm3, 0
cvtdq2ps xmm3, xmm3					;xmm3 -> 2.0|..|2.0

divps xmm1, xmm3					;xmm1 -> c/2 | c/2 | c/2 | c/2
movdqu xmm3, xmm15

subps xmm3, xmm1					;xmm3 -> l-(c/2) | c/2 | c/2 | c/2
shufps xmm3, xmm3, 0xff				;xmm3 -> m|m|m|m|

;-------------------------------------------------------------------------------------------
;en xmm4 esta c|c|c|c|
;en xmm2 esta x|x|x|x
;en xmm3 esta m|m|m|m|
;en xmm15 esta lsha
;resto utilizable salvo xmm0, xmm10, xmm11 y xmm12
;-------------------------------------------------------------------------------------------

;calculo de rgb ------------------------------------------------------------------------------

blendpd xmm4, xmm2, 00000100b		;xmm4 -> c|x|c|c
pxor xmm2, xmm2
blendpd xmm4, xmm2, 00001001b		;xmm4 -> 0|x|c|0

pxor xmm5, xmm5
blendpd xmm5, xmm15, 00000010b		;xmm5 -> 0|0|h|0
shufps xmm5, xmm5, 01010101b		;xmm5 -> h|h|h|h

pcmpeqd xmm6, xmm6					;xmm6 -> todos 1

mov r9d, 300
movd xmm1, r9d
pshufd xmm1, xmm1, 0
cvtdq2ps xmm1, xmm1					;xmm1 -> 300.0|..|300.0

;como solo uno de los casos puede ser cierto, andeo todos y los sumo, y me queda el resultado
;del que era verdad
;de aca en adelante cuidado, porque cada caso es un copy paste modificado del anterior
;igual creo que no le pifie a nada

cmpps xmm1, xmm5, 2					;xmm1 -> 300<=h?
movdqu xmm7, xmm4					;xmm7 -> b=0| g=x | r=c | a=0(por el momento, sirve)
pand xmm7, xmm1						;xmm7 -> Si 300<=h b=0| g=x | r=c | a=0 , sino 0

;fin caso 1

movdqu xmm8, xmm4					;xmm8 -> 0|x|c|0
shufps xmm8, xmm8, 00011000b		;xmm8 -> b=0 | g=c | r=x | a=0

mov r9d, 240
movd xmm9, r9d
pshufd xmm9, xmm9, 0
cvtdq2ps xmm9, xmm9					;xmm9 -> 240.0|..|240.0

cmpps xmm9, xmm5, 2					;xmm9 -> 240 <= h?
pandn xmm1, xmm9					;xmm1 -> 240 <= h <300?

pand xmm8, xmm1						;xmm8 -> Si 240 <= h <300 b=0 | g=c | r=x | a=0, sino 0
addps xmm7, xmm8					;acumulo casos

;fin caso 2


movdqu xmm8, xmm4					;xmm8 -> 0|x|c|0
shufps xmm8, xmm8, 10010000b		;xmm8 -> b=x | g=c | r=0 | a=0

mov r9d, 180
movd xmm1, r9d
pshufd xmm1, xmm1, 0
cvtdq2ps xmm1, xmm1					;xmm1 -> 180.0|..|180.0

cmpps xmm1, xmm5, 2					;xmm1 -> 180 <= h?
pandn xmm9, xmm1					;xmm9 -> 180 <= h <240?

pand xmm8, xmm9						;xmm8 -> Si 180 <= h <240 b=x | g=c | r=0 | a=0, sino 0
addps xmm7, xmm8					;acumulo casos

; fin caso 3

movdqu xmm8, xmm4					;xmm8 -> 0|x|c|0
shufps xmm8, xmm8, 01100000b		;xmm8 -> b=c | g=x | r=0 | a=0

mov r9d, 120
movd xmm9, r9d
pshufd xmm9, xmm9, 0
cvtdq2ps xmm9, xmm9					;xmm9 -> 120.0|..|120.0

cmpps xmm9, xmm5, 2					;xmm9 -> 120 <= h?
pandn xmm1, xmm9					;xmm1 -> 120 <= h <180?

pand xmm8, xmm1						;xmm8 -> Si 120 <= h <180 b=c | g=x | r=0 | a=0, sino 0
addps xmm7, xmm8					;acumulo casos

; fin caso 4

movdqu xmm8, xmm4					;xmm8 -> 0|x|c|0
shufps xmm8, xmm8, 01001000b		;xmm8 -> b=c | g=0 | r=x | a=0

mov r9d, 60
movd xmm1, r9d
pshufd xmm1, xmm1, 0
cvtdq2ps xmm1, xmm1					;xmm1 -> 60.0|..|60.0

cmpps xmm1, xmm5, 2					;xmm1 -> 60 <= h?
pandn xmm9, xmm1					;xmm9 -> 60 <= h <120?

pand xmm8, xmm9						;xmm8 -> Si 60 <= h <120 b=c | g=0 | r=x | a=0, sino 0
addps xmm7, xmm8					;acumulo casos

; fin caso 5

movdqu xmm8, xmm4					;xmm8 -> 0|x|c|0
shufps xmm8, xmm8, 10000100b		;xmm8 -> b=x | g=0 | r=c | a=0

pandn xmm1, xmm6					;xmm9 -> h <60?

pand xmm8, xmm1						;xmm8 -> Si h <60 b=x | g=0 | r=c | a=0, sino 0
addps xmm7, xmm8					;acumulo casos

;fin caso 6

;-------------------------------------------------------------------------------------------
;en xmm7 esta b|g|r|a
;en xmm3 esta m|m|m|m|
;en xmm15 esta lsha
;resto utilizable salvo xmm0, xmm10, xmm11 y xmm12
;-------------------------------------------------------------------------------------------

;calculo de escala -------------------------------------------------------------------------

addps xmm7, xmm3					;xmm7 -> b+m|g+m|r+m|a+m

mov r9d, 255
movd xmm9, r9d
pshufd xmm9, xmm9, 0
cvtdq2ps xmm9, xmm9					;xmm9 -> 255.0|..|255.0

mulps xmm7, xmm9					;xmm7 -> 255*(b+m)|255*(g+m)|255*(r+m)|255*(a+m)
blendps xmm7, xmm15, 00000001b		;xmm7 -> 255*(b+m)|255*(g+m)|255*(r+m)|a original

cvttps2dq xmm7, xmm7				;en xmm7 tengo bgra de a dwords en ints!!


;-------------------------------------------------------------------------------------------
;en xmm7 esta b|g|r|a	en ints
;resto utilizable salvo xmm0, xmm10, xmm11 y xmm12
;-------------------------------------------------------------------------------------------

;acomodando todo en eax --------------------------------------------------------------------

packusdw xmm7, xmm7
packuswb xmm7, xmm7 				;xmm7 -> basura|basura|basura|bgra

movd eax, xmm7						; y asi tenemos en eax el pixel procesado =D

pop rbp
ret
