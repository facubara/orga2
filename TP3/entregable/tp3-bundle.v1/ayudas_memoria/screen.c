/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones de pantalla
*/

#include "screen.h"
#include "game.h"
#include "sched.h"

void print(const char * text, unsigned int x, unsigned int y, unsigned short attr) {
    ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
    int i;
    for (i = 0; text[i] != 0; i++) {
        p[y][x].c = (unsigned char) text[i];
        p[y][x].a = (unsigned char) attr;
        x++;
        if (x == VIDEO_COLS) {
            x = 0;
            y++;
        }
    }
}

void print_hex(unsigned int numero, int size, unsigned int x, unsigned int y, unsigned short attr) {
    ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO; // magia
    int i;
    char hexa[8];
    char letras[16] = "0123456789ABCDEF";
    hexa[0] = letras[ ( numero & 0x0000000F ) >> 0  ];
    hexa[1] = letras[ ( numero & 0x000000F0 ) >> 4  ];
    hexa[2] = letras[ ( numero & 0x00000F00 ) >> 8  ];
    hexa[3] = letras[ ( numero & 0x0000F000 ) >> 12 ];
    hexa[4] = letras[ ( numero & 0x000F0000 ) >> 16 ];
    hexa[5] = letras[ ( numero & 0x00F00000 ) >> 20 ];
    hexa[6] = letras[ ( numero & 0x0F000000 ) >> 24 ];
    hexa[7] = letras[ ( numero & 0xF0000000 ) >> 28 ];
    for(i = 0; i < size; i++) {
        p[y][x + size - i - 1].c = hexa[i];
        p[y][x + size - i - 1].a = attr;
    }
}

void init_video(){
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	videoCache = obtener_pagina_libre();
    int i = 0;
    int x = 0;
    int y = 1;
    while(x<VIDEO_COLS){
		p[0][x].c = (unsigned char) ' ';
		p[0][x].a = (unsigned char) C_BG_BLACK;
		x++;
	}
	x = 0;
    while (y<45) {
		p[y][x].c = (unsigned char) ' ';
		if(x==0){
			p[y][x].a = (unsigned char) C_BG_RED;
		}else if(x==VIDEO_COLS-1){
			p[y][x].a = (unsigned char) C_BG_BLUE;
		}else{
			p[y][x].a = (unsigned char) C_BG_GREEN;
		}
        x++;
        if (x == VIDEO_COLS) {
            x = 0;
            y++;
        }
    }
    //tengo el fondo y las líneas laterales.
    //Ahora, los elementos.
    /* cuadros inferiores */
    y = VIDEO_FILS-5;
    x = (VIDEO_COLS/2)-5;
    while(y<VIDEO_FILS){
		p[y][x].c = (unsigned char) ' ';
		if(x<VIDEO_COLS/2){
			p[y][x].a = (unsigned char) C_BG_RED;
		}else{
			p[y][x].a = (unsigned char) C_BG_BLUE;
		}
		if( y == VIDEO_FILS-3 && ( x == (VIDEO_COLS/2)-3 || x == (VIDEO_COLS/2)+2 ) ){ //pongo los 0's iniciales
			p[y][x].c = (unsigned char) '0';
			p[y][x].a = p[y][x].a | (unsigned char) C_FG_WHITE; //mantengo el fondo, frente blanco
		}
		x++;
        if (x == (VIDEO_COLS/2)+5) {
            x = (VIDEO_COLS/2)-5;
            y++;
        }
	}
	/* fin cuadros inferiores */
	
	/* zombies restantes */
	p[VIDEO_FILS-3][(VIDEO_COLS/2)-9].c = (unsigned char) '2';
	p[VIDEO_FILS-3][(VIDEO_COLS/2)-9].a = (unsigned char) C_BG_RED | (unsigned char) C_FG_WHITE;
	p[VIDEO_FILS-3][(VIDEO_COLS/2)-8].c = (unsigned char) '0';
	p[VIDEO_FILS-3][(VIDEO_COLS/2)-8].a = (unsigned char) C_BG_RED | (unsigned char) C_FG_WHITE;
	
	p[VIDEO_FILS-3][(VIDEO_COLS/2)+7].c = (unsigned char) '2';
	p[VIDEO_FILS-3][(VIDEO_COLS/2)+7].a = (unsigned char) C_BG_BLUE | (unsigned char) C_FG_WHITE;
	p[VIDEO_FILS-3][(VIDEO_COLS/2)+8].c = (unsigned char) '0';
	p[VIDEO_FILS-3][(VIDEO_COLS/2)+8].a = (unsigned char) C_BG_BLUE | (unsigned char) C_FG_WHITE;
	/* fin zombies restantes */
	
	/* zombies activos */
	y = VIDEO_FILS-4;
	x = 3;
	i = 0;
	while (i <= 8*2){
		i++;
		if(i%2 == 0){
			p[y][x+i].c = (unsigned char) (char)(((int)'0')+(i/2));
			p[y][x+i].a = (unsigned char) C_FG_WHITE;
		}
	}
	
	y = VIDEO_FILS-4;
	x = 59;
	i = 0;
	while (i <= 8*2){
		i++;
		if(i%2 == 0){
			p[y][x+i].c = (unsigned char) (char)(((int)'0')+(i/2));
			p[y][x+i].a = (unsigned char) C_FG_WHITE;
		}
	}
	/* fin zombies activos */
}

