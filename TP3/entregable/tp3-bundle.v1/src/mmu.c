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
	
//unsigned int copiar_codigo(unsigned int cr3,/*, unsigned short pirata,*/ unsigned char jugador/* unsigned short y*/, unsigned char tipo, unsigned char nuevo){
	//int signo, x;
        
        //unsigned int posicion_mapa;
        //0x500000 puerto jugador 1 supongo
	    //unsigned char* posicion_mapa; // = (unsigned char*) (0x500000);  //+ 0x1000;
	    //unsigned char* codigo_tarea; 
        //posicion mapa = salida del puerto digamos
       /*if(jugador == 0){                //jugador 1
            posicion_mapa = (unsigned char*) (0x500000 + 81*0x1000);   //puerto jugador 1
            
                 if(tipo == 0){  //explorador
                 codigo_tarea = (unsigned char*) (0x10000);
                 }else{   //minero
                 codigo_tarea = (unsigned char*) (0x11000);
                      }
                   }
            else{
            posicion_mapa = (unsigned char*) (0x121FFFF - 81* 0x1000);  // puerto jugador 2}
            if(tipo == 0){
            codigo_tarea = (unsigned char*) (0x12000);
            }else{
            codigo_tarea = (unsigned char*) (0x13000);
            }
        }
        //unsigned char* codigo_tarea = (unsigned char*) (0x10000);
        //codigo primer tarea, para probar
        //LOGICA (0x0881000 deberia ir variando)
        tarea_al_mapa(cr3, codigo_tarea, posicion_mapa, 0x0881000, tipo, jugador, nuevo);
	return cr3;
}
*/
/*void tarea_al_mapa(unsigned int cr3, unsigned char* fisica0, unsigned char* fisica1, unsigned int logica, unsigned char tipo, unsigned char jugador, unsigned char nuevo){
	//unsigned int temp;
	
	//CODIGO EN LA 0x400000

                unsigned int cr3Actual = rcr3();
				mmu_mapear_pagina(0x0400000, cr3Actual, (unsigned int) fisica1, 1, 0);
                   
				
				unsigned char* cod_tarea_dest = (unsigned char*) 0x0400000;
				unsigned char* cod_tarea_origen = (unsigned char*) 0x10000;
				int i;
				for (i = 0; i < 0x1000; i++) {
					
					cod_tarea_dest[i] = cod_tarea_origen[i];
				}
				
				mmu_unmapear_pagina(0x0400000, cr3Actual);
        
	mmu_mapear_pagina(0x400000, cr3, (unsigned int) fisica0, 1, 1);//codigo
        if(tipo == 0){ //explorador
        mmu_mapear_pagina(logica, cr3, (unsigned int) fisica1, 0, 1); //centro        

	mmu_mapear_pagina(logica+0x1000, cr3, (unsigned int)fisica1 + 0x1000, 0, 1); //adelante
	
	mmu_mapear_pagina(logica-0x1000, cr3, (unsigned int)fisica1 - 0x1000, 0, 1); //atrás
	
	mmu_mapear_pagina(logica- (0x1000*80), cr3, (unsigned int)fisica1 - (0x1000*80), 0, 1); //izquierda
	
	mmu_mapear_pagina(logica- (0x1000*79), cr3, (unsigned int)fisica1 - (0x1000*79), 0, 1); //adelante izquierda
	
	mmu_mapear_pagina(logica- (0x1000*81), cr3, (unsigned int)fisica1 - (0x1000*81), 0, 1); //atrás izquierda
	
	mmu_mapear_pagina(logica+ (0x1000*81), cr3, (unsigned int)fisica1 + (0x1000*81), 0, 1); //adelante derecha
	
	mmu_mapear_pagina(logica+ (0x1000*80), cr3, (unsigned int)fisica1 + (0x1000*80), 0, 1); //derecha
	
	mmu_mapear_pagina(logica+ (0x1000*79), cr3, (unsigned int)fisica1 + (0x1000*79), 0, 1); //atrás derecha
        }
        //MAPEE LAS POSICIONES CORRESPONDIENTES A LA TAREA EN EL AREA DE MEM DE LA TAREA EN CUESTION
        // VER QUE ONDA EL MAPEO DE ESTO MISMO A LAS OTRAS TAREAS
	
//}
*/

unsigned int obtener_pagina_libre() {
	return 0x100000 + (contador_paginas_ocupadas++) * 0x1000; //area libre 
	//~ contador_paginas_ocupadas++;
}


