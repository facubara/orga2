; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================
; definicion de rutinas de atencion de interrupciones

%include "imprimir.mac"

BITS 32

sched_tarea_offset:     dd 0x00
sched_tarea_selector:   dw 0x00

int0_capturada: db "Divide Error Exception"
int0_capturada_len equ $ - int0_capturada

int1_capturada: db "Debug Exception"
int1_capturada_len equ $ - int1_capturada

int2_capturada: db "NMI Interrupt",0
int2_capturada_len equ $ - int2_capturada

int3_capturada: db "Breakpoint Exception"
int3_capturada_len equ $ - int3_capturada

int4_capturada: db "Overflow Exception"
int4_capturada_len equ $ - int4_capturada

int5_capturada: db "BOUND Range Exceeded Exception!"
int5_capturada_len equ $ - int5_capturada

int6_capturada: db "Invalid Opcode Exception"
int6_capturada_len equ $ - int6_capturada

int7_capturada: db "Device Not Available Exception!"
int7_capturada_len equ $ - int7_capturada

int8_capturada: db "Double Fault Exception"
int8_capturada_len equ $ - int8_capturada

int9_capturada: db "Coprocessor Segment Overrun"
int9_capturada_len equ $ - int9_capturada

int10_capturada: db "invalid TSS"
int10_capturada_len equ $ - int10_capturada

int11_capturada: db "Segment Not Present"
int11_capturada_len equ $ - int11_capturada

int12_capturada: db "Stack Fault Exception!"
int12_capturada_len equ $ - int12_capturada

int14_capturada: db "Page-Fault Exception"
int14_capturada_len equ $ - int14_capturada

int13_capturada: db "General Protection"
int13_capturada_len equ $ - int13_capturada

int17_capturada: db "Alignment Check Exception"
int17_capturada_len equ $ - int17_capturada




;; PIC
extern fin_intr_pic1

;; Sched
extern sched_proximo_indice

;screen.c
extern print_hex
extern game_actualizarFrame
extern game_cambiarClase_adelante
extern game_cambiarClase_atras
extern game_moverJugador
extern game_lanzar_zombi
;;
;; Definición de MACROS
;; -------------------------------------------------------------------------- ;;

;;
;; Datos
;; -------------------------------------------------------------------------- ;;
; Scheduler
isrnumero:           dd 0x00000000
isrClock:            db '|/-\'

;;
;; Rutina de atención de las EXCEPCIONES
;; -------------------------------------------------------------------------- ;;

global _isr0
global _isr5
global _isr8
global _isr9
global _isr10
global _isr11
global _isr12
global _isr13
global _isr14
global _isr17
global _isr1
global _isr2
global _isr3
global _isr4
global _isr6
global _isr7


