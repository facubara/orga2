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
mascara: dd 0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0x00000000
section .text
; void ASM_blur1( uint32_t w, uint32_t h, uint8_t* data )
global ASM_blur1
ASM_blur1:
    
    ;rdi = ancho
    ;rsi = alto
    ;rdx = src
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    xor r12, r12    ;contador filas
    xor r13, r13    ;contador columnas
    xor r14, r14
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
    pxor xmm7, xmm7
    pxor xmm8, xmm8
    pxor xmm9, xmm9
    pxor xmm10, xmm10
    ; Fin de seteo 
    mov r13, rdx ;backup puntero
    mov r14, rdi ;backup  columnas
    mov r15,rsi   ;backup filas

    lea r9,[rdi*rsi*4] ;multiplicacion de ancho*alto*4 (tamanio bytes)
    mov rdi, r9; preparo malloc
    call malloc ; tengo en rax el puntero a copy
    shr r9, 4 ;tengo el tamanio de imagen en grupos de  4 pixeles
    mov rdi, r13 ; rdi puntero al dato rdi = r13
    mov rsi, rax ; puntero al dato rsi = rax

    .ciclocopia:
    ; en r9 = tamanio de imagen, en rsi puntero a la copia 
    cmp r15, r9               ;termine de copiar?
    jz .cargarConst
    movdqu xmm0, [rdi]
    movdqu xmm0, [rsi]
    inc r15                           ;copio lo que estaba en la imagen
    lea rdx,[rdx+16]
    lea rdi,[rdi+16]
    jmp .ciclocopia
  .cargarConst:                        
    movdqu xmm14, [constante]         ;xmm14 = 9 | 9 | 9 | 9 
    cvtdq2ps xmm14, xmm14             ;xmm14 = 9 | 9 | 9 | 9 (en float)
    mov r8, r14       
    sub r8,2                          ;contador columna
    mov r9, r15                       
    sub r9,2                          ;contador fila
    mov rdi, r13                      ;puntero a la fila actual
    mov rsi, rdi                      ;puntero a mi pixeles a cargar
    lea rdi, [rdi+r14*4+4]              ;pongo la segunda fila segundo pixel como inicio
    xor rdx,rdx
    xor rcx,rcx
  .ciclofila:
     cmp rdx, r9         ;se fija si termine con las filas   
     je .fin
     xor rcx, rcx         ;reseto contador columnas
  .cicloColumna:
      cmp rcx, r8 
      je .avanzoFila
      movdqu xmm0,[rsi] ;cargo el pixel a cargar
      mov rax, rsi  ;rax = rsi
      lea rax, [rax - r14*4] ;estoy en la fila superior
      movdqu xmm1, [rax]; cargo vecinos superiores
      lea rax, [rax + r14 * 8]; estoy en la fila inferior
      movdqu xmm2, [rax] ; cargo vecinos inferiores
      pand xmm0, [mascara] ; hago cero la basura
      pand xmm1, [mascara] ; hago cero la basura
      pand xmm2, [mascara] ; hago cero la basura
      

      inc rcx ;incremente la columna
      lea rsi, [rsi + 4];mueve al siguiente el puntero de pixel a cargar
      jmp .cicloColumna
      .avanzoFila:
        inc rdx ;incremento contador fila
        lea rdi,[rdi+ r14*4] ; rdi+=columnas*4 pongo el puntero fila actual en la siguiente
        mov rsi, rdi          ; pongo el puntero pixeles a cargar en el inicio de la fila
        jmp .ciclofila
                         
                           

.fin:
  mov qword rdi, rax
  call free                    ;libero la memoria de la imagen copia
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp
  ret
