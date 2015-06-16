; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "imprimir.mac"

global start


;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
iniciando_mr_msg db     'Iniciando kernel (Modo Real)...'
iniciando_mr_len equ    $ - iniciando_mr_msg

iniciando_mp_msg db     'Iniciando kernel (Modo Protegido)...'
iniciando_mp_len equ    $ - iniciando_mp_msg

%define dir_kernel_addr 0x27000
%define selector_Inicial 0x006b ;0000000001101011
%define selector_Idle 0x073 ;0000 0000 0111 0011
;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; Deshabilitar interrupciones
    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; Imprimir mensaje de bienvenida
    imprimir_texto_mr iniciando_mr_msg, iniciando_mr_len, 0x07, 0, 0


    ; Habilitar A20

    call habilitar_A20

    ; Cargar la GDT

    lgdt [GDT_DESC]
    ; Setear el bit PE del registro CR0

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Saltar a modo protegido

    jmp 0x40:mp


    ; Establecer selectores de segmentos

BITS 32
  mp:

    xor eax, eax
    mov ax, 0x50       ; index = 10 / gdt/ldt = 0 / rpl = 0
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov ss, ax
    mov ax, 0x60
    mov fs, ax             ; no se esto

    ; Establecer la base de la pila
    
    mov ebp, 0x27000
    mov esp, 0x27000

    ; Imprimir mensaje de bienvenida
    
     imprimir_texto_mp iniciando_mp_msg, iniciando_mp_len, 0x07, 3, 0


    ; Inicializar el juego

    ; Inicializar pantalla

    call inic_video
 

    ; Inicializar el manejador de memoria
    call mmu_iniciar
    ; Inicializar el directorio de paginas
    mov eax, dir_kernel_addr ;0x27000
    ; Cargar directorio de paginas
    mov cr3, eax
   
    ; Habilitar paginacion

    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
 
    ; IMPIMIR NOMBRE DE GRUPO POR PANTALLA
    call imprime_nombre_grupo




    ; Inicializar tss
    call tss_inicializar

    ; Inicializar el scheduler
    call inicializar_scheduler
    
    ; Inicializar la IDT
    call idt_inicializar
    ; Cargar IDT
    lidt [IDT_DESC]
    ; Configurar controlador de interrupciones 
    call resetear_pic
    call habilitar_pic

    ; Cargar tarea inicial

        mov ax, selector_Inicial
        ltr ax

    ; Habilitar interrupciones
    sti
    
    ; Saltar a la primera tarea: Idle
    mov ax, selector_Idle
    mov es, ax 
    jmp selector_Idle:0

    ; Ciclar infinitamente (por si algo sale mal...)
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    xchg bx,bx
    jmp $
    jmp $
   
;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
extern GDT_DESC
extern IDT_DESC
extern inic_video
extern imprime_nombre_grupo
extern idt_inicializar
extern mmu_inicializar_dir_kernel
extern deshabilitar_pic
extern resetear_pic
extern habilitar_pic
extern mmu_iniciar
extern mmu_inic_dir_pirata
extern tarea_al_mapa
extern mmu_mapear_pagina
extern inicializar_scheduler
extern tss_inicializar