%define Tab 0x0f
%define Q 0x10
%define W 0x11
%define E 0x12
%define R 0x13
%define T 0x14
%define Y 0x15
%define U 0x16
%define I 0x17
%define O 0x18
%define P 0x19
%define BrktL{ 0x1a
%define BrktR} 0x1b
%define nter 0x1c
%define LCtrl 0x1d
%define A 0x1e
%define S 0x1f
%define D 0x20
%define F 0x21
%define G 0x22
%define H 0x23
%define J 0x24
%define K 0x25
%define L 0x26
%define ptoYcoma 0x27
%define comas 0x28
;%define `~ 0x29
%define LShift 0x2a
;%define \| 0x2b
%define Z 0x2c
%define X 0x2d
%define C 0x2e
%define V 0x2f
%define B 0x30
%define N 0x31
%define M 0x32
%define coma< 0x33
%define punto> 0x34
%define Barra/Pregunta 0x35
%define RShift 0x36
;%define Keypad-* 0x37
%define LAlt 0x38
%define Space bar 0x39
%define CapsLock 0x3a
%define F1 0x3b
%define F2 0x3c
%define F3 0x3d
%define F4 0x3e
%define F5 0x3f
%define F6 0x40
%define F7 0x41
%define F8 0x42
%define F9 0x43
%define F10 0x44
%define NumLock 0x45 
%define ScrollLock 0x46 
%define Keypad/Home 0x47 
%define Keypad/Up 0x48 
%define Keypad/PgUp 0x49 
;%define Keypad 0x4a 
%define Keypad/Left 0x4b 
;%define Keypad 0x4c 
%define Keypad/Right 0x4d
;%define Keypad 0x4e
%define Keypad/End 0x4f
%define Keypad/Down 0x50
%define Keypad/PgDn 0x51
;%define Keypad 0x52
%define Keypad/Del 0x53

extern game_error_handling
;en caso de que el error sea en la pila, esto podria traer porblemas
extern print
_isr0:
    push ebp
    mov ebp, esp
    pushad
    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int0_capturada, int0_capturada_len, 0x07, 20, 30
    jmp $

_isr1:
    push ebp
    mov ebp, esp
    pushad
    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int1_capturada, int1_capturada_len, 0x07, 20, 30
    jmp $

_isr2:
    push ebp
    mov ebp, esp
    pushad
    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int2_capturada, int2_capturada_len, 0x07, 20, 30
    jmp $

_isr3:
    push ebp
    mov ebp, esp
    pushad
    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int3_capturada, int3_capturada_len, 0x07, 20, 30
    jmp $

_isr4:
    push ebp
    mov ebp, esp
    pushad

    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int4_capturada, int4_capturada_len, 0x07, 20, 30
    jmp $

_isr5:;BOUND Range Exceeded Exception
    push ebp
    mov ebp, esp
    pushad

    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int5_capturada, int5_capturada_len, 0x07, 20, 30
    jmp $

_isr6:
    push ebp
    mov ebp, esp
    pushad

    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int6_capturada, int6_capturada_len, 0x07, 20, 30
    jmp $

_isr7:
    push ebp
    mov ebp, esp
    pushad

    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int7_capturada, int7_capturada_len, 0x07, 20, 30
    jmp $

_isr8:;Double Fault Exception
    push ebp
    mov ebp, esp
    pushad

    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int8_capturada, int8_capturada_len, 0x07, 20, 30
    
    jmp imprimirErrorCode
    jmp $

_isr9:;Coprocessor Segment Overrun
    push ebp
    mov ebp, esp
    pushad

    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int9_capturada, int9_capturada_len, 0x07, 20, 30
    jmp $

_isr10:;invalid TSS
    push ebp
    mov ebp, esp
    pushad

    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int10_capturada, int10_capturada_len, 0x07, 20, 30
    jmp imprimirErrorCode
    jmp $

_isr11:;Segment Not Present
    push ebp
    mov ebp, esp
    pushad

    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int11_capturada, int11_capturada_len, 0x07, 20, 30
    jmp imprimirErrorCode
    jmp $

_isr12:;Stack Fault Exception
    push ebp
    mov ebp, esp
    pushad

    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int12_capturada, int12_capturada_len, 0x07, 20, 30
    jmp imprimirErrorCode
    jmp $

_isr13:
    push ebp
    mov ebp, esp
    pushad

    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int13_capturada, int13_capturada_len, 0x07, 20, 30
    jmp imprimirErrorCode
    jmp $

_isr14:
    push ebp
    mov ebp, esp
    pushad

    call game_error_handling
    cmp eax, 0
    je errorZombie

    imprimir_texto_mp int14_capturada, int14_capturada_len, 0x07, 20, 30
    
    jmp imprimirErrorCode
    jmp $
    

_isr17:
    push ebp
    mov ebp, esp
    pushad

    call game_error_handling
    cmp eax, 0
    je errorZombie
    imprimir_texto_mp int17_capturada, int17_capturada_len, 0x07, 20, 30
    jmp imprimirErrorCode
    jmp $

extern game_imprimir_stack
DEBUG_MODE dd 0x0
AUX dd 0x0

errorZombie:
    cmp dword [DEBUG_MODE], 0
    jz .salto
;imprimo las cosas modo debug
    popad

    ;xchg bx, bx
    push dword [ebp +16];eflags
    push  ss 
    push  gs
    push  fs
    push es
    push ds
    push  cs
    push dword [ebp+8];eip
    push dword [ebp+20] ;esp
    push dword [ebp] ;ebp
    push  edi
    push  esi
    push  edx
    push  ecx
    push  ebx
    push  eax
    call game_imprimir_stack    
    add esp, 20*4
;me quedo haciendo pooling de la tecla Y
.pooling:
    in al, 0x60
    cmp al, Y
    jnz .pooling
.salto:
    mov word [selector], 0x70
    JMP far [offset]
    ;bueno, ya maté la tarea, salto a idle

text_code: db "Code Error:"
text_code_len equ $ - text_code

imprimirErrorCode:
    imprimir_texto_mp text_code, text_code_len, 0x07, 21, 30
    mov edi, [esp+4]
    push 0x07
    push 22
    push 30
    push 8
    push dword edi
    call print_hex
    jmp $


;;
;; Rutina de atención del RELOJ
;; -------------------------------------------------------------------------- ;;

offset dd 0
selector dw 0x70

global _isr32
_isr32:
    pushad

        
    ;xchg bx, bx
    ;con cada tic del reloj, actualizo la pantalla
    call game_actualizarFrame

    call proximo_reloj
    ;pido la proxima tarea
    call sched_proximo_indice

    cmp ax,[selector]
    je  .noJump
        mov [selector], ax
        call fin_intr_pic1  
        JMP far [offset]  
        jmp .end
.noJump:
    call fin_intr_pic1    
.end:
    
    popad
    iret

;;
;; Rutina de atención del TECLADO
;; -------------------------------------------------------------------------- ;;

global _isr33
_isr33:
    pushad
    in al, 0x60
    cmp al, W
    jz .W
    cmp al, A
    jz .A
    cmp al, B
    jz .fin
    cmp al, C
    jz .fin
    cmp al, D
    jz .D
    cmp al, E
    jz .fin
    cmp al, F
    jz .fin
    cmp al, G
    jz .fin
    cmp al, H
    jz .fin
    cmp al, I
    jz .I
    cmp al, J
    jz .J
    cmp al, K
    jz .K
    cmp al, L
    jz .L
    cmp al, M
    jz .fin
    cmp al, N
    jz .fin
    cmp al, O
    jz .fin
    cmp al, P
    jz .fin
    cmp al, Q
    jz .fin
    cmp al, R
    jz .fin
    cmp al, S
    jz .S
    cmp al, T
    jz .fin
    cmp al, Y
    jz .Y
    cmp al, Z
    jz .fin
    cmp al, V
    jz .fin
    cmp al,RShift
    jz .RShift
    cmp al,LShift
    jz .LShift
    jmp .fin

.Y:
    mov dword [DEBUG_MODE], 1
    jmp .fin
.I:
    ; moverJugadorA(1);
    push -1
    push 0
    call game_moverJugador
    add esp, 8
    jmp .fin
.K:
    push 1
    push 0
    call game_moverJugador
    add esp, 8
    jmp .fin
.L:
    push 0
    call game_cambiarClase_adelante
    add esp,4
    jmp .fin

.J:
    push 0
    call game_cambiarClase_atras  
    add esp,4
    jmp .fin

.W:
    ; moverJugadorA(1);
    push -1
    push 1
    call game_moverJugador
    add esp, 8
    jmp .fin
.S:
    push 1
    push 1
    call game_moverJugador
    add esp, 8
    jmp .fin
.D:
    push 1
    call game_cambiarClase_adelante
    add esp,4
    jmp .fin

.A:
    push 1
    call game_cambiarClase_atras  
    add esp, 4
    jmp .fin
.RShift:
    push 0
    call game_lanzar_zombi
    add esp, 4
    jmp .fin
.LShift:
    push 1
    ;xchg bx,bx
    call game_lanzar_zombi
    ;xchg bx,bx
    add esp, 4
    jmp .fin
.fin:
    call fin_intr_pic1
    popad
    iret


;;
;; Rutinas de atención de las SYSCALLS
;; -------------------------------------------------------------------------- ;;
%define IZQ 0xAAA
%define DER 0x441
%define ADE 0x83D
%define ATR 0x732


extern game_move_current_zombi
;102 -> 0x66
global _isr102
_isr102:
    pushad
    ;llamo a game_move_current_zombi(direccion dir)
    push eax
    call game_move_current_zombi
    add esp, 4
    ;ok, hago taskswitch a idle
    mov word [selector], 0x70
    JMP far [offset]
    
    popad
    iret

int99_capturada db "Paginas para manejo de mmu/tss agotadas"
int99_capturada_len equ $ - int99_capturada
global _isr99:
_isr99:
    pushad
    imprimir_texto_mp int14_capturada, int14_capturada_len, 0x07, 20, 30
    jmp $



;; Funciones Auxiliares
;; -------------------------------------------------------------------------- ;;
;solo tiene que llamarse por la interrupcion, sino la pantalla se va a actualizar de manera random
;not good
proximo_reloj:
        pushad

        inc DWORD [isrnumero]
        mov ebx, [isrnumero]
        cmp ebx, 0x4
        jl .ok
                mov DWORD [isrnumero], 0x0
                mov ebx, 0
        .ok:
                add ebx, isrClock
                imprimir_texto_mp ebx, 1, 0x0f, 49, 79
                popad
        ret
        
        