void imprime_nombre_grupo_a_la_derecha(){
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	char* nombre_grupo = "Dale Perejil al Toro / Parrillita de vegetales";
	int len = long_string(nombre_grupo);
	int x = VIDEO_COLS-len;
	int y = 0;
	int i = 0;
	for(i = 0; i<len; i++){
		p[y][x+i].a = (unsigned char) C_FG_LIGHT_CYAN;
		p[y][x+i].c = (unsigned char) nombre_grupo[i];
	}
}

int long_string(const char* s){
	int i = 0;
	while(s[i] != 0){
		i++;
	}
	return i;
}

unsigned char imprime_tecla(unsigned char n, unsigned char prev){
	if(n >= 0x80 && prev+0x80 != n){ //cuando presiono
		return 0;
	}
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	int len;
	int x;
	int y = 0;
	int i = 0;
	if(n>=0x80){
		n = n-0x80; //recuperar el make
		char* mensajeSol = "Usted ha   soltado  la tecla de su bonito teclado: ";
		len = long_string(mensajeSol)+1;
		x = VIDEO_COLS-len;
		for(i = 0; i<len; i++){
			p[y][x+i].a = (unsigned char) C_FG_LIGHT_CYAN;
			p[y][x+i].c = (unsigned char) mensajeSol[i];
		}
	}else{
		char* mensajeA = "Usted ha presionado la tecla de su bonito teclado: ";
		len = long_string(mensajeA)+1;
		x = VIDEO_COLS-len;
		for(i = 0; i<len; i++){
			p[y][x+i].a = (unsigned char) C_FG_LIGHT_CYAN;
			p[y][x+i].c = (unsigned char) mensajeA[i];
		}
	}
	
	
	//~ int len = long_string(mensaje)+1;
	switch ( n ) {
		case 0x11: //W
			p[y][VIDEO_COLS-1].a = (unsigned char) C_FG_LIGHT_CYAN;
			p[y][VIDEO_COLS-1].c = (unsigned char) 'W';
		break;
		case 0x1e: //A
			p[y][VIDEO_COLS-1].a = (unsigned char) C_FG_LIGHT_CYAN;
			p[y][VIDEO_COLS-1].c = (unsigned char) 'A';
		break;
		case 0x1f: //S
			p[y][VIDEO_COLS-1].a = (unsigned char) C_FG_LIGHT_CYAN;
			p[y][VIDEO_COLS-1].c = (unsigned char) 'S';
		break;
		case 0x20: //D
			p[y][VIDEO_COLS-1].a = (unsigned char) C_FG_LIGHT_CYAN;
			p[y][VIDEO_COLS-1].c = (unsigned char) 'D';
		break;
		case 0x17: //I
			p[y][VIDEO_COLS-1].a = (unsigned char) C_FG_LIGHT_CYAN;
			p[y][VIDEO_COLS-1].c = (unsigned char) 'I';
		break;
		case 0x24: //J
			p[y][VIDEO_COLS-1].a = (unsigned char) C_FG_LIGHT_CYAN;
			p[y][VIDEO_COLS-1].c = (unsigned char) 'J';
		break;
		case 0x25: //K
			p[y][VIDEO_COLS-1].a = (unsigned char) C_FG_LIGHT_CYAN;
			p[y][VIDEO_COLS-1].c = (unsigned char) 'K';
		break;
		case 0x26: //L
			p[y][VIDEO_COLS-1].a = (unsigned char) C_FG_LIGHT_CYAN;
			p[y][VIDEO_COLS-1].c = (unsigned char) 'L';
		break;
		//~ case
	}
	
	return 1;
}


