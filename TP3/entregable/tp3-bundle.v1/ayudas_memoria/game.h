/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
*/

#ifndef __GAME_H__
#define __GAME_H__

#include "defines.h"
//~ #include "screen.h"
#include "mmu.h"
#include "tss.h"

typedef struct str_posicion {
    unsigned char x;
    unsigned char y;
} __attribute__((__packed__)) posicion;

typedef struct str_zombie {
    posicion posicion;
    unsigned char id;
    tss*          tss;
    unsigned int  centro;
    int           vivo;
    unsigned char clock;
    unsigned char jugador;
    unsigned char index_lanzamiento;  // esto es el 1 2 3 4 5 6 7 8 para saber donde enchufar el clockcito
    unsigned char tipo;
} __attribute__((__packed__)) zombie;

typedef struct str_jugador {
    unsigned char posicion;
    unsigned char puntaje;
    unsigned char remanente;
    unsigned char vivos[8];
    unsigned char tipo;
} __attribute__((__packed__)) jugador;

zombie zombiesA[8];	// zombies del primer jugador
zombie zombiesB[8];	// zombies del segundo jugador

jugador jugadores[2];

unsigned char debug;	//0 -> desactivado, 1-> en espera, 2-> mostrando

typedef enum direccion_e { IZQ = 0xAAA, DER = 0x441, ADE = 0x83D, ATR = 0x732 } direccion;
//							

char tipos_zombies_E[3];

void game_jugador_mover(unsigned int jugador, unsigned int value);

void game_lanzar_zombi(unsigned int jugador);

void game_move_current_zombi(direccion dir);

void init_game();

unsigned char game_key_press(unsigned char n, unsigned char prev);

void game_jugador_cambia_tipo(unsigned char j, char d);

void game_matar_zombie();

void game_matar_zombie_interrupt();

void cambiar_tarea_ya(unsigned short idle);

void imprimir_debug(unsigned int eax,unsigned int ebx,unsigned int ecx,unsigned int edx,unsigned int esi,unsigned int edi,unsigned int ebp,unsigned int esp,unsigned int eip,unsigned short int sc,unsigned short  int ds,unsigned short  int es,unsigned short int fs,unsigned short int gs,unsigned short int ss, unsigned int eflags);

unsigned int buffer_debug;

void game_over();

void game_matar_todo();

void game_ver_si_termina();

unsigned int sin_zombies();

unsigned int tiempo_sin_juego;

void _cli();
void _sti();
void _end_();

#endif  /* !__GAME_H__ */
