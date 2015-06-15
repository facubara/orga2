/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de estructuras para administrar tareas
*/

#include "tss.h"
#include "mmu.h"


tss tss_inicial;
tss tss_idle;

tss tss_jugadorA[MAX_CANT_PIRATAS_VIVOS];
tss tss_jugadorB[MAX_CANT_PIRATAS_VIVOS];

void tss_inicializar() {
	tss* tarea_inicial = (tss*) obtener_pagina_libre();
	tss* tarea_A1 = (tss*) obtener_pagina_libre();
	tss* tarea_A2 = (tss*) obtener_pagina_libre();
	tss* tarea_A3 = (tss*) obtener_pagina_libre();
	tss* tarea_A4 = (tss*) obtener_pagina_libre();
	tss* tarea_A5 = (tss*) obtener_pagina_libre();
	tss* tarea_A6 = (tss*) obtener_pagina_libre();
	tss* tarea_A7 = (tss*) obtener_pagina_libre();
	tss* tarea_A8 = (tss*) obtener_pagina_libre();
	tss* tarea_B1 = (tss*) obtener_pagina_libre();
	tss* tarea_B2 = (tss*) obtener_pagina_libre();
	tss* tarea_B3 = (tss*) obtener_pagina_libre();
	tss* tarea_B4 = (tss*) obtener_pagina_libre();
	tss* tarea_B5 = (tss*) obtener_pagina_libre();
	tss* tarea_B6 = (tss*) obtener_pagina_libre();
	tss* tarea_B7 = (tss*) obtener_pagina_libre();
	tss* tarea_B8 = (tss*) obtener_pagina_libre();
	
	gdt[13].base_0_15  = (unsigned int) tarea_inicial;
	gdt[13].base_23_16 = ((unsigned int) tarea_inicial) >> 16;
	gdt[13].base_31_24 = ((unsigned int) tarea_inicial) >> 24;
	
	gdt[14].base_0_15  = (unsigned int) &tss_idle;
	gdt[14].base_23_16 = ((unsigned int) &tss_idle) >> 16;
	gdt[14].base_31_24 = ((unsigned int) &tss_idle) >> 24;
	
	gdt[15].base_0_15  = (unsigned int) tarea_A1;
	gdt[15].base_23_16 = ((unsigned int) tarea_A1) >> 16;
	gdt[15].base_31_24 = ((unsigned int) tarea_A1) >> 24;
	
	gdt[16].base_0_15  = (unsigned int) tarea_A2;
	gdt[16].base_23_16 = ((unsigned int) tarea_A2) >> 16;
	gdt[16].base_31_24 = ((unsigned int) tarea_A2) >> 24;
	
	gdt[17].base_0_15  = (unsigned int) tarea_A3;
	gdt[17].base_23_16 = ((unsigned int) tarea_A3) >> 16;
	gdt[17].base_31_24 = ((unsigned int) tarea_A3) >> 24;
	
	gdt[18].base_0_15  = (unsigned int) tarea_A4;
	gdt[18].base_23_16 = ((unsigned int) tarea_A4) >> 16;
	gdt[18].base_31_24 = ((unsigned int) tarea_A4) >> 24;
	
	gdt[19].base_0_15  = (unsigned int) tarea_A5;
	gdt[19].base_23_16 = ((unsigned int) tarea_A5) >> 16;
	gdt[19].base_31_24 = ((unsigned int) tarea_A5) >> 24;
	
	gdt[20].base_0_15  = (unsigned int) tarea_A6;
	gdt[20].base_23_16 = ((unsigned int) tarea_A6) >> 16;
	gdt[20].base_31_24 = ((unsigned int) tarea_A6) >> 24;
	
	gdt[21].base_0_15  = (unsigned int) tarea_A7;
	gdt[21].base_23_16 = ((unsigned int) tarea_A7) >> 16;
	gdt[21].base_31_24 = ((unsigned int) tarea_A7) >> 24;
	
	gdt[22].base_0_15  = (unsigned int) tarea_A8;
	gdt[22].base_23_16 = ((unsigned int) tarea_A8) >> 16;
	gdt[22].base_31_24 = ((unsigned int) tarea_A8) >> 24;
	
	gdt[23].base_0_15  = (unsigned int) tarea_B1;
	gdt[23].base_23_16 = ((unsigned int) tarea_B1) >> 16;
	gdt[23].base_31_24 = ((unsigned int) tarea_B1) >> 24;
	
	gdt[24].base_0_15  = (unsigned int) tarea_B2;
	gdt[24].base_23_16 = ((unsigned int) tarea_B2) >> 16;
	gdt[24].base_31_24 = ((unsigned int) tarea_B2) >> 24;
	
	gdt[25].base_0_15  = (unsigned int) tarea_B3;
	gdt[25].base_23_16 = ((unsigned int) tarea_B3) >> 16;
	gdt[25].base_31_24 = ((unsigned int) tarea_B3) >> 24;
	
	gdt[26].base_0_15  = (unsigned int) tarea_B4;
	gdt[26].base_23_16 = ((unsigned int) tarea_B4) >> 16;
	gdt[26].base_31_24 = ((unsigned int) tarea_B4) >> 24;
	
	gdt[27].base_0_15  = (unsigned int) tarea_B5;
	gdt[27].base_23_16 = ((unsigned int) tarea_B5) >> 16;
	gdt[27].base_31_24 = ((unsigned int) tarea_B5) >> 24;
	
	gdt[28].base_0_15  = (unsigned int) tarea_B6;
	gdt[28].base_23_16 = ((unsigned int) tarea_B6) >> 16;
	gdt[28].base_31_24 = ((unsigned int) tarea_B6) >> 24;
	
	gdt[29].base_0_15  = (unsigned int) tarea_B7;
	gdt[29].base_23_16 = ((unsigned int) tarea_B7) >> 16;
	gdt[29].base_31_24 = ((unsigned int) tarea_B7) >> 24;
	
	gdt[30].base_0_15  = (unsigned int) tarea_B8;
	gdt[30].base_23_16 = ((unsigned int) tarea_B8) >> 16;
	gdt[30].base_31_24 = ((unsigned int) tarea_B8) >> 24;
	
	tss_inicializar_tarea_idle();
	
	tss_inicializar_tareas_piratas(tarea_A1);
	tss_inicializar_tareas_piratas(tarea_A2);
	tss_inicializar_tareas_piratas(tarea_A3);
	tss_inicializar_tareas_piratas(tarea_A4);
	tss_inicializar_tareas_piratas(tarea_A5);
	tss_inicializar_tareas_piratas(tarea_A6);
	tss_inicializar_tareas_piratas(tarea_A7);
	tss_inicializar_tareas_piratas(tarea_A8);
	tss_inicializar_tareas_piratas(tarea_B1);
	tss_inicializar_tareas_piratas(tarea_B2);
	tss_inicializar_tareas_piratas(tarea_B3);
	tss_inicializar_tareas_piratas(tarea_B4);
	tss_inicializar_tareas_piratas(tarea_B5);
	tss_inicializar_tareas_piratas(tarea_B6);
	tss_inicializar_tareas_piratas(tarea_B7);
	tss_inicializar_tareas_piratas(tarea_B8);
	
	piratasA[0].tss = tarea_A1;
	piratasA[1].tss = tarea_A2;
	piratasA[2].tss = tarea_A3;
	piratasA[3].tss = tarea_A4;
	piratasA[4].tss = tarea_A5;
	piratasA[5].tss = tarea_A6;
	piratasA[6].tss = tarea_A7;
	piratasA[7].tss = tarea_A8;
	piratasB[0].tss = tarea_B1;
	piratasB[1].tss = tarea_B2;
	piratasB[2].tss = tarea_B3;
	piratasB[3].tss = tarea_B4;
	piratasB[4].tss = tarea_B5;
	piratasB[5].tss = tarea_B6;
	piratasB[6].tss = tarea_B7;
	piratasB[7].tss = tarea_B8;
}


