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

shufps xmm2, xmm2, 0xaa				;xmm2 -> x|x|x|x

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