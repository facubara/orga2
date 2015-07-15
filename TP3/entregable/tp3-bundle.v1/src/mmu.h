/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del manejador de memoria
*/

#ifndef __MMU_H__
#define __MMU_H__

#include "defines.h"
#include "game.h"


#define CODIGO_BASE       0X400000

#define MAPA_BASE_FISICA  0x500000
#define MAPA_BASE_VIRTUAL 0x800000

unsigned int contador_paginas_ocupadas;

typedef struct str_page_dir_entry {
    unsigned char  p:1;			// Present
    unsigned char  rw:1;		// Read/Write
    unsigned char  su:1;		// User/Supervisor
    unsigned int   ignored:9;
    unsigned int   base:20;		// Direccion base de la pagina
} __attribute__((__packed__, aligned (4))) page_dir_entry;


void mmu_iniciar();
void mmu_inicializar_dir_kernel();
void mmu_mapear_pagina(unsigned int virtual, unsigned int cr3, unsigned int fisica, char rw, char su);
void mmu_unmapear_pagina(unsigned int virtual, unsigned int cr3);
unsigned int mmu_inic_dir_pirata();
unsigned int obtener_pagina_libre();
void mapear_alrededores(unsigned int cr3, unsigned int virtualDst);
void copiar_codigo(unsigned int cr3, unsigned int virtualDst ,unsigned int virtualSrc, unsigned int x, unsigned int y);
void mapea_visitadas(unsigned int cr3);
unsigned int posicionToVirtual(posicion p);
unsigned int virtualToFisica(unsigned int virtual);
unsigned int fisicaToVirtual(unsigned int fisica);
unsigned char estaMapeada(unsigned int cr3, unsigned int virtual);


#endif	/* !__MMU_H__ */
