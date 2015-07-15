/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"
#include "sched.h"

/* Atributos paginas */
/* -------------------------------------------------------------------------- */


/* Direcciones fisicas de codigos */
/* -------------------------------------------------------------------------- */
/* En estas direcciones estan los códigos de todas las tareas. De aqui se
 * copiaran al destino indicado por TASK_<i>_CODE_ADDR.
 */

/* Direcciones fisicas de directorios y tablas de paginas del KERNEL */
/* -------------------------------------------------------------------------- */

void mmu_iniciar(){
	contador_paginas_ocupadas = 0;
	mmu_inicializar_dir_kernel();
}


void mmu_inicializar_dir_kernel(){
	page_dir_entry* page_table_0 = (page_dir_entry*)(table_0_kernel_addr);	// 0x28000
	page_dir_entry* page_dir = (page_dir_entry*)(dir_kernel_addr);			// 0x27000
	
	// Inicializo dir y tabla a la vez
	int i = 0;
	while(i < 1024){
	
		
		page_table_0[i] = (page_dir_entry) {
			.p = 1,
			.rw = 1,
			.su = 0,
			.ignored = 0,
			.base = i//(1024*0)
		};	
		i++;
	}
	
	// La primera entrada de dir apunta a la tabla.
	page_dir[0] = (page_dir_entry) {
		.p = 1,
		.rw = 1,
		.su = 0,
		.ignored = 0,
		.base = (unsigned int) table_0_kernel_addr >> 12
	};

	for (i=1; i<1024; i++) {                  //EL RESTO NO LAS NECESITO
		 page_dir[i] = (page_dir_entry){
		 	.p = 0,
		 	.rw = 0,
		 	.su = 0,
		 	.ignored = 0,
		 	.base = 0,
		 };
	}
}

void mmu_mapear_pagina(unsigned int virtual, unsigned int cr3, unsigned int fisica, char rw, char su) {
	
	// CUIDADO, REVISAR QUE NO ESTEMOS PISANDO NADA EN EL CASO P = 1
	//~ breakpoint();
	page_dir_entry* page_dir = (page_dir_entry*)(cr3);		// Levanto el valor de cr3
	unsigned int dir_indice = virtual >> 22;				// Levanto el indice en dir
	unsigned int table_indice = (virtual >> 12) & 0x3FF;	// Levanto el indice en table

	// Voy a la entrada correspondiente en page_dir
	page_dir_entry page_dir_entrada = page_dir[dir_indice];

	// Si no estaba presente, cargo todo y busco una pagina libre
	if (page_dir_entrada.p == 0) { 
		page_dir_entrada = page_dir[dir_indice] = (page_dir_entry) {
			.p = 1,
			.rw = rw,
			.su = su,
			.ignored = 0,
			.base = (unsigned int) obtener_pagina_libre() >> 12
		};
	}

	// Voy a la entrada correspondiente en page table
	page_dir_entry* page_table = (page_dir_entry*)((unsigned int)page_dir_entrada.base << 12);

	// Hago el mapeo
	page_table[table_indice] = (page_dir_entry) {
		.p = 1,
		.rw = rw,
		.su = su,
		.ignored = 0,
		.base = (unsigned int) fisica >> 12
	};
	
	tlbflush();
}


void mmu_unmapear_pagina(unsigned int virtual, unsigned int cr3) {
	page_dir_entry* page_dir = (page_dir_entry*)(cr3);		// Levanto el valor de cr3
	unsigned int dir_indice = virtual >> 22;				// Levanto el indice en dir
	unsigned int table_indice = (virtual >> 12) & 0x3FF;	// Levanto el indice en table

	// Voy a la entrada correspondiente en page_dir
	page_dir_entry page_dir_entrada = page_dir[dir_indice];

	// Si estaba presente, busco la entrada en page_table y lo pongo como no presente
	if (page_dir_entrada.p != 0) {
		page_dir_entry* page_table = (page_dir_entry*)((unsigned int)page_dir_entrada.base << 12);

		page_table[table_indice].p = 0;

		tlbflush();
	}
}


unsigned int mmu_inic_dir_pirata(){
	
	unsigned int cr3 = obtener_pagina_libre();	// Busco una pagina nueva y la pongo en cr3 para el directorio

	page_dir_entry* page_dir = (page_dir_entry*)(cr3);	// Voy con la dir de esa pag nueva a page_dir
	//page_dir_entry* page_tables[1];						// Arreglo de 4 page_dir_entry

	
		page_dir_entry* page_table_k = (page_dir_entry*)(obtener_pagina_libre());		// Pido una pag libre para la page table para "kernel"
	
	
	// Inicializo tooooodo
		int i;
	for (i = 0; i < 1024; i++) {
		/*page_dir[i] = (page_dir_entry) {                //inicializo todas las entradas del directorio de tarea       
			.p = 0,
			.rw = 1,
			.su = 1,
			.ignored = 0,
			.base = i
		};*/
                page_table_k[i] = (page_dir_entry) {           //identity mapping para los primeros 0x000000 - 0x3FFFFF (kernel)
                        .p = 1,
                        .rw = 1,
                        .su = 1,
                        .ignored = 0,
                        .base = i
                };
		
	}
	
	   page_dir[0] = (page_dir_entry){
	   	    .p = 1,
	   	    .rw = 1,
	   	    .su = 1,
	   	    .ignored = 0,
	   	    .base = (unsigned int) page_table_k >> 12
	   };
	// Las primera entrada de esa page dir van con el page table que ya hice
	//for (j = 0; j < 1; j++) {
			
	for(i=1; i<1024; i++){                                      ;//ignoro el resto de las entradas del directorio de la tarea
		page_dir[i] = (page_dir_entry) {
				.p = 0,
				.rw = 0,
				.su = 0,
				.ignored = 0,
				.base = 0
			};
	}
	
	///////
	return cr3;
}	
	


