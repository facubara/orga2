; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 1                                     ;
;                                                                           ;
; ************************************************************************* ;
extern malloc
extern free
section .data
constante: times 4 dd 9
mascara: dd 0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0
mascara2: db 0,0,0,0,0xff,0xff,0xff,0,0,0,0,0,0,0,0,0
section .text
; void ASM_blur1( uint32_t w, uint32_t h, uint8_t* data )
global ASM_blur1
ASM_blur1:
    
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

    xor r15, r15
    xor r8, r8
    xor r9, r9
    pxor xmm0, xmm0
    pxor xmm1, xmm1
    pxor xmm2, xmm2
    pxor xmm3, xmm3
    pxor xmm4, xmm4
    pxor xmm5, xmm5
    pxor xmm6, xmm6
    ; Fin de seteo 
    mov r13, rdx                  ;backup puntero
    mov r14, rdi                  ;backup  columnas
    mov r15,rsi                   ;backup filas

    mov rax, rdi          ;preparo mul 
    mul rsi               ;rdi*rsi Columnas* filas
    lea rax,[rax*4]         ;multiplicacion de ancho*alto*4 (tamanio bytes)
    mov rdi, rax                   ; preparo malloc
    call malloc                   ; tengo en rax el puntero a copy
    shr r9, 4                     ;tengo el tamanio de imagen en grupos de  4 pixeles
    mov rdi, r13                  ; rdi puntero al dato rdi = r13
    mov rsi, rax                  ; puntero a copy rsi = rax

    .ciclocopia:
    ; en r9 = tamanio de imagen, en rsi puntero a la copia 
    cmp r15, r9                       ;termine de copiar?
    jz .cargarVar
    movdqu xmm0, [rdi]
    movdqu xmm0, [rsi]
    inc r15                           ;copio lo que estaba en la imagen
    lea rdx,[rdx+16]
    lea rdi,[rdi+16]
    jmp .ciclocopia
    ; la copia la hago contando las iteraciones y luego copiando esa cantidad de veces
  .cargarVar:                        
    movdqu xmm14, [constante]         ;xmm14 = 9 | 9 | 9 | 9 
    cvtdq2ps xmm14, xmm14             ;xmm14 = 9 | 9 | 9 | 9 (en float)
    mov r8, r14       
    sub r8,2                          ;contador columna
    mov r9, r15                       
    sub r9,2                          ;contador fila
    mov rsi, rax                      ;puntero a la fila actual (me muevo en la copia)
    lea rsi, [rsi+r14*4+4]            ;pongo la segunda fila segundo pixel como inicio
    mov rdi, rsi                      ;puntero a mi pixeles a cargar ->|v|pixel|v|v| (memoria)
    movdqu xmm15, [mascara]           ;cargo en xmm15 la mascara para and
    xor rdx,rdx
    xor rcx,rcx
    mov r12, rax                      ;backup rax
    mov rax, r13                      ;puse en rax puntero a la orignal
    lea rax, [rax+r14*4+4]            ;pongo el puntero original tmb en segunda fila segundo pixel
  .ciclofila:
     cmp rdx, r9           ;se fija si termine con las filas   
     je .fin               ;si es la ultima termino
     xor rcx, rcx          ;reseto contador columnas
  .cicloColumna:
      cmp rcx, r8                       ;se fija si termine con las columnas
      je .avanzoFila                    ;si termine con las columnas salto a la otra
     

      ;EMPIEZA OPERATORIA CON PIXEL
      movdqu xmm0,[rdi]                 ;cargo el pixel a cargar
      mov rbx, rdi                      ;rbx = rdi
      mov r12, r14                      ;r12 = r14
      lea r12,[r12*4]                   ;r12*4 (offset fila)
      sub rbx, r12                      ;rbx estoy en la fila superior
      movdqu xmm1, [rbx]                ; cargo vecinos superiores
      lea rbx, [rbx + r14 * 8]          ; estoy en la fila inferior
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
      ;movdqu xmm3, [shift4]          ;cargo la mascara 
      ;psrldq xmm1, xmm3               ;shifteo 4 bytes hacia la derecha xmm1 = 0|t+s1+i1 
      ;paddb xmm0, xmm1                ;xmm0 = t+s1+i1|t+s1+i1+p0+p2+s0+s2+i0+i2  ya sume todo
      punpcklwd xmm0,xmm6             ;desempaquete xmm0 = p0+p2+s0+s2+i0+i2
      punpckhwd xmm1,xmm6             ;desmpaquete  xmm1 = t+s1+i1
      paddd xmm0, xmm1                ;xmm0 = p0+p2+s0+s2+i0+i2+t+s1+i1 Toda la suma entera 
      cvtdq2ps xmm0,xmm0              ;paso a float cada una de las componentes 
      divps xmm0, xmm14               ;dividi toda las componentes por 9 
      cvtps2dq xmm0,xmm0              ;los volvi a pasar a integer
      packssdw xmm0,xmm0              ;los paso a word
      packsswb xmm0,xmm0              ;los paso a byte xmm0 = |x|x|x|t
      
      ;parche 
      mov rbx, rdi                        ;backup rdi
      mov r10, rax                        ;backup rax 
      mov rax, r9                         ;rax = filaQmeMovi 
      mul r14                             ;rax = filaQmeMovi*cantColumna
      lea rax,[rax*4]                     ;rax = filaQmeMovi*cantColumna*4 (cuantos bytes me movi de filas)
      mov rdi,r10                         ;pongo el puntero a la segunda fila segunda segundo pixel de la original
      add rdi, rax                        ;le agrego el offsetFila al puntero
      lea rdi,[rdi+r8*4]                  ;puntero_a_la_segunda_fila+offsetFila+cantColQMeMovi*4(offset columna) calculo la posicion del pixel que levanto en la original
      mov rax,r10                         ;devuelvo rax a lo original
      ;falta volver rdi al original
      pslldq xmm0, 0x04              ;shifteo 4 bytes hacia la izq xmm0 = |x|x|t|0 
      movdqu xmm3, [mascara2]         ;cargo la mascara
      maskmovdqu xmm0, xmm3           ;esto va cargar los bytes que su bit mas significativo empieze con 1 cargando a memoria 
      ;si mi mascara esta bien deberia cargar cargar solo los r g b del pixel t
      mov rdi,rbx                     ;ahi lo volvi al orignial 
      ;TERMINO OPERATORIA CON PIXEL



      inc rcx                         ;incremente la columna
      lea rdi, [rdi + 4]              ;mueve al siguiente el puntero de pixel a cargar
      jmp .cicloColumna
      .avanzoFila:
        inc rdx                       ;incremento contador fila
        lea rsi,[rsi+ r14*4]          ; rsi+=columnas*4 pongo el puntero fila actual en la siguiente
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
