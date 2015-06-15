/* ** por compatibilidad se omiten tildes **
================================================================================
TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
definicion de funciones del scheduler
*/

#include "sched.h"
#include "i386.h"


void inicializar_scheduler() {
	contador_tareas = 0;
	anterior = 0;
	actual = 0;
	proximaA = 0; // proxima tarea jugador 1
	proximaB = 0; // proxima tarea jugador 2
	vivas = 0;
	jugadorJugando = 0;
	gdt_tss_actual = 13; //indice en la gdt de la tarea actual, INICIALIZADA COMO INDICE TAREA INICIAL
}

unsigned short sched_proximo_indice() {	
	//~ unsigned char viejo = jugadorJugando;
	unsigned char proxima_viva = obtener_proxima_viva();
	
	if(proxima_viva == 0xff){
		pasar_a_idle();
		return 0xff;
	}else{
		//~ breakpoint();
		//~ if (jugadorJugando == 0) {
			cambiar_tarea(proxima_viva);
			//actualizar_restantes();
			mostrar_clock(actual);
			return ((13 + gdt_tss_actual) << 3);
		//~ }
	}
	//~ actualizar_restantes();
	//~ mostrar_clock(actual);

return 0;
}


unsigned char obtener_proxima_viva() {
	
	if(debug == 2){return 0xff;} //si estoy mostrando

	//~ unsigned char i;
	unsigned char siguiente;

	if(jugadorJugando == 0){			// está jugando A
		siguiente = ver_vivo_aux(1);	// busco el siguiente vivo de B
		if (siguiente != 0xff && piratasB[siguiente].vivo){	// si hay alguno vivo de B, cambio de jugador
			jugadorJugando = 1;
		}else{
			siguiente = ver_vivo_aux(0);// sino, me quedo en A y busco la siguiente viva ahí
		}
	}else{								// está jugando B - misma lógica que arriba
		siguiente = ver_vivo_aux(0);
		if (siguiente != 0xff && piratasA[siguiente].vivo){
			jugadorJugando = 0;
		}else{
			siguiente = ver_vivo_aux(1);
		}
	}
	//~ breakpoint();
	return siguiente;
}


unsigned char ver_vivo_aux(unsigned char j){
	unsigned char siguiente;
	unsigned int hayAlgoVivo = 0;
	int i;
	if (j == 0){							// miro en los zombies de A
		siguiente = proximaA;
		for (i = 0; i<9; i++){				// itero 9 veces //9 porque si lo único vivo de mi lado soy yo, quiero volver y usar mi turno.
			if (piratasA[siguiente].vivo){	// si encuentro 1 vivo ya está
				//~ breakpoint();
				hayAlgoVivo = 1;
				proximaA = siguiente+1;
				break;
			}else{							// sino sigo mirando (módulo 8)
				siguiente++;
				siguiente = siguiente % 8;
			}
		}
	}else{									// miro en los zombies de B - misma lógica que arriba
		siguiente = proximaB;
		for (i = 0; i<9; i++){
			if (piratasB[siguiente].vivo){
				hayAlgoVivo = 1;
				proximaB = siguiente +1;
				break;
			}else{
				siguiente++;
				siguiente = siguiente % 8;
			}
		}
	}
	
	if(!hayAlgoVivo){return 0xff;}
	return siguiente;
}

unsigned short pasar_a_idle() {
	//~ breakpoint();
	if (actual == 0xff) {
		return 0xff;
	}

	cambiar_tarea(0xff);

	return ((13 + gdt_tss_actual) << 3);
}


void cambiar_tarea (unsigned char tss_indice) {
	unsigned char gdt_nueva_tss;
	if(tss_indice == 0xff){
		gdt_tss_actual = 1; //o 0: si es 0, restarle 1 a la cosa que dice 2 más abajo
		actual = 0xff;
	}else{

		anterior = actual;
		actual = tss_indice;

			if(proximaA >= 8){
				proximaA = 0;
			}
			if(proximaB >=8){
				proximaB = 0;
			}

			//~ mostrar_clock(actual);
		//~ }
		
		gdt_nueva_tss = actual + 2; //tarea 0 : +1 = idle, +2 = tareaA0
		
		if(jugadorJugando == 0){
			gdt_tss_actual = gdt_nueva_tss;
		}else{
			gdt_tss_actual = gdt_nueva_tss + 8;
		}

		//~ gdt_tss_actual = gdt_nueva_tss;
	}
}
