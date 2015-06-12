; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================
; definicion de rutinas de atencion de interrupciones

%include "imprimir.mac"

BITS 32

sched_tarea_offset:     dd 0x00
sched_tarea_selector:   dw 0x00
offset: dd 0
selector: dw 0
;; PIC
extern fin_intr_pic1

;; Sched
extern sched_tick
extern sched_tarea_actual
extern screen_actualizar_reloj_global
extern imprime_tecla


;;
;; Definición de MACROS
;; -------------------------------------------------------------------------- ;;

;%macro ISR 1
;global _isr%1


;_isr%1:
;    mov eax, %1
;    jmp $

;%endmacro
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
global _isr32
global _isr33
global _isr70

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
;;
;; Datos
;; -------------------------------------------------------------------------- ;;
; Scheduler

tecla: db 0x00
;;
;; Rutina de atención de las EXCEPCIONES
;; -------------------------------------------------------------------------- ;;
;ISR 0
_isr0:
    push ebp
    mov ebp, esp
    pushad
    imprimir_texto_mp int0_capturada, int0_capturada_len, 0x07, 20, 30
    jmp $

_isr1:
    push ebp
    mov ebp, esp
    pushad
    imprimir_texto_mp int1_capturada, int1_capturada_len, 0x07, 20, 30
    jmp $

_isr2:
    push ebp
    mov ebp, esp
    pushad
    imprimir_texto_mp int2_capturada, int2_capturada_len, 0x07, 20, 30
    jmp $

_isr3:
    push ebp
    mov ebp, esp
    pushad
    imprimir_texto_mp int3_capturada, int3_capturada_len, 0x07, 20, 30
    jmp $

_isr4:
    push ebp
    mov ebp, esp
    pushad
    imprimir_texto_mp int4_capturada, int4_capturada_len, 0x07, 20, 30
    jmp $

_isr5:;BOUND Range Exceeded Exception
    push ebp
    mov ebp, esp
    pushad

    imprimir_texto_mp int5_capturada, int5_capturada_len, 0x07, 20, 30
    jmp $

_isr6:
    push ebp
    mov ebp, esp
    pushad

    imprimir_texto_mp int6_capturada, int6_capturada_len, 0x07, 20, 30
    jmp $

_isr7:
    push ebp
    mov ebp, esp
    pushad

    imprimir_texto_mp int7_capturada, int7_capturada_len, 0x07, 20, 30
    jmp $

_isr8:;Double Fault Exception
    push ebp
    mov ebp, esp
    pushad

    imprimir_texto_mp int8_capturada, int8_capturada_len, 0x07, 20, 30
    
    
    jmp $

_isr9:;Coprocessor Segment Overrun
    push ebp
    mov ebp, esp
    pushad

    imprimir_texto_mp int9_capturada, int9_capturada_len, 0x07, 20, 30
    jmp $

_isr10:;invalid TSS
    push ebp
    mov ebp, esp
    pushad

    imprimir_texto_mp int10_capturada, int10_capturada_len, 0x07, 20, 30
    
    jmp $

_isr11:;Segment Not Present
    push ebp
    mov ebp, esp
    pushad

    imprimir_texto_mp int11_capturada, int11_capturada_len, 0x07, 20, 30
    
    jmp $

_isr12:;Stack Fault Exception
    push ebp
    mov ebp, esp
    pushad

    imprimir_texto_mp int12_capturada, int12_capturada_len, 0x07, 20, 30
    
    jmp $

_isr13:
    push ebp
    mov ebp, esp
    pushad

    imprimir_texto_mp int13_capturada, int13_capturada_len, 0x07, 20, 30
    
    jmp $

_isr14:
    push ebp
    mov ebp, esp
    pushad


    imprimir_texto_mp int14_capturada, int14_capturada_len, 0x07, 20, 30
    
    
    jmp $
    

_isr17:
    push ebp
    mov ebp, esp
    pushad

    imprimir_texto_mp int17_capturada, int17_capturada_len, 0x07, 20, 30
   
    jmp $

;;
;; Rutina de atención del RELOJ
;; -------------------------------------------------------------------------- ;;
_isr32:

    pushad

    call screen_actualizar_reloj_global

    call game_ver_si_termina

    call sched_proximo_indice
    cmp ax, 0xff
    je .nojump
    mov bx, [selector]
    cmp ax, bx
    je .nojump
    mov [selector], ax
    call fin_intr_pic1

    jmp far [offset]

    jmp .end

    .nojump:
      call fin_intr_pic1

    .end:
      popad
      iret
    popad
    iret
;;
;; Rutina de atención del TECLADO
;; -------------------------------------------------------------------------- ;;
_isr33:

   pushad

   xor eax, eax
   mov al, [tecla]
   push eax
   in al, 0x60
   push eax
   call imprime_tecla
   cmp eax, 0
   je .next
   pop eax
   mov [tecla], al
   jmp .sale
   
   .next:
    add esp, 4
   
   .sale:
    
    call fin_intr_pic1
   
    add esp, 4
    popad
   iret


_isr70:
    ;push ebp
    ;mov ebp, esp
    ;call fin_intr_pic1
    ;mov eax, 0x42

    ;pop ebp
    ;iret
    ;~ xchg bx,bx
	pushad
	push eax
        push ecx
	call game_syscall_manejar
	call fin_intr_pic1
	pop eax
        pop ecx
	popad
	;~ xchg bx,bx
	iret
    
;;
;; Rutinas de atención de las SYSCALLS
;; -------------------------------------------------------------------------- ;;


