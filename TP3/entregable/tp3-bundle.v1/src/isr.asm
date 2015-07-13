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
extern game_syscall_manejar
extern game_ver_si_termina
extern sched_proximo_indice
extern tiempo_sin_juego
extern game_atender_teclado
extern pasar_a_idle
extern debug
extern game_matar_pirata_interrupt
extern screen_muestra_error

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
global _isr15
global _isr16
global _isr17
global _isr18
global _isr19
global _isr1
global _isr2
global _isr3
global _isr4
global _isr6
global _isr7
global _isr32
global _isr33
global _isr70

int0_capturada: db "Divide Error Exception",0
int0_capturada_len equ $ - int0_capturada

int1_capturada: db "Debug Exception",0
int1_capturada_len equ $ - int1_capturada

int2_capturada: db "NMI Interrupt",0
int2_capturada_len equ $ - int2_capturada

int3_capturada: db "Breakpoint Exception",0
int3_capturada_len equ $ - int3_capturada

int4_capturada: db "Overflow Exception",0
int4_capturada_len equ $ - int4_capturada

int5_capturada: db "BOUND Range Exceeded Exception!",0
int5_capturada_len equ $ - int5_capturada

int6_capturada: db "Invalid Opcode Exception",0
int6_capturada_len equ $ - int6_capturada

int7_capturada: db "Device Not Available Exception!",0
int7_capturada_len equ $ - int7_capturada

int8_capturada: db "Double Fault Exception",0
int8_capturada_len equ $ - int8_capturada

int9_capturada: db "Coprocessor Segment Overrun",0
int9_capturada_len equ $ - int9_capturada

int10_capturada: db "invalid TSS",0
int10_capturada_len equ $ - int10_capturada

int11_capturada: db "Segment Not Present",0
int11_capturada_len equ $ - int11_capturada

int12_capturada: db "Stack Fault Exception!",0
int12_capturada_len equ $ - int12_capturada

int14_capturada: db "Page-Fault Exception",0
int14_capturada_len equ $ - int14_capturada

int13_capturada: db "General Protection",0
int13_capturada_len equ $ - int13_capturada

int15_capturada: db "Reserved",0
int15_capturada_len equ $ - int15_capturada

int16_capturada: db "Coprocessor Error",0
int16_capturada_len equ $ - int16_capturada

int17_capturada: db "Alignment Check Exception",0
int17_capturada_len equ $ - int17_capturada

int18_capturada: db "Reserved",0
int18_capturada_len equ $ - int18_capturada

int19_capturada: db "Reserved",0
int19_capturada_len equ $ - int19_capturada
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
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int0_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad
 
    call game_matar_pirata_interrupt


    ;imprimir_texto_mp int0_capturada, int0_capturada_len, 0x07, 20, 30
    xchg bx,bx

    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
     

_isr1:
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int1_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

    call game_matar_pirata_interrupt

    ;imprimir_texto_mp int1_capturada, int1_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
     

_isr2:
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int2_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

    call game_matar_pirata_interrupt 

    ;imprimir_texto_mp int2_capturada, int2_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti

     

_isr3:
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int3_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

     call game_matar_pirata_interrupt

    ;imprimir_texto_mp int3_capturada, int3_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti

     

_isr4:
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int4_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

     call game_matar_pirata_interrupt

    ;imprimir_texto_mp int4_capturada, int4_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti

     

_isr5:;BOUND Range Exceeded Exception
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int5_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

     call game_matar_pirata_interrupt

    ;imprimir_texto_mp int5_capturada, int5_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
     

_isr6:
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int6_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

     call game_matar_pirata_interrupt
 
    ;imprimir_texto_mp int6_capturada, int6_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
     

_isr7:
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int7_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

    call game_matar_pirata_interrupt


    ;imprimir_texto_mp int7_capturada, int7_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti

_isr8:;Double Fault Exception
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int8_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

     call game_matar_pirata_interrupt
    
    ;imprimir_texto_mp int8_capturada, int8_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti

