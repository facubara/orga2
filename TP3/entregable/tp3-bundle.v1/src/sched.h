/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del scheduler
*/

#ifndef __SCHED_H__
#define __SCHED_H__

#include "game.h"

unsigned short sched_proximo_indice();

void cambiar_tarea (unsigned char tss_indice);

unsigned short pasar_a_idle();

unsigned char obtener_proxima_viva();

unsigned char ver_vivo_aux(unsigned char i);

void inicializar_scheduler();

//void sched_inserta_pirata(unsigned int cr3, unsigned char id, unsigned char _jugador, unsigned char tipo);

unsigned short contador_tareas;

unsigned char anterior;
unsigned char actual;
unsigned char proxima;
unsigned char proximaA;	
unsigned char proximaB; 
unsigned char vivas;
unsigned char jugadorJugando; 

unsigned char gdt_tss_actual;

#endif	/* !__SCHED_H__ */