void mostrar_clock(unsigned int indice) {
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;

	zombie zombi;

	if (jugadorJugando == 0){
		zombi = zombiesA[indice];
	}else{
		zombi = zombiesB[indice];
	}
	
	int y = VIDEO_FILS-2;
	int x = (2*zombi.index_lanzamiento);
	if (zombi.jugador == 0){
		x =  3 + x;
	}else{
		x = 59 + x;
	}
	
	p[y][x].a = (unsigned char) C_FG_LIGHT_GREY | (unsigned char) C_BG_BLACK;

    if(!zombi.vivo){
		p[y][x].c = 'X';
	}else{
    
		switch (zombi.clock) {
			case 0:
				p[y][x].c = '-';
				break;
			case 1:
				p[y][x].c = '\\';
				break;
			case 2:
				p[y][x].c = '|';
				break;
			case 3:
				p[y][x].c = '/';
				break;
		}
	}

	if (jugadorJugando == 0){
		zombiesA[indice].clock = (zombi.clock + 1) % 4;;
	}else{
		zombiesB[indice].clock = (zombi.clock + 1) % 4;;
	}
}


void screen_mueve_jug(unsigned int gamer, unsigned char pos, unsigned char pospos, unsigned char primera){
	pos++;
	pospos++; //porque el mapa comienza en la fila 1 de la pantalla
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	unsigned char color = 0;
	int x = 0;
	if (gamer == 0){
		x = 0;
		color = (unsigned char) C_BG_RED | (unsigned char) C_FG_WHITE;
	}else{
		x = VIDEO_COLS-1;
		color = (unsigned char) C_BG_BLUE | (unsigned char) C_FG_WHITE;
	}
	
	jugador g = jugadores[gamer];
	
	p[pos][x].c = 0;
	p[pos][x].a = color;
	p[pospos][x].c = g.tipo;
	p[pospos][x].a = color;
	
	if(primera == 1){
		p[pospos][x].c = 'M';
	}

}

void restaurar_pantalla(){
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	ca (*q)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) videoCache;
	int y, x;
    for(y=7; y<43; y++){
		for(x=25; x<55; x++){
			p[y][x].c = q[y][x].c;
			p[y][x].a = q[y][x].a;
		}
	}
}

void copiar_pantalla(){
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	ca (*q)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) videoCache;
	int y, x;
    for(y=7; y<43; y++){
		for(x=25; x<55; x++){
			q[y][x].c = p[y][x].c;
			q[y][x].a = p[y][x].a;
        }
    }
}

