; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 1                                     ;
;                                                                           ;
; ************************************************************************* ;
extern malloc
extern free
section .data
constante: times 4 dd 9.0
mascaraBorraUltimo: dd 0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0
mascaraEscribo2Primeros: db 0,0xff,0xff,0xff,0,0xff,0xff,0xff,0,0,0,0,0,0,0,0
mascaraEscriboTodos: db 0,0xff,0xff,0xff,0,0xff,0xff,0xff,0,0xff,0xff,0xff,0,0xff,0xff,0xff
section .text
; void ASM_blur2( uint32_t w, uint32_t h, uint8_t* data )
global ASM_blur2
ASM_blur2:
    
    ;rdi = ancho
    ;rsi = altos
    ;rdx = src
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp,8
    ; Fin seteo

    mov r13, rdx                  ;backup puntero
    mov r14, rdi                  ;backup  columnas
    mov r15,rsi                   ;backup filas

    mov rax, rdi                  ;preparo mul 
    mul rsi                       ;rdi*rsi Columnas* filas
    lea rax,[rax*4]               ;multiplicacion de ancho*alto*4 (tamanio bytes)
    mov rdi, rax                  ;preparo malloc
    mov rbx, rdi                  ;guardo el tamanio de la imagen en rbx
    call malloc                   ;tengo en rax el puntero a copy
    mov r9, rbx                   ;tam imagen a r9
    shr r9, 4                     ;tengo el tamanio de imagen en grupos de  4 pixeles
    mov rdi, r13                  ;rdi puntero al dato rdi = r13
    mov rsi, rax                  ;puntero a copy 
    xor r10, r10                  ;r10 = 0
    
    ;hasta aca
    ;r13 p original
    ;r14 col
    ;r15 fil
    ;rax puntero a copy 
    ;rbx tiene tam imagen en bytes 

    ;r9 tam imagen en grup 4 pix 
    ;rdi puntero a la original
    ;r15 tiene 0 va a ser contador 
    ;rsi puntero a copy (rax tmb)
    .ciclocopia:
    ; en r9 = tamanio de imagen, en rsi puntero a la copia 
    cmp r9, r10                      ;termine de copiar?
    je .cargarVar
    movdqu xmm0, [rdi]
    movdqu [rsi], xmm0
    inc r10                           ;copio lo que estaba en la imagen
    lea rsi,[rsi+16]
    lea rdi,[rdi+16]
    jmp .ciclocopia
    ; la copia la hago contando las iteraciones y luego copiando esa cantidad de veces

    ;HASTA ACA TENGO LA COPIA YA HECHA
    ;EMPIEZO CON LA OPERATORIA SOBRE LA COPIA
  
  .cargarVar:                        
    movdqu xmm14, [constante]         ;xmm14 = 9 | 9 | 9 | 9 (float)
    mov r8, r14       
    shr r8,2                          ;contador columna es columnas/4
    mov r9, r15                       
    sub r9,2                          ;contador fila
    mov rsi, rax                      ;puntero a la fila actual copy(me muevo en la copia)
    lea rsi, [rsi+r14*4]              ;pongo la segunda fila  como inicio
    mov rdi, rsi                      ;puntero a mi pixeles a cargar ->|v|pixel|v|v| (memoria), voy a cargar tres veces.
    movdqu xmm15, [mascaraBorraUltimo]           ;cargo en xmm15 la mascaraBorraUltimo para and
    xor rdx,rdx
    xor rcx,rcx
    mov r12, rax                      ;backup rax
    mov rax, r13                      ;puse en rax puntero a la orignal
    lea rax, [rax+r14*4]            ;pongo el puntero original tmb en segunda fila
    lea r11, [r14*4]                  ;r11 tiene el offset fila
    pxor xmm6, xmm6
    ;xmm14 cst float 
    ;r8 contador columna
    ;r9 contador fila 
    ;rsi puntero a 2da fila  copy
    ;rax puntero a 2da fila  original
    ;rdi apunta a lo mismo q rsi va a ser el puntero a pixel 
    ;xmm15 mascaraBorraUltimo and
    ;rdx rcx = 0 son los contadores de filas y columnas (voy a iterar hasta que sean iguales a r8 y r9 respectivamente)
    ;r11 offset fila 
    ;r12 backup rax

  .ciclofila:
     cmp rdx, r9           ;se fija si termine con las filas   
     je .fin               ;si es la ultima termino
     xor rcx, rcx          ;reseto contador columnas
  .cicloColumna:
      cmp rcx, r8                       ;se fija si termine con las columnas
      je .avanzoFila                    ;si termine con las columnas salto a la otra
     

      ;EMPIEZA OPERATORIA CON PIXEL 1

      movdqu xmm0,[rdi]                 ;cargo el pixel a cargar
      mov rbx, rdi                      ;rbx = rdi
      sub rbx, r11                      ;rbx-r11(offsetFila) estoy en la fila superior
      movdqu xmm1, [rbx]                ; cargo vecinos superiores
      lea rbx, [rbx + r11*2]          ; estoy en la fila inferior
      movdqu xmm2, [rbx]                ; cargo vecinos inferiores
      ;xmm0 = |p3|p2|t|p0| medio
      ;xmm1 = |s3|s2|s1|s0| superior
      ;xmm2 = |i3|i2|i1|i0| inferior
      pand xmm0, xmm15                ; hago cero la basura
      pand xmm1, xmm15                ; hago cero la basura
      pand xmm2, xmm15                ; hago cero la basura
      ;xmm0 = |0|p2|t|p0| medio
      ;xmm1 = |0|s2|s1|s0| superior
      ;xmm2 = |0|i2|i1|i0| inferior
      movdqu xmm3, xmm0               ;preparo para unpack xmm0          
      movdqu xmm4, xmm1               ;preparo para unpack xmm1
      movdqu xmm5, xmm2               ;preparo para unpack xmm2
      punpcklbw xmm0,xmm6
      punpckhbw xmm3,xmm6             ;despempaquete m en xmm0 y xmm3 
      punpcklbw xmm1,xmm6
      punpckhbw xmm4,xmm6             ;despempaquete s en xmm1 y xmm4 
      punpcklbw xmm2,xmm6 
      punpckhbw xmm5,xmm6             ;despempaquete i en xmm2 y xmm5 
      ;ahora tengo todo de a dos falta sumarlos 
      paddw xmm0,xmm3                 ;xmm0 = t|p0+p2
      paddw xmm1,xmm4                 ;xmm1 = s1|s0+s2
      paddw xmm2,xmm5                 ;xmm2 = i1|i0+i2
      paddw xmm0,xmm1                 ;xmm0 = t+s1|p0+p2+s0+s2
      paddw xmm0,xmm2                 ;xmm0 = t+s1+i1|p0+p2+s0+s2+i0+i2
      movdqu xmm1, xmm0               ;xmm1 = xmm0

      punpcklwd xmm0,xmm6             ;desempaquete xmm0 = p0+p2+s0+s2+i0+i2
      punpckhwd xmm1,xmm6             ;desmpaquete  xmm1 = t+s1+i1
      paddd xmm0, xmm1                ;xmm0 = p0+p2+s0+s2+i0+i2+t+s1+i1 Toda la suma entera 
      cvtdq2ps xmm0,xmm0              ;paso a float cada una de las componentes 
      divps xmm0, xmm14               ;dividi toda las componentes por 9 
      cvttps2dq xmm0,xmm0             ;los volvi a pasar a integer
      movdqu xmm7, xmm0               ;PIXEL1 en xmm7 b|g|r|a 
      ;HASTA ACA TENGO UN PIXEL1 PROCESADO CON TODOS SUS VECINOS

      lea rdi, [rdi+4]                ;aumento el puntero pixel al siguiente 

      ;EMPIEZA OPERATORIA CON PIXEL 2

      movdqu xmm0,[rdi]                 ;cargo el pixel a cargar
      mov rbx, rdi                      ;rbx = rdi
      sub rbx, r11                      ;rbx-r11(offsetFila) estoy en la fila superior
      movdqu xmm1, [rbx]                ; cargo vecinos superiores
      lea rbx, [rbx + r11*2]          ; estoy en la fila inferior
      movdqu xmm2, [rbx]                ; cargo vecinos inferiores
      ;xmm0 = |p3|p2|t|p0| medio
      ;xmm1 = |s3|s2|s1|s0| superior
      ;xmm2 = |i3|i2|i1|i0| inferior
      pand xmm0, xmm15                ; hago cero la basura
      pand xmm1, xmm15                ; hago cero la basura
      pand xmm2, xmm15                ; hago cero la basura
      ;xmm0 = |0|p2|t|p0| medio
      ;xmm1 = |0|s2|s1|s0| superior
      ;xmm2 = |0|i2|i1|i0| inferior
      movdqu xmm3, xmm0               ;preparo para unpack xmm0          
      movdqu xmm4, xmm1               ;preparo para unpack xmm1
      movdqu xmm5, xmm2               ;preparo para unpack xmm2
      punpcklbw xmm0,xmm6
      punpckhbw xmm3,xmm6             ;despempaquete m en xmm0 y xmm3 
      punpcklbw xmm1,xmm6
      punpckhbw xmm4,xmm6             ;despempaquete s en xmm1 y xmm4 
      punpcklbw xmm2,xmm6 
      punpckhbw xmm5,xmm6             ;despempaquete i en xmm2 y xmm5 
      ;ahora tengo todo de a dos falta sumarlos 
      paddw xmm0,xmm3                 ;xmm0 = t|p0+p2
      paddw xmm1,xmm4                 ;xmm1 = s1|s0+s2
      paddw xmm2,xmm5                 ;xmm2 = i1|i0+i2
      paddw xmm0,xmm1                 ;xmm0 = t+s1|p0+p2+s0+s2
      paddw xmm0,xmm2                 ;xmm0 = t+s1+i1|p0+p2+s0+s2+i0+i2
      movdqu xmm1, xmm0               ;xmm1 = xmm0

      punpcklwd xmm0,xmm6             ;desempaquete xmm0 = p0+p2+s0+s2+i0+i2
      punpckhwd xmm1,xmm6             ;desmpaquete  xmm1 = t+s1+i1
      paddd xmm0, xmm1                ;xmm0 = p0+p2+s0+s2+i0+i2+t+s1+i1 Toda la suma entera 
      cvtdq2ps xmm0,xmm0              ;paso a float cada una de las componentes 
      divps xmm0, xmm14               ;dividi toda las componentes por 9 
      cvttps2dq xmm0,xmm0             ;los volvi a pasar a integer
      movdqu xmm8, xmm0               ;PIXEL2 en xmm8 
      ;HASTA ACA TENGO UN PIXEL2 PROCESADO CON TODOS SUS VECINOS
      
      lea rdi, [rdi+4]                ;aumento el puntero pixel al siguiente 
      
      ;EMPIEZA OPERATORIA CON PIXEL 3

      movdqu xmm0,[rdi]                 ;cargo el pixel a cargar
      mov rbx, rdi                      ;rbx = rdi
      sub rbx, r11                      ;rbx-r11(offsetFila) estoy en la fila superior
      movdqu xmm1, [rbx]                ; cargo vecinos superiores
      lea rbx, [rbx + r11*2]            ; estoy en la fila inferior
      movdqu xmm2, [rbx]                ; cargo vecinos inferiores
      ;xmm0 = |p3|p2|t|p0| medio
      ;xmm1 = |s3|s2|s1|s0| superior
      ;xmm2 = |i3|i2|i1|i0| inferior
      
      ;RESGUARDO DE DATOS PARA EL PIXEL 4

      movdqu xmm11,xmm0               ;xmm11 = xmm0
      movdqu xmm12,xmm1               ;xmm12 = xmm1
      movdqu xmm13,xmm2               ;xmm13 = xmm2 

      ;FIN DE RESGUARDO

      pand xmm0, xmm15                ; hago cero la basura
      pand xmm1, xmm15                ; hago cero la basura
      pand xmm2, xmm15                ; hago cero la basura
      ;xmm0 = |0|p2|t|p0| medio
      ;xmm1 = |0|s2|s1|s0| superior
      ;xmm2 = |0|i2|i1|i0| inferior
      movdqu xmm3, xmm0               ;preparo para unpack xmm0          
      movdqu xmm4, xmm1               ;preparo para unpack xmm1
      movdqu xmm5, xmm2               ;preparo para unpack xmm2
      punpcklbw xmm0,xmm6
      punpckhbw xmm3,xmm6             ;despempaquete m en xmm0 y xmm3 
      punpcklbw xmm1,xmm6
      punpckhbw xmm4,xmm6             ;despempaquete s en xmm1 y xmm4 
      punpcklbw xmm2,xmm6 
      punpckhbw xmm5,xmm6             ;despempaquete i en xmm2 y xmm5 
      ;ahora tengo todo de a dos falta sumarlos 
      paddw xmm0,xmm3                 ;xmm0 = t|p0+p2
      paddw xmm1,xmm4                 ;xmm1 = s1|s0+s2
      paddw xmm2,xmm5                 ;xmm2 = i1|i0+i2
      paddw xmm0,xmm1                 ;xmm0 = t+s1|p0+p2+s0+s2
      paddw xmm0,xmm2                 ;xmm0 = t+s1+i1|p0+p2+s0+s2+i0+i2
      movdqu xmm1, xmm0               ;xmm1 = xmm0

      punpcklwd xmm0,xmm6             ;desempaquete xmm0 = p0+p2+s0+s2+i0+i2
      punpckhwd xmm1,xmm6             ;desmpaquete  xmm1 = t+s1+i1
      paddd xmm0, xmm1                ;xmm0 = p0+p2+s0+s2+i0+i2+t+s1+i1 Toda la suma entera 
      cvtdq2ps xmm0,xmm0              ;paso a float cada una de las componentes 
      divps xmm0, xmm14               ;dividi toda las componentes por 9 
      cvttps2dq xmm0,xmm0             ;los volvi a pasar a integer
      movdqu xmm9, xmm0               ;PIXEL3 en xmm9 
      ;HASTA ACA TENGO UN PIXEL3 PROCESADO CON TODOS SUS VECINOS
     

      ;EMPIEZA OPERATORIA CON PIXEL 4

      movdqu xmm0, xmm11
      movdqu xmm1, xmm12
      movdqu xmm2, xmm13
      ;xmm0 = |p3|t|p1|p0| medio
      ;xmm1 = |s3|s2|s1|s0| superior
      ;xmm2 = |i3|i2|i1|i0| inferior
      
      ;NORMALIZO EL PIXEL CUATRO PARA APLICAR LA OPERATORIA DE SIEMPRE 
      psrldq xmm0, 0x4      ;xmm0 = |0|p3|t|p1| medio
      psrldq xmm1, 0x4      ;xmm1 = |0|s3|s2|s1| superior
      psrldq xmm2, 0x4      ;xmm2 = |0|i3|i2|i1| inferior

      ;LOS PIXELES YA FUERON NORMALIZADOS 

      movdqu xmm3, xmm0               ;preparo para unpack xmm0          
      movdqu xmm4, xmm1               ;preparo para unpack xmm1
      movdqu xmm5, xmm2               ;preparo para unpack xmm2
      punpcklbw xmm0,xmm6
      punpckhbw xmm3,xmm6             ;despempaquete m en xmm0 y xmm3 
      punpcklbw xmm1,xmm6
      punpckhbw xmm4,xmm6             ;despempaquete s en xmm1 y xmm4 
      punpcklbw xmm2,xmm6 
      punpckhbw xmm5,xmm6             ;despempaquete i en xmm2 y xmm5 
      ;ahora tengo todo de a dos falta sumarlos 
      paddw xmm0,xmm3                 ;xmm0 = t|p0+p2
      paddw xmm1,xmm4                 ;xmm1 = s1|s0+s2
      paddw xmm2,xmm5                 ;xmm2 = i1|i0+i2
      paddw xmm0,xmm1                 ;xmm0 = t+s1|p0+p2+s0+s2
      paddw xmm0,xmm2                 ;xmm0 = t+s1+i1|p0+p2+s0+s2+i0+i2
      movdqu xmm1, xmm0               ;xmm1 = xmm0

      punpcklwd xmm0,xmm6             ;desempaquete xmm0 = p0+p2+s0+s2+i0+i2
      punpckhwd xmm1,xmm6             ;desmpaquete  xmm1 = t+s1+i1
      paddd xmm0, xmm1                ;xmm0 = p0+p2+s0+s2+i0+i2+t+s1+i1 Toda la suma entera 
      cvtdq2ps xmm0,xmm0              ;paso a float cada una de las componentes 
      divps xmm0, xmm14               ;dividi toda las componentes por 9 
      cvttps2dq xmm0,xmm0             ;los volvi a pasar a integer
      movdqu xmm10, xmm0               ;PIXEL4 en xmm10 
      ;HASTA ACA TENGO UN PIXEL4 PROCESADO CON TODOS SUS VECINOS

      ;HASTA ACA TODOS LOS PIXELES FUERON PROCESADOS, CARGADOS DESDE XMM7 A XMM10 CADA UNO ESTA EN INT.

      ;EMPAQUETADO

      packusdw xmm9,xmm10              ;los paso a word |PIXEL4|PIXEL3
      packusdw xmm7,xmm8               ;los paso a word |PIXEL2|PIXEL1
      packuswb xmm7,xmm9               ;los paso a byte xmm0 = |PIXEL4|PIXEL3|PIXEL2|PIXEL1
      
      ;cuenta para encontrar el puntero que debo escribir en la original 
      mov r10, rax                        ;backup rax 
      mov rax, rdx                        ;rax = filaQmeMovi 
      mov rbx, rdx                        ;PROBANDO SI ES MUL LA Q ME ROMPE 
      mul r11                             ;rax = filaQmeMovi*offsetFila 
      mov rdx, rbx                        ;RESTABLEZCO TODO IGUAL
      mov rbx, r10                        ;rbx contiene el puntero a original 
      add rbx, rax                        ;rbx contiene el puntero original + lasFilasQmemovi*offsetFila
      shl rcx,2
      lea rbx,[rbx +rcx*4+4]              ;rbx = filaQmeMovi*offsetFila+colQMovi*16+4 (cuantos bytes me movi de filas)
      shr rcx,2
      mov rax, rbx                        ;rax = puntero al pixel q debo escribir original
      mov rbx, rdi                        ;backup rdi
      mov rdi, rax                        ;rdi = rax (es necesario porque maskmovdqu direcciona sobre el valor de rdi)
      ;falta volver rax y rdi al original

      ;ME FIJO SI ESTOY EN LA COLUMNA DE 4 
      dec r8                    ;r8 tiene la cantidad de columnas de 4 pix q tengo q modificar, le resto 1 para ver si estoy en la ultima
      cmp rcx, r8               ;lo comparo   
      movdqu xmm3, [mascaraEscriboTodos]             ;cargo mascar para escribir todos
      jne .escriboTodos
      
      movdqu xmm3, [mascaraEscribo2Primeros]         ;cargo la mascara para escribir solo los dos primeros
      
      .escriboTodos:

      maskmovdqu xmm7, xmm3                          ;esto va cargar los bytes que su bit mas significativo empieze con 1 cargando a memoria 
      ;si mi mascara esta bien deberia cargar cargar solo los r g b del pixel t

      ;TERMINO OPERATORIA CON PIXELES
      mov rax,r10                                     ;devuelvo rax a lo original
      mov rdi,rbx                                     ;ahi lo volvi al orignial a rdi 
      inc r8                    ;lo vuelvo a como estaba (ya no se que registros puedo tocar :D)
      inc rcx                         ;incremente la columna
      lea rdi, [rdi + 8]              ;mueve al siguiente el puntero de pixel a cargar (fijarse q cargue 3 pixeles y procese 4 entonces avanzo uno mas)
      jmp .cicloColumna
      
      .avanzoFila:
        inc rdx                       ;incremento contador fila
        lea rsi,[rsi + r14*4]          ; rsi+=columnas*4 pongo el puntero fila actual en la siguiente
        mov rdi, rsi                  ; pongo el puntero pixeles a cargar en el inicio de la fila
        jmp .ciclofila
                         
.fin:
  mov qword rdi, r12
  call free                           ;libero la memoria de la imagen copia
  add rsp,8
  pop rbp
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp
  ret
