/* ** por compatibilidad se omiten tildes **
================================================================================
TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
*/

//#include "game.h"
#include <stdarg.h>
#include "screen.h"
#include "mmu.h"
#include "sched.h"
#define POS_INIT_A_X                      1
#define POS_INIT_A_Y                      1
#define POS_INIT_B_X         MAPA_ANCHO - 2
#define POS_INIT_B_Y          MAPA_ALTO - 2

#define CANT_POSICIONES_VISTAS            9
#define MAX_SIN_CAMBIOS                 999

#define BOTINES_CANTIDAD 8

uint botines[BOTINES_CANTIDAD][3] = { // TRIPLAS DE LA FORMA (X, Y, MONEDAS)
                                        {30,  3, 50}, {30, 38, 50}, {15, 21, 100}, {45, 21, 100} ,
                                        {49,  3, 50}, {49, 38, 50}, {64, 21, 100}, {34, 21, 100}
                                    };

//jugador_t jugadorA;
//jugador_t jugadorB;


void inic_game(){
	tiempo_sin_juego = 0;
	
	//buffer_debug = obtener_pagina_libre();
        posicion pos1 = (posicion){
		.x = 1,
		.y = 1
	};
        posicion pos2 = (posicion){
		.x = 78,
		.y = 43
	};
	// Inicializo los valores de los jugadores
	// Se decide arrancar con un zombie tipo mago ('M')
	jugador_t j1 = (jugador_t){
                .puerto = pos1,
		        .puntaje = (unsigned char) 0,
                .m_pendientes = 0,
                .ult_indice_vis = 0,
                .color = C_FG_MAGENTA
	};
	
	jugador_t j2 = (jugador_t){
                .puerto = pos2,
		        .puntaje = (unsigned char) 0,
                .m_pendientes = 0,
                .ult_indice_vis = 0,
                .color = C_FG_CYAN
	};

	jugadores[0] = j1;
	jugadores[1] = j2;
	
	debug = 0;
	
	posicion p = (posicion){
		.x = 0,
		.y = 0
	};
	
	int i;
	for(i = 0; i<8; i++){
		piratasA[i].posicion = p;
		piratasB[i].posicion = p;
		
		piratasA[i].index = i;
		piratasB[i].index = i;
		
		piratasA[i].centro = 0;
		piratasB[i].centro = 0;
		
		piratasA[i].vivo = 0;
		piratasB[i].vivo = 0;
		
		piratasA[i].clock = 0;
		piratasB[i].clock = 0;
		
		piratasA[i].jugador = 0;
		piratasB[i].jugador = 1;
		
		piratasA[i].indice = 0;
		piratasB[i].indice = 0;

                piratasA[i].tipo = 0;
                piratasB[i].tipo = 0;
		
	}
	/*for(i=0; i<8;i++){
		jugadores[0].vivos[i] = 0;
		jugadores[1].vivos[i] = 0;
	}*/
	
	// Esto muestra en pantalla a cada jugador
	//screen_mueve_jug(0, 0, 0, 1);
	//screen_mueve_jug(1, 0, 0, 1);
	
}

void* error()
{
	__asm__ ("int3");
	return 0;
}

uint game_xy2lineal (uint x, uint y) {
	return (y * MAPA_ANCHO + x);
}

uint game_posicion_valida(int x, int y) {
	return (x >= 0 && y >= 0 && x < MAPA_ANCHO && y < MAPA_ALTO);
}

pirata_t* id_pirata2pirata(uint id_pirata)
{
    // ~ completar ~
	return NULL;
}

uint game_dir2xy(direccion dir, int *x, int *y)
{
	switch (dir)
	{
		case IZQ: *x = -1; *y =  0; break;
		case DER: *x =  1; *y =  0; break;
		case ABA: *x =  0; *y =  1; break;
		case ARR: *x =  0; *y = -1; break;
    	default: return -1;
	}

	return 0;
}