_isr9:;Coprocessor Segment Overrun
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int9_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

     call game_matar_pirata_interrupt


    ;imprimir_texto_mp int9_capturada, int9_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
    

_isr10:;invalid TSS
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int10_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

     call game_matar_pirata_interrupt


    ;imprimir_texto_mp int10_capturada, int10_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
    

_isr11:;Segment Not Present
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int11_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

     call game_matar_pirata_interrupt
   
    ;imprimir_texto_mp int11_capturada, int11_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error	
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
    

_isr12:;Stack Fault Exception
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int12_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

    call game_matar_pirata_interrupt

    ;imprimir_texto_mp int12_capturada, int12_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
    popad

_isr13:
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int13_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

    call game_matar_pirata_interrupt

    ;imprimir_texto_mp int13_capturada, int13_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error	
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
    popad

_isr14:
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int14_capturada
	push eax
    mov ebp, esp
    ;pushad

    
    call game_matar_pirata_interrupt

    ;imprimir_texto_mp int14_capturada, int14_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti

    
_isr15:;
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int15_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

     call game_matar_pirata_interrupt
   
    ;imprimir_texto_mp int11_capturada, int11_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $	
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
    

_isr16:;
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int16_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

     call game_matar_pirata_interrupt
   
    ;imprimir_texto_mp int11_capturada, int11_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error	
	
     ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
_isr17:
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int17_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

    call game_matar_pirata_interrupt

    ;imprimir_texto_mp int17_capturada, int17_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
    

_isr18:;
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int18_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

     call game_matar_pirata_interrupt
   
    ;imprimir_texto_mp int11_capturada, int11_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error	
	 ;jmp $
	.salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
    

_isr19:;Segment Not Present
    push gs
    push fs
    push es
    push ds
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    ;mov eax, %1
    mov eax, int19_capturada
    push eax
    push ebp
    mov ebp, esp
    pushad

     call game_matar_pirata_interrupt
   
    ;imprimir_texto_mp int11_capturada, int11_capturada_len, 0x07, 20, 30
    xchg bx,bx
    cmp byte [debug], 0
	je .salir
	mov byte [debug], 2 ;modo mostrando

    call screen_muestra_error
	
     ;jmp $
    .salir:

    call pasar_a_idle
    push eax
    call cambiar_tarea_ya
    add esp, 13*4
        
    iret
    sti
;;
;; Rutina de atención del RELOJ
;; -------------------------------------------------------------------------- ;;
_isr32:

    pushad
    xchg bx,bx
    call fin_intr_pic1
    call screen_actualizar_reloj_global

    call game_ver_si_termina

    call sched_proximo_indice
    cmp ax, 0xff
    je .nojump
    mov bx, [selector]
    cmp ax, bx
    je .nojump
    mov [selector], ax
    ;call fin_intr_pic1
    jmp far [offset]

    jmp .end

    .nojump:
      add dword [tiempo_sin_juego], 1
      call fin_intr_pic1

    .end:
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
   ;call imprime_tecla
   call game_atender_teclado
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
    ;xchg bx,bx
	pushad
	;call fin_intr_pic1
	push ecx
        push eax
	;xchg bx,bx
	call game_syscall_manejar
        ;call fin_intr_pic1
        ;xchg bx,bx
	call pasar_a_idle
	mov [selector], ax
        ;xchg bx,bx
	jmp far [offset]
	pop ecx
        pop eax
	popad
	;xchg bx,bx
	iret
    
;;
;; Rutinas de atención de las SYSCALLS
;; -------------------------------------------------------------------------- ;;


global cambiar_tarea_ya
cambiar_tarea_ya:
	;~ pushad
	;xchg bx,bx
        push ebp
        mov ebp, esp
	mov eax, [ebp+8]
        ;xchg bx,bx
	mov [selector], ax
        ;xchg bx,bx
	jmp far [offset]
	
        pop ebp
	;~ popad
	ret