unsigned int obtener_pagina_libre() {
	return 0x100000 + (contador_paginas_ocupadas++) * 0x1000; //area libre 
	//~ contador_paginas_ocupadas++;
}

void copiar_fisico(unsigned int cr3, unsigned int dst, unsigned int src, unsigned int x, unsigned int y){
	int i;
	unsigned int cr3Actual = rcr3();
	mmu_mapear_pagina(0x500000,cr3Actual,src,1,0);
	mmu_mapear_pagina(0x501000,cr3Actual,dst,1,0);
	int* psrc = (int*)(0x500000);
    int* pdst = (int*)(0x501000);
    for(i=0;i<1024;i++) pdst[i] = psrc[i];
    pdst[1024-1] = y;
    pdst[1024-2] = x;
    mmu_unmapear_pagina(0x500000,cr3Actual);
    mmu_unmapear_pagina(0x501000,cr3Actual);
}


void copiar_codigo(unsigned int cr3, unsigned int virtualDst, unsigned int virtualSrc, unsigned int x, unsigned int y){

	copiar_fisico(cr3,virtualToFisica(virtualDst),virtualToFisica(virtualSrc),x,y);
	
	mmu_mapear_pagina(0x400000, cr3, virtualToFisica(virtualDst), 1, 1); //codigo
}

void mapear_alrededores(unsigned int cr3, unsigned int virtualDst){
	//la idea es que esta sirve para mapear y para mover porque mapea los alrededores del "virtualDst", ojo que hasta aca le paso direcciones virtuales 

	unsigned int fisicaCodigo = virtualToFisica(virtualDst);
	
       
    mmu_mapear_pagina(virtualDst, cr3, fisicaCodigo, 0, 1); //centro        

	mmu_mapear_pagina(virtualDst + 0x1000, cr3, fisicaCodigo + 0x1000, 0, 1); //adelante
	
	mmu_mapear_pagina(virtualDst-0x1000, cr3, fisicaCodigo - 0x1000, 0, 1); //atrás
	
	mmu_mapear_pagina(virtualDst- (0x1000*80), cr3, fisicaCodigo - (0x1000*80), 0, 1); //izquierda
	
	mmu_mapear_pagina(virtualDst- (0x1000*79), cr3, fisicaCodigo - (0x1000*79), 0, 1); //adelante izquierda
	
	mmu_mapear_pagina(virtualDst- (0x1000*81), cr3, fisicaCodigo - (0x1000*81), 0, 1); //atrás izquierda
	
	mmu_mapear_pagina(virtualDst+ (0x1000*81), cr3, fisicaCodigo + (0x1000*81), 0, 1); //adelante derecha
	
	mmu_mapear_pagina(virtualDst+ (0x1000*80), cr3, fisicaCodigo + (0x1000*80), 0, 1); //derecha
	
	mmu_mapear_pagina(virtualDst+ (0x1000*79), cr3, fisicaCodigo + (0x1000*79), 0, 1); //atrás derecha

        //MAPEE LAS POSICIONES CORRESPONDIENTES A LA TAREA EN EL AREA DE MEM DE LA TAREA EN CUESTION	
}

unsigned int posicionToVirtual(posicion p){
	return 0x800000+p.x*0x1000+(p.y)*80*0x1000;
}

unsigned int virtualToFisica(unsigned int virtual){
	if (virtual >= 0x400000){
		virtual = 0x500000 + (virtual - 0x800000);
	}
	return virtual;
}

unsigned int fisicaToVirtual(unsigned int fisica){
	if (fisica >= 0x400000){
		fisica = 0x800000 + (fisica - 0x500000);
	}
	return fisica;
}

void mapea_visitadas(unsigned int cr3){
	unsigned int *visitadas;
	unsigned int fisica; 
	if (jugadorJugando == 0){
		visitadas = (unsigned int *) visitadasA;
	}else{
		visitadas = (unsigned int *) visitadasB;
	}
	int i;
	for (i=0; i < jugadores[jugadorJugando].ult_indice_vis; i++){
		fisica = virtualToFisica(visitadas[i]);
		mmu_mapear_pagina(visitadas[i],cr3,fisica,0,1);
	}
}

unsigned char estaMapeada(unsigned int cr3,unsigned int virtual){
	// se fija si esta o no esta mapeada en el cr3 la virtual

	page_dir_entry * dir = (page_dir_entry * ) cr3;
	unsigned int dir_index = (virtual >> 22 );
	unsigned int table_index = ((virtual >> 12) & 0x3FF);
	if (dir[dir_index].p == 0){
		return 0;
	}else{
		page_dir_entry* tab = (page_dir_entry*) (((unsigned int)dir[dir_index].base) >> 12);

		if (tab[table_index].p == 0){
			return 0;
		}else{
			return 1;
		} 
	}
}