uint game_valor_tesoro(uint x, uint y)
{
	int i;
	for (i = 0; i < BOTINES_CANTIDAD; i++)
	{
		if (botines[i][0] == x && botines[i][1] == y)
			return botines[i][2];
	}
	return 0;
}

// dada una posicion (x,y) guarda las posiciones de alrededor en dos arreglos, uno para las x y otro para las y
void game_calcular_posiciones_vistas(int *vistas_x, int *vistas_y, int x, int y)
{
	int next = 0;
	int i, j;
	for (i = -1; i <= 1; i++)
	{
		for (j = -1; j <= 1; j++)
		{
			vistas_x[next] = x + j;
			vistas_y[next] = y + i;
			next++;
		}
	}
}


void game_inicializar()
{
}

void game_jugador_inicializar_mapa(jugador_t *jug)
{
}

/*void game_jugador_inicializar(jugador_t *j)
{
	static int index = 0;

	j->index = index++;
    // ~ completar ~

}*/

void game_pirata_inicializar(pirata_t *pirata, jugador_t *j, uint index, uint id)
{
}

void game_tick(uint id_pirata)
{
}


void game_pirata_relanzar(pirata_t *pirata, jugador_t *j, uint tipo)
{
}

pirata_t* game_jugador_erigir_pirata(jugador_t *j, uint tipo)
{
    // ~ completar ~

	return NULL;
}


void game_jugador_lanzar_pirata(jugador_t *j, uint tipo, int x, int y)
{
}

void game_pirata_habilitar_posicion(jugador_t *j, pirata_t *pirata, int x, int y)
{
}


void game_explorar_posicion(jugador_t *jugador, int c, int f)
{
}


uint game_syscall_pirata_mover(uint id, direccion dir)
{
    /*int signo;
       pirata_t pir;
    if (jugadorJugando == 0){
       pir = piratasA[actual];
       signo = 1; 
       }else{
       pir = piratasB[actual];
       signo = -1;
       }
       posicion pos = pir.posicion;

       unsigned int pos_fisica = 0x500000 + pos.x * 0x1000 + pos.y * 0x80000;
       posicion pos_dst;
       switch(dir){
		case IZQ:
                        if(pos.x == 1){
                        pos_dst = pos;
                        }else{
			pos_dst.x = pos.x-1;
			pos_dst.y = pos.y;
			}
			break;
		case DER:
                        if(pos.x == 78){
                        pos_dst = pos;
                        }else{
			pos_dst.x = pos.x+1;
			pos_dst.y = pos.y;
			}
			break;
		case ARR:
                        if(pos.y == 1){
                        pos_dst = pos;
                        }else{
                        pos_dst.x = pos.x;
                        pos_dst.y = pos.y-1;
			}
			break;
		case ABA:
                        if(pos.y == 43){
                        pos_dst = pos;
                        }else{
                        pos_dst.x = pos.x;
                        pos_dst.y = pos.y+1;
			}
			break;
	}
    //if(pir.tipo == 1) //si es minero tiene que estar mapeada la pos, sino no hay drama
    //int i;   
    //for(i = 0, i<jugadores[jugadorJugando].ult_indice_vis, i++)
       //{
       
    return 0;*/
    return 0;
}