void screen_mover_zombie(posicion pos_act, posicion pos_dst, unsigned char muerto, zombie zmb){
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	unsigned char x_act = pos_act.x;
	unsigned char y_act = pos_act.y + 1;
	unsigned char x_dst = pos_dst.x;
	unsigned char y_dst = pos_dst.y + 1;
	unsigned char color, bcolor;
	
	
	if (jugadorJugando == 0){
		color = C_FG_RED;
		bcolor = (unsigned char) C_BG_RED | (unsigned char) C_FG_WHITE;
	}else{
		color = C_FG_BLUE;
		bcolor = (unsigned char) C_BG_BLUE | (unsigned char) C_FG_WHITE;
	}
	
	if (muerto){
		p[y_dst][x_dst].a = (unsigned char) C_BG_GREEN | color;
		p[y_dst][x_dst].c = 'X';
	}else{
		p[y_dst][x_dst].a = bcolor;
		p[y_dst][x_dst].c = zmb.tipo;
	}
	
	if(x_act != x_dst || y_act != y_dst){
		p[y_act][x_act].a = (unsigned char) C_BG_GREEN | (unsigned char) C_FG_LIGHT_GREY;
		p[y_act][x_act].c = 'X';
	}

	
}

void screen_nuevo_zombie(posicion pos, unsigned int gamer){
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	unsigned char x = pos.x;
	unsigned char y = pos.y + 1;
	unsigned char color = 0;

	if (gamer == 0){
		color = (unsigned char) C_BG_RED | (unsigned char) C_FG_WHITE;
	}else{
		color = (unsigned char) C_BG_BLUE | (unsigned char) C_FG_WHITE;
	}

	p[y][x].a = color;
	p[y][x].c = jugadores[gamer].tipo;
	
}

void actualizar_restantes(){
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
    
	unsigned char resto = jugadores[jugadorJugando].remanente;
	unsigned char unidades = resto % 10;
	resto = resto - unidades;
	if (resto > 0){
		resto = 1;
	}
	
	if (jugadorJugando == 0){
		p[VIDEO_FILS-3][(VIDEO_COLS/2)-9].c = 48 + resto;		// el ascii del número
		p[VIDEO_FILS-3][(VIDEO_COLS/2)-8].c = 48 + unidades;
	
	}else{
		p[VIDEO_FILS-3][(VIDEO_COLS/2)+7].c = 48 + resto;
		p[VIDEO_FILS-3][(VIDEO_COLS/2)+8].c = 48 + unidades;
	}
}

void actualizar_puntaje(unsigned char gamer){
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
    
	unsigned char puntos = jugadores[gamer].puntaje;
	
	if (gamer == 0){
		p[VIDEO_FILS-3][(VIDEO_COLS/2)-3].c = 48 + puntos;		// el ascii del número
	}else{
		p[VIDEO_FILS-3][(VIDEO_COLS/2)+2].c = 48 + puntos;
	}
}

void screen_mostrar_ganador(char ganador, unsigned char puntajeA, unsigned char puntajeB){
	
	unsigned char color, prim, fin, x, y, i;
	char* mensaje;
	unsigned char centerY = (VIDEO_FILS/2);
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	
	puntajeA = 48 + puntajeA; //int -> char
	puntajeB = 48 + puntajeB; //int -> char
	
	if(ganador == 0){
		mensaje = "ganador el jugador ROJO (0/0)";//23, 14 1 14, 25, 27
		color = (unsigned char) C_BG_RED | (unsigned char) C_FG_WHITE;
		mensaje[25] = puntajeA;
		mensaje[27] = puntajeB;
		prim = (VIDEO_COLS/2) - 14;
		fin  = (VIDEO_COLS/2) + 14;
	}else if(ganador == 1){
		mensaje = "ganador el jugador AZUL (0/0)"; //29, 14 1 14, 25, 27
		color = (unsigned char) C_BG_BLUE | (unsigned char) C_FG_WHITE;
		mensaje[25] = puntajeA;
		mensaje[27] = puntajeB;
		prim = (VIDEO_COLS/2) - 14;
		fin  = (VIDEO_COLS/2) + 14;
	}else{
		mensaje = "tenemos un EMPATE (0/0)"; //23, 11 1 11, 19, 21
		color = (unsigned char) C_BG_LIGHT_GREY | (unsigned char) C_FG_BLACK;
		mensaje[19] = puntajeA;
		mensaje[21] = puntajeB;
		prim = (VIDEO_COLS/2) - 11;
		fin  = (VIDEO_COLS/2) + 11;
	}
	
	i = 0;
	x = 0;
	y = 0;
	while (y < VIDEO_FILS) {
		if(y != centerY || (x < prim || x > fin)){
			p[y][x].c = ' ';
		}else{
			p[y][x].c = mensaje[i];
			++i;
		}
		p[y][x].a = color;
		x++;
		if (x == VIDEO_COLS) {
			x = 0;
			y++;
		}
	}
}