void tss_inicializar_tarea_idle() {
	tss_idle.ptl      = 0;
	tss_idle.unused0  = 0;
	tss_idle.esp0     = 0;
	tss_idle.ss0      = 0;
	tss_idle.unused1  = 0;
	tss_idle.esp1     = 0;
	tss_idle.ss1      = 0;
	tss_idle.unused2  = 0;
	tss_idle.esp2     = 0;
	tss_idle.ss2      = 0;
	tss_idle.unused3  = 0;
	tss_idle.cr3      = dir_kernel_addr;
	tss_idle.eip      = 0x16000;
	tss_idle.eflags   = 0x202;
	tss_idle.eax      = 0;
	tss_idle.ecx      = 0;
	tss_idle.edx      = 0;
	tss_idle.ebx      = 0;
	tss_idle.esp      = dir_kernel_addr;
	tss_idle.ebp      = dir_kernel_addr;
	tss_idle.esi      = 0;
	tss_idle.edi      = 0;
	tss_idle.es       = 0x0050;
	tss_idle.unused4  = 0;
	tss_idle.cs       = 0x0040;
	tss_idle.unused5  = 0;
	tss_idle.ss       = 0x0050;
	tss_idle.unused6  = 0;
	tss_idle.ds       = 0x0050;
	tss_idle.unused7  = 0;
	tss_idle.fs       = 0x0050;
	tss_idle.unused8  = 0;
	tss_idle.gs       = 0x0050;
	tss_idle.unused9  = 0;
	tss_idle.ldt      = 0;
	tss_idle.unused10 = 0;
	tss_idle.dtrap    = 0;
	tss_idle.iomap    = 0xFFFF;
}


void tss_inicializar_tareas_piratas(tss *mi_tss) {
	mi_tss->ptl      = 0;
	mi_tss->unused0  = 0;
	mi_tss->esp0     = obtener_pagina_libre()+0x1000;
	mi_tss->ss0      = 0x0050;
	mi_tss->unused1  = 0;
	mi_tss->esp1     = 0;
	mi_tss->ss1      = 0;
	mi_tss->unused2  = 0;
	mi_tss->esp2     = 0;
	mi_tss->ss2      = 0;
	mi_tss->unused3  = 0;
	mi_tss->cr3      = 0;	// Esto se modifica al lanzar el zombi
	mi_tss->eip      = 0x400000;
	mi_tss->eflags   = 0x202;
	mi_tss->eax      = 0;
	mi_tss->ecx      = 0;
	mi_tss->edx      = 0;
	mi_tss->ebx      = 0;
	mi_tss->esp      = 0x400000+0x1000; //0x8000000+0x1000;
	mi_tss->ebp      = 0x400000+0x1000; //0x8000000+0x1000;
	mi_tss->esi      = 0;
	mi_tss->edi      = 0;
	mi_tss->es       = 0x005B;
	mi_tss->unused4  = 0;
	mi_tss->cs       = 0x004B;
	mi_tss->unused5  = 0;
	mi_tss->ss       = 0x005B;
	mi_tss->unused6  = 0;
	mi_tss->ds       = 0x005B;
	mi_tss->unused7  = 0;
	mi_tss->fs       = 0x005B;
	mi_tss->unused8  = 0;
	mi_tss->gs       = 0x005B;
	mi_tss->unused9  = 0;
	mi_tss->ldt      = 0;
	mi_tss->unused10 = 0;
	mi_tss->dtrap    = 0;
	mi_tss->iomap    = 0xFFFF;
}