/*uint*/ void game_syscall_cavar(uint id)
{   
	posicion pos;
    if(jugadorJugando == 0){
    //actual es el indice en la gdt de la tss actual, hacer la cuenta necesaria para obtener 
    //que numero de tarea de jugador es
    pos = piratasA[actual].posicion; //actual o id aca
}else{
	pos = piratasB[actual].posicion;
}
    unsigned int x_a = pos.x;                    // pos.x devuelve unsigned char no se si esta bien hacer eso
    unsigned int y_a = pos.y;
    int i;
    unsigned char haybotin = 0;
	for (i = 0; i < BOTINES_CANTIDAD; i++)
	{
		if (botines[i][0] == x_a && botines[i][1] == y_a)
			haybotin = 1;
	}
    if(!haybotin){ //si no hay botin en esa pos
    return; //NO SE QUE DEVUELVE ESTA FUNCION
    }
    unsigned int valor = game_valor_tesoro(x_a, y_a);
    if(valor == 0){
    //ACA MATO A LA TAREA MINERO
	}else{
    jugadores[jugadorJugando].puntaje++; //aumento puntaje
       for (i = 0; i < BOTINES_CANTIDAD; i++)
	{
		if (botines[i][0] == x_a && botines[i][1] == y_a){
			botines[i][2] = botines[i][2]-1;   //resto moneda al botin
		}
	}
	//return; //0; //NO SE QUE DEVUELVEEE
}
}
uint game_syscall_pirata_posicion(uint id, int idx)
{
    if(jugadorJugando == 0){
          if(idx != -1){
             posicion pos = piratasA[idx].posicion;
             uint res = 0;
             res = res || pos.y;
             res =res << 8;
             res = res || pos.x;
             return res;
          }else{
             posicion pos = piratasA[actual].posicion;
             uint res = 0;
             res = res || pos.y;
             res = res << 8;
             res = res || pos.x;
             return res;
          }
    }else{
          if(idx != -1){
             posicion pos = piratasB[idx].posicion;
             uint res = 0;
             res = res || pos.y;
             res = res << 8;
             res = res || pos.x;
             return res;
             }else{
             posicion pos = piratasB[actual].posicion;
             uint res = 0;
             res = res || pos.y;
             res = res << 8;
             res = res || pos.x;
             return res;
             }
         }
}

uint game_syscall_manejar(uint syscall, uint param1)
{
/*
    if (syscall == 0x1) //mover
        {
         game_syscall_pirata_mover(param1);
         return 0;
        }
    if (syscall == 0x2) //cavar
        {
         game_syscall_cavar();
         return 0;
        }
    if (syscall == 0x3) //posición
        {
         game_syscall_posicion(param1);
         return pos;
        }
    // ~ completar ~
  */  
        return 0;
}

void game_pirata_exploto(uint id)
{
}

pirata_t* game_pirata_en_posicion(uint x, uint y)
{
	return NULL;
}

void game_matar_pirata(){
	if(jugadorJugando == 0){
		piratasA[actual].vivo = 0;
	}else{
		piratasB[actual].vivo = 0;
	}
}

void game_matar_pirata_interrupt(){
	game_matar_pirata();
	
	mostrar_clock(actual);
	
	//pirata_t pir;
	//if(jugadorJugando == 0){
//		pir = piratasA[actual];
//	}else{
//		pir = piratasB[actual];
//	}
	//posicion pos = pir.posicion;
	
	//screen_mover_zombie(pos,pos,1, _zombie/*no necesario, pero no da sobrecargar por la diferencia*/);
}
void game_jugador_anotar_punto(jugador_t *j)
{
}

void game_ver_si_termina(){
/*	char ganador;
   	if (tiempo_sin_juego == MAX_SIN_CAMBIOS || debug == 2){
    	return;
    }
    if(jugadores[1].puntaje < jugadores[0].puntaje){
     	ganador = 0;
   	}else{
        if(jugadores[0].puntaje < jugadores[1].puntaje){
        	ganador = 1;
        }else{
        	ganador = -1;
        }
 	} 
	//screen_muestro_ganador(ganador, jugadores[0].puntaje, jugadores[1].puntaje);
*/
}
void game_terminar_si_es_hora()
{
}

void game_atender_teclado(unsigned char tecla)
{
}


#define KB_w_Aup    0x11 // 0x91
#define KB_s_Ado    0x1f // 0x9f
#define KB_a_Al     0x1e // 0x9e
#define KB_d_Ar     0x20 // 0xa0
#define KB_e_Achg   0x12 // 0x92
#define KB_q_Adir   0x10 // 0x90
#define KB_i_Bup    0x17 // 0x97
#define KB_k_Bdo    0x25 // 0xa5
#define KB_j_Bl     0x24 // 0xa4
#define KB_l_Br     0x26 // 0xa6
#define KB_shiftA   0x2a // 0xaa
#define KB_shiftB   0x36 // 0xb6