void screen_muestra_error(unsigned int numero, unsigned int ebp, unsigned int edi, unsigned int esi
							, unsigned int edx, unsigned int ecx, unsigned int ebx, unsigned int eax
							, unsigned int ds, unsigned int es, unsigned int fs, unsigned int gs
							, unsigned int errorCode, unsigned int eip, unsigned int cs, unsigned int eflags
							, unsigned int *esp, unsigned int ss){


	unsigned int cr0 = rcr0();
	unsigned int cr2 = rcr2();
	unsigned int cr3 = rcr3();
	unsigned int cr4 = rcr4();
	copiar_pantalla();
	//~ breakpoint();
	
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	unsigned int x,y;
    
    // Base del cuadrito
    for(y=7; y<43; y++){
		for(x=25; x<55; x++){
			// Si estoy en el borde del cuadrito, va negro
			if(y == 7 || y == 42 || x == 25 || x == 54){
				p[y][x].c = (unsigned char) ' ';
				p[y][x].a = (unsigned char) C_BG_BLACK;
				
			}
			// Si estoy en la linea del 'titulo', va el color del jugador
			else if(y == 8 && x != 25 && x != 54){
				p[y][x].c = (unsigned char) ' ';
				if(jugadorJugando == 0){
					p[y][x].a = (unsigned char) C_BG_RED;
				}else{
					p[y][x].a = (unsigned char) C_BG_BLUE;
				}
			}
			// Sino va gris
			else{
				p[y][x].c = (unsigned char) ' ';
				p[y][x].a = (unsigned char) C_BG_LIGHT_GREY;
			}
		}
	}
    
    // Ahora, el texto
    // Título
    char* titulo;
    if (jugadorJugando == 1){
		if (zombiesB[actual].tipo == 'M'){
			titulo = "Zombi B Mago";
		}else if (zombiesB[actual].tipo == 'G'){
			titulo = "Zombi B Guerrero";
		}else{
			titulo = "Zombi B Clerigo";
		}
	}else{
		if (zombiesA[actual].tipo == 'M'){
			titulo = "Zombi A Mago";
		}else if (zombiesA[actual].tipo == 'G'){
			titulo = "Zombi A Guerrero";
		}else{
			titulo = "Zombi A Clerigo";
		}
	}
	if(jugadorJugando == 0){
		print(titulo,26,8,(unsigned char) C_BG_RED |(unsigned char) C_FG_WHITE);
	}else{
		print(titulo,26,8,(unsigned char) C_BG_BLUE |(unsigned char) C_FG_WHITE);
	}
	
	//error detectado (ex)
	char* error_detectado;
	switch(numero){
		case 0:
			error_detectado = "00#DE"; //divide error
			break;
		case 1:
			error_detectado = "01#DB"; //reserved
			break;
		case 2:
			error_detectado = "02NMI"; //Nonmaskable external interrupt
			break;
		case 3:
			error_detectado = "03#BP"; //breakpoint
			break;
		case 4:
			error_detectado = "04#OF"; //overflow
			break;
		case 5:
			error_detectado = "05#BR"; //ROUND Range exceeded
			break;
		case 6:
			error_detectado = "06#UD"; //Invalid opcode
			break;
		case 7:
			error_detectado = "07#NM"; //no math coprocessor
			break;
		case 8:
			error_detectado = "08#DF"; //double fault
			break;
		case 9:
			error_detectado = "09CSO"; //Coprocessor Segment Overrun
			break;
		case 10:
			error_detectado = "10#TS"; //Invalid TSS
			break;
		case 11:
			error_detectado = "11#NP"; //segment not present
			break;
		case 12:
			error_detectado = "12#SS"; //Stack-segment fault
			break;
		case 13:
			error_detectado = "13#GP"; //General Protection
			break;
		case 14:
			error_detectado = "14#PF"; //page fault
			break;
		case 15:
			error_detectado = "15#  "; //intel reserved
			break;
		case 16:
			error_detectado = "16#MF"; //x87 math fault
			break;
		case 17:
			error_detectado = "17#AC"; //Aligment Check
			break;
		case 18:
			error_detectado = "18#MC"; //machine check
			break;
		case 19:
			error_detectado = "19#XM"; //SIMD floating point exception
			break;
		case 20:
			error_detectado = "20#  ";
			break;
		case 21:
			error_detectado = "21#  ";
			break;
		case 22:
			error_detectado = "22#  ";
			break;
		case 23:
			error_detectado = "23#  ";
			break;
		case 24:
			error_detectado = "24#  ";
			break;
		case 25:
			error_detectado = "25#  ";
			break;
		case 26:
			error_detectado = "26#  ";
			break;
		case 27:
			error_detectado = "27#  ";
			break;
		case 28:
			error_detectado = "28#  ";
			break;
		case 29:
			error_detectado = "29#  ";
			break;
		case 30:
			error_detectado = "30#  ";
			break;
		case 31:
			error_detectado = "31#  ";
			break;
		default:
			error_detectado = "  #  ";
	}
	if(jugadorJugando == 0){
		print(error_detectado,49,8,(unsigned char) C_BG_RED |(unsigned char) C_FG_WHITE);
	}else{
		print(error_detectado,49,8,(unsigned char) C_BG_BLUE |(unsigned char) C_FG_WHITE);
	}
	
	// Registros
	
	print("eax",27,10,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("ebx",27,12,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("ecx",27,14,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("edx",27,16,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("esi",27,18,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("edi",27,20,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("ebp",27,22,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("esp",27,24,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("eip",27,26,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("cs",27,28,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("ds",27,30,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("es",27,32,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("fs",27,34,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("gs",27,36,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("ss",27,38,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("eflags",27,40,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("cr0",41,10,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("cr2",41,12,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("cr3",41,14,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("cr4",41,16,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	print("stack",41,27,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_BLACK);
	
	print_hex(eax,8,31,10,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(ebx,8,31,12,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(ecx,8,31,14,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(edx,8,31,16,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(esi,8,31,18,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(edi,8,31,20,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(ebp,8,31,22,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex((unsigned int)esp,8,31,24,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(eip,8,31,26,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(cs,4,31,28,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(ds,4,31,30,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(es,4,31,32,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(fs,4,31,34,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(gs,4,31,36,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(ss,4,31,38,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(eflags,8,34,40,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);	// OJO ACA
	print_hex(cr0,8,45,10,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(cr2,8,45,12,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(cr3,8,45,14,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(cr4,8,45,16,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(esp[0],8,41,29,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(esp[1],8,41,31,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(esp[2],8,41,33,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
	print_hex(esp[3],8,41,35,(unsigned char) C_BG_LIGHT_GREY |(unsigned char) C_FG_WHITE);
}

void screen_indicar_debug_activo(){
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	char *mensaje = "MODO DEBUG ACTIVO";
	int i;
	for(i=0; i < long_string(mensaje); ++i){
		p[0][i].c = mensaje[i];
		p[0][i].a = (unsigned char) C_BG_BLACK |(unsigned char) C_FG_RED | (unsigned char) C_BLINK;
	}
}
