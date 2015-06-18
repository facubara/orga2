/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del scheduler
*/

#ifndef __SCREEN_H__
#define __SCREEN_H__

/* Definicion de la pantalla */
#define VIDEO_FILS 50
#define VIDEO_COLS 80

#include "colors.h"
#include "defines.h"
#include "game.h"

/* Estructura de para acceder a memoria de video */
typedef struct ca_s {
    unsigned char c;
    unsigned char a;
} ca;

void print(const char * text, unsigned int x, unsigned int y, unsigned short attr);

void print_hex(unsigned int numero, int size, unsigned int x, unsigned int y, unsigned short attr);

void imprime_nombre_grupo_a_la_derecha();

int long_string(const char *s);

unsigned char screen_print_key (unsigned char n, unsigned char prev);

void mostrar_clock(unsigned int indice);

void screen_mueve_jug(unsigned int jugador, unsigned char pos, unsigned char pospos, unsigned char primera);

void actualizar_restantes();

void actualizar_puntaje(unsigned char gamer);

void screen_mover_zombie(posicion pos_act, posicion pos_dst, unsigned char muerto, zombie _zmb);

void screen_nuevo_zombie(posicion pos, unsigned int gamer);

void copiar_pantalla();

void restaurar_pantalla();

void screen_mostrar_ganador(char ganador, unsigned char puntajeA, unsigned char puntajeB);

void screen_muestra_error(unsigned int numero, unsigned int ebp, unsigned int edi, unsigned int esi
							, unsigned int edx, unsigned int ecx, unsigned int ebx, unsigned int eax
							, unsigned int ds, unsigned int es, unsigned int fs, unsigned int gs
							, unsigned int errorCode, unsigned int eip, unsigned int cs, unsigned int eflags
							, unsigned int *esp, unsigned int ss);

void screen_indicar_debug_activo();

unsigned int videoCache;

#endif  /* !__SCREEN_H__ */
