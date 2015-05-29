/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"
#include "defines.h"
/* Atributos paginas */
/* -------------------------------------------------------------------------- */


/* Direcciones fisicas de codigos */
/* -------------------------------------------------------------------------- */
/* En estas direcciones estan los códigos de todas las tareas. De aqui se
 * copiaran al destino indicado por TASK_<i>_CODE_ADDR.
 */

/* Direcciones fisicas de directorios y tablas de paginas del KERNEL */
/* -------------------------------------------------------------------------- */

void mmu_inicializar_dir_kernel(){
	page_dir_entry* page_table_0 = (page_dir_entry*)(table_0_kernel_addr);	// 0x28000
	page_dir_entry* page_dir = (page_dir_entry*)(dir_kernel_addr);			// 0x27000
	
	// Inicializo dir y tabla a la vez
	int i = 0;
	while(i < 1024){
		/*page_dir[i] = (page_dir_entry) {
			.p = 0,
			.rw = 1,
			.su = 0,
			.ignored = 0,
			.base = i // i*4KB
		};*/
		
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
	/*page_dir[1] = (page_dir_entry) {
		.p = 0,
		.rw = 1,
		.su = 0,
		.ignored = 0,
		.base = (unsigned int) table_1_kernel_addr >> 12
	};
	
	/*for(i=1;i<1024;i++){
		page_dir[i] = (page_dir_entry) {
				.p = 0,
				.rw = 0,
				.su = 0,
				.ignored = 0,
				.base = 0
			};*/
	//}
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
	
	unsigned int cr3 = obtener_pagina_libre();	// Busco una pagina nueva y la pongo en cr3

	page_dir_entry* page_dir = (page_dir_entry*)(cr3);	// Voy con la dir de esa pag nueva a page_dir
	page_dir_entry* page_tables[1];						// Arreglo de 4 page_dir_entry

	
		page_tables[j] = (page_dir_entry*)(obtener_pagina_libre());		// Pido una pag libre para la page table
	
	
	// Inicializo tooooodo
	for (i = 0; i < 1024; i++) {
		page_dir[i] = (page_dir_entry) {                //inicializo todas las entradas del directorio de tarea       
			.p = 0,
			.rw = 1,
			.su = 1,
			.ignored = 0,
			.base = i
		};
                page_tables[0][i] = (page_dir_entry) {           //identity mapping para los primeros 0x000000 - 0x3FFFFF
                        .p = 0,
                        .rw = 1,
                        .su = 1,
                        .ignored = 0,
                        .base = i
                }
		/*for (j = 0; j < 1; j++) {
			page_tables[j][i] = (page_dir_entry) {
				.p = 1,
				.rw = 1,
				.su = 1,
				.ignored = 0,
				.base = i + j * 1024
			};
		}
                */
                
		//~ if (0x003FFFFF < (i + 2048) * 0x1000) {
			//~ page_tables[2][i] = (page_dir_entry) {
				//~ .p = 0,
				//~ .rw = 0,
				//~ .su = 0,
				//~ .ignored = 0,
				//~ .base = 0
			//~ };
		//~ }
	}
	
	// Las primera entrada de esa page dir van con el page table que ya hice
	//for (j = 0; j < 1; j++) {
		page_dir[0] = (page_dir_entry) {                            
			.p = 1,
			.rw = 1,
			.su = 1,
			.ignored = 0,
			.base = (unsigned int) page_tables[j] >> 12
		};
	}
	
			
	for(i=1;i<1024;i++){                                      ;//ignoro el resto de las entradas del directorio de la tarea
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
	
unsigned int copiar_codigo(unsigned int cr3, unsigned short _zombie, unsigned char _jugador, unsigned short y, unsigned char tipo){
	int signo, x;
	
	//ver esto dependiendo del jugador
	if(_jugador==0){
		x = 2;
		signo = 1;
	}else{
		x=77;
		tipo = 3+tipo;
		signo = -1;
		//~ _zombie = 8+_zombie;
	}
	//~ zombies[_zombie].posicion.x = x;//VER ESTO AL MOMENTO DE CREAR LOS ZOMBIES
	//~ zombies[_zombie].posicion.y = y;
	unsigned int posicion_en_mapa;
	if(_jugador == 0){
		zombiesA[_zombie].posicion.x = x;//VER ESTO AL MOMENTO DE CREAR LOS ZOMBIES
		zombiesA[_zombie].posicion.y = y;
		posicion_en_mapa = 0x400000 + zombiesA[_zombie].posicion.x * 0x1000 + zombiesA[_zombie].posicion.y * 0x78000;//VER!!!
	}else{
		zombiesB[_zombie].posicion.x = x;//VER ESTO AL MOMENTO DE CREAR LOS ZOMBIES
		zombiesB[_zombie].posicion.y = y;
		posicion_en_mapa = 0x400000 + zombiesB[_zombie].posicion.x * 0x1000 + zombiesB[_zombie].posicion.y * 0x78000;//VER!!!
	}
	
	//~ unsigned int posicion_en_mapa = 0x400000 + zombies[_zombie].posicion.x * 0x1000 + zombies[_zombie].posicion.y * 0x78000;//VER!!!

	//~ breakpoint();
	unsigned char* codigo_tarea = (unsigned char*) (0x10000 + (tipo * 0x1000));
	unsigned char* mapa_tarea = (unsigned char*) posicion_en_mapa;

	
	//~ int banana = y;
	//~ breakpoint();
	//~ banana = banana+1;
	mueve_tarea_mapa(cr3, codigo_tarea, mapa_tarea, signo, 0x08000000/*centro inicial*/);
	
	
	
	
	if(_jugador==0){
		zombiesA[_zombie].centro = 0x8000000;
	}else{
		zombiesB[_zombie].centro = 0x8000000;
	}
	
	// Armo la TSS de este zombie
	// OJO, VER SI NO TIENE QUE IR EN OTRA FUNCIÓN
	
	
	
	//~ sched_inserta_zombie(teeseese, _zombie, _jugador);
	
	return cr3;
}

void mueve_tarea_mapa(unsigned int cr3, unsigned char* fisica0, unsigned char* fisica1, int signo, unsigned int logica){
	unsigned int temp;
	//~ breakpoint();
	
				mmu_mapear_pagina((unsigned int)0x09000000, rcr3(), (unsigned int)fisica0, 1, 1);
				mmu_mapear_pagina((unsigned int)0x09001000, rcr3(), (unsigned int)fisica1, 1, 1);

				//~ mmu_mapear_pagina(logica, dir_kernel_addr, (unsigned int)fisica1, 1, 1);//centro kernel
				//~ breakpoint();
				// Copio la tarea del zombi en la posición del mapa
				unsigned char* logicaPoint = (unsigned char*) 0x09001000;
				unsigned char* logicaPointOrigen = (unsigned char*) 0x09000000;
				int i;
				for (i = 0; i < 0x1000; i++) {
					//~ breakpoint();
					logicaPoint[i] = logicaPointOrigen[i];
				}
				//~ breakpoint();
				//~ mmu_unmapear_pagina(logica, dir_kernel_addr);
				
				//~ mmu_unmapear_pagina((unsigned int)fisica0, dir_kernel_addr);
				mmu_unmapear_pagina((unsigned int)0x09000000, dir_kernel_addr);
				mmu_unmapear_pagina((unsigned int)0x09001000, dir_kernel_addr);
	//~ breakpoint();
	
	mmu_mapear_pagina(logica, cr3, (unsigned int)fisica1, 1, 1);//centro
	
	mmu_mapear_pagina(logica+0x1000, cr3, (unsigned int)fisica1 + (0x1000*signo), 1, 1); //adelante
	
	mmu_mapear_pagina(logica+0x6000, cr3, (unsigned int)fisica1 - (0x1000*signo), 1, 1); //atrás
	
	temp = (unsigned int)fisica1 - (0x78000*signo);
	if(temp<0x400000){
		temp = TABLERO + temp;
	}else if(temp>0x400000+TABLERO){
		temp = -TABLERO + temp;
	}
	mmu_mapear_pagina(logica+0x5000, cr3, temp, 1, 1); //izquierda
	
	temp = (unsigned int)fisica1 + (0x1000*signo)+(0x78000*signo);
	if(temp<0x400000){
		temp = TABLERO + temp;
	}else if(temp>0x400000+TABLERO){
		temp = -TABLERO + temp;
	}
	mmu_mapear_pagina(logica+0x3000, cr3, temp, 1, 1); //adelante izquierda
	
	temp = (unsigned int)fisica1 - (0x1000*signo)-(0x78000*signo);
	if(temp<0x400000){
		temp = TABLERO + temp;
	}else if(temp>0x400000+TABLERO){
		temp = -TABLERO + temp;
	}
	mmu_mapear_pagina(logica+0x7000, cr3, temp, 1, 1); //atrás izquierda
	
	temp = (unsigned int)fisica1 + (0x1000*signo)+(0x78000*signo);
	if(temp<0x400000){
		temp = TABLERO + temp;
	}else if(temp>0x400000+TABLERO){
		temp = -TABLERO + temp;
	}	
	mmu_mapear_pagina(logica+0x2000, cr3, temp, 1, 1); //adelante derecha
	
	temp = (unsigned int)fisica1 + (0x78000*signo);
	if(temp<0x400000){
		temp = TABLERO + temp;
	}else if(temp>0x400000+TABLERO){
		temp = -TABLERO + temp;
	}
	mmu_mapear_pagina(logica+0x4000, cr3, temp, 1, 1); //derecha
	
	temp = (unsigned int)fisica1 - (0x1000*signo)+(0x78000*signo);
	if(temp<0x400000){
		temp = TABLERO + temp;
	}else if(temp>0x400000+TABLERO){
		temp = -TABLERO + temp;
	}	
	mmu_mapear_pagina(logica+0x8000, cr3, temp, 1, 1); //atrás derecha
	//~ breakpoint();
}


unsigned int obtener_pagina_libre() {
	return 0x100000 + (contador_paginas_ocupadas++) * 0x1000; //area libre +
	//~ contador_paginas_ocupadas++;
}