void copiar_codigo(unsigned int cr3, unsigned int virtualDst, unsigned int virtualSrc, unsigned int x, unsigned int y){
	// funcion de copiado de codigos, presupone que soy kernel y no tengo mapeada la destination.
	
	unsigned int cr3Actual = rcr3();
	unsigned int fisica = 0x500000 + (virtualDst - 0x800000); 		 // calculo de la direccion fisica
	mmu_mapear_pagina(virtualDst, cr3Actual, (unsigned int) fisica, 1, 0);  //mapea la direccion virtual a la fisica
	int i;
        unsigned char* ptDst = (unsigned char*) virtualDst;
        unsigned char* ptSrc = (unsigned char*) virtualSrc;
	for (i = 0; i < 0x1000 - 12; i++) {
					
		ptDst[i] = ptSrc[i];
	}
	
	// hasta ahi copia ahora pasaje de parametros
	unsigned int * pos = (unsigned int*) ptDst + i;
	pos[0] = x;
	pos[1] = y;
				
	mmu_unmapear_pagina(virtualDst, cr3Actual);				//desmapeo virtualDest del cr3  actual
	
	//CODIGO EN LA 0x400000
        
	mmu_mapear_pagina(0x400000, cr3, virtualSrc, 1, 1);//codigo
}

void mapear_alrededores(unsigned int cr3, unsigned int virtualDst){
	//la idea es que esta sirve para mapear y para mover porque mapea los alrededores del "virtualDst", ojo que hasta aca le paso direcciones virtuales 



	unsigned int fisicaCodigo = 0x500000 + (virtualDst - 0x800000);
	
	
       
    mmu_mapear_pagina(virtualDst, cr3, fisicaCodigo, 0, 1); //centro        

	mmu_mapear_pagina(virtualDst+0x1000, cr3, fisicaCodigo + 0x1000, 0, 1); //adelante
	
	mmu_mapear_pagina(virtualDst-0x1000, cr3, fisicaCodigo - 0x1000, 0, 1); //atrás
	
	mmu_mapear_pagina(virtualDst- (0x1000*80), cr3, fisicaCodigo - (0x1000*80), 0, 1); //izquierda
	
	mmu_mapear_pagina(virtualDst- (0x1000*79), cr3, fisicaCodigo - (0x1000*79), 0, 1); //adelante izquierda
	
	mmu_mapear_pagina(virtualDst- (0x1000*81), cr3, fisicaCodigo - (0x1000*81), 0, 1); //atrás izquierda
	
	mmu_mapear_pagina(virtualDst+ (0x1000*81), cr3, fisicaCodigo + (0x1000*81), 0, 1); //adelante derecha
	
	mmu_mapear_pagina(virtualDst+ (0x1000*80), cr3, fisicaCodigo + (0x1000*80), 0, 1); //derecha
	
	mmu_mapear_pagina(virtualDst+ (0x1000*79), cr3, fisicaCodigo + (0x1000*79), 0, 1); //atrás derecha

        //MAPEE LAS POSICIONES CORRESPONDIENTES A LA TAREA EN EL AREA DE MEM DE LA TAREA EN CUESTION
        // VER QUE ONDA EL MAPEO DE ESTO MISMO A LAS OTRAS TAREAS	
}

unsigned int posicionToVirtual(posicion p){
	return 0x800000+p.x*0x1000+p.y*80*0x1000;
}

void tarea_al_mapa(unsigned int cr3, unsigned int virtualDst, unsigned int virtualSrc){
	//copiar_codigo(cr3,virtualDst,virtualSrc);
	mapear_alrededores(cr3,virtualDst);
	unsigned int *visitadas;
	if (jugadorJugando == 0){
		visitadas = (unsigned int *) visitadasA;
	}else{
		visitadas = (unsigned int *) visitadasB;
	}
	int i;
	for (i=0; i < jugadores[jugadorJugando].ult_indice_vis; i++){
		unsigned int fisica = 0x500000 + (visitadas[i]-0x800000);
		mmu_mapear_pagina(visitadas[i],cr3,fisica,0,1);
	}

}

// TODO fijarse que es mas comodo pasar las posiciones o pasar las direcciones virtuales por otra parte quizas estaria
// bueno que cada pirata sepa donde esta su codigo porque se usa todo el tiempo.
// el uso de la funcion mapear alrededores al mover es muy simple, le paso la direccion del codigo, el cr3 de la tarea y la direcc a donde quiero moverla, esta puede ser la posicion como tipo
// posicion luego de llamada posicionToVirtual(posicion p)
