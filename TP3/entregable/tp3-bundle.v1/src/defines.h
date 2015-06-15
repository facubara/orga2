/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

    Definiciones globales del sistema.
*/

#ifndef __DEFINES_H__
#define __DEFINES_H__

/* Tipos basicos */
/* -------------------------------------------------------------------------- */
#define NULL                    0
#define TRUE                    0x00000001
#define FALSE                   0x00000000
#define ERROR                   1

typedef unsigned char  uchar;
typedef unsigned short ushort;
typedef unsigned int   uint;

/* Constantes basicas */
/* -------------------------------------------------------------------------- */
#define PAGE_SIZE               0x00001000
#define TASK_SIZE               4096

#define BOOTSECTOR              0x00001000 /* direccion fisica de comienzo del bootsector (copiado) */
#define KERNEL                  0x00001200 /* direccion fisica de comienzo del kernel */


#define dir_kernel_addr 	0x27000
#define table_0_kernel_addr 0x28000
#define table_1_kernel_addr 0x29000


/* Indices en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_COUNT 32

#define GDT_IDX_NULL_DESC           0
#define	seg_datos_usr = 0x005B // 0b1011011; // 11 DPL 3
#define	seg_codigo_usr = 0x004B //0b1001011; // 9 DPL 3
#define	seg_codigo_ker = 0x0040 //0b1000000; // 8 dpl =0
#define	seg_datos_ker = 0x0050 //0b1010000;  // 10 dpl = 0


/* Offsets en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_OFF_NULL_DESC           (GDT_IDX_NULL_DESC      << 3)

/* Selectores de segmentos */
/* -------------------------------------------------------------------------- */

void* error();

#define ASSERT(x) while(!(x)) {};


#endif  /* !__DEFINES_H__ */
