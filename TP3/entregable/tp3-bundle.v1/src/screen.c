/* ** por compatibilidad se omiten tildes **
================================================================================
TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
definicion de funciones del scheduler
*/

#include "screen.h"
#include "sched.h"


extern jugador_t jugadorA, jugadorB;


static ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;

const char reloj[] = "|/-\\";
#define reloj_size 4


void screen_actualizar_reloj_global()
{
    static uint reloj_global = 0;

    reloj_global = (reloj_global + 1) % reloj_size;

    screen_pintar(reloj[reloj_global], C_BW, 49, 79);
}

void screen_pintar(uchar c, uchar color, uint fila, uint columna)
{   
    if (c != 'q'){
        p[fila][columna].c = c;
    }
    p[fila][columna].a = color;
}

uchar screen_valor_actual(uint fila, uint columna)
{
    return p[fila][columna].c;
}

void print(const char * text, uint x, uint y, unsigned short attr) {
    int i;
    for (i = 0; text[i] != 0; i++)
     {
        screen_pintar(text[i], attr, y, x);

        x++;
        if (x == VIDEO_COLS) {
            x = 0;
            y++;
        }
    }
}

void print_hex(uint numero, int size, uint x, uint y, unsigned short attr) {
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

void print_dec(uint numero, int size, uint x, uint y, unsigned short attr) {
    int i;
    char letras[16] = "0123456789";

    for(i = 0; i < size; i++) {
        int resto  = numero % 10;
        numero = numero / 10;
        p[y][x + size - i - 1].c = letras[resto];
        p[y][x + size - i - 1].a = attr;
    }
}

void inic_video(){
    ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;


    int x = 0;
    int y = 0;
    //PRIMERA FILA EN NEGRO
    while (x<VIDEO_COLS){
          p[0][x].c = (unsigned char) ' ';
          p[0][x].a = (unsigned char) C_BG_BLACK;
          x++;
    }
    x=0;
    y=1;
    //PANTALLA EN GRIS
    while (y<45){
          p[y][x].c = (unsigned char) ' ';
          p[y][x].a = (unsigned char) C_BG_LIGHT_GREY;
          x++;
          if (x == VIDEO_COLS){
            x = 0;
            y++;
      }
    }
    y = VIDEO_FILS -5;
    x = 0;
    while (y<VIDEO_FILS){
        p[y][x].c = (unsigned char) ' ';
        p[y][x].a = (unsigned char) C_BG_BLACK;
        x++;
        if (x == VIDEO_COLS){
            x= 0;
            y++;
        }
        
    }
    y = VIDEO_FILS - 5;
    x = (VIDEO_COLS/2) - 5;
    while (y<VIDEO_FILS){
        p[y][x].c = (unsigned char) ' ';
        if(x<VIDEO_COLS/2){
            p[y][x].a = (unsigned char) C_BG_RED;
        }
        else{
            p[y][x].a = (unsigned char) C_BG_BLUE;
        }
        x++;
        if(x == VIDEO_COLS/2+5){
            x = VIDEO_COLS/2 -5;
            y++;
        }
    }
    //0s para puntaje jugador 1
    p[47][36].c = (unsigned char) '0';
    p[47][36].a = (unsigned char) C_FG_WHITE;
    p[47][37].c = (unsigned char) '0';
    p[47][37].a = (unsigned char) C_FG_WHITE;
    p[47][38].c = (unsigned char) '0';
    p[47][38].a = (unsigned char) C_FG_WHITE;
    //0s para puntaje jugador 2
    p[47][41].c = (unsigned char) '0';
    p[47][41].a = (unsigned char) C_FG_WHITE;
    p[47][42].c = (unsigned char) '0';
    p[47][42].a = (unsigned char) C_FG_WHITE;
    p[47][43].c = (unsigned char) '0';
    p[47][43].a = (unsigned char) C_FG_WHITE;

    screen_inicializar_reloj_pirata();
}

int long_string(const char* s){
	int i = 0;
	while(s[i] != 0){
		i++;
	}
	return i;
}

void imprime_nombre_grupo(){
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;
	char* nombre_grupo = " Circus / Family";
	int len = long_string(nombre_grupo);
	int x = VIDEO_COLS-len;
	int y = 0;
	int i = 0;
	for(i = 0; i<len; i++){
		p[y][x+i].a = (unsigned char) C_FG_LIGHT_CYAN;
		p[y][x+i].c = (unsigned char) nombre_grupo[i];
	}
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
		char* mensajeSol = "Usted ha soltado la tecla: ";
		len = long_string(mensajeSol)+6;
		x = VIDEO_COLS-len;
		for(i = 0; i<len; i++){
			p[y][x+i].a = (unsigned char) C_FG_LIGHT_CYAN;
			p[y][x+i].c = (unsigned char) mensajeSol[i];
		}
	}else{
		char* mensajeA = "Usted ha presionado la tecla: ";
		len = long_string(mensajeA)+6;
		x = VIDEO_COLS-len;
		for(i = 0; i<len; i++){
			p[y][x+i].a = (unsigned char) C_FG_LIGHT_CYAN;
			p[y][x+i].c = (unsigned char) mensajeA[i];
		}
	}
	
	
	//~ int len = long_string(mensaje)+1;
	switch ( n ) {
 
                case 0x2a:  //Lshift
                        p[y][VIDEO_COLS-6].a = (unsigned char) C_FG_LIGHT_CYAN;
                        p[y][VIDEO_COLS-6].c = (unsigned char) 'L';
                        p[y][VIDEO_COLS-5].a = (unsigned char) C_FG_LIGHT_CYAN;
                        p[y][VIDEO_COLS-5].c = (unsigned char) 'S';
                        p[y][VIDEO_COLS-4].a = (unsigned char) C_FG_LIGHT_CYAN;
                        p[y][VIDEO_COLS-4].c = (unsigned char) 'H';
                        p[y][VIDEO_COLS-3].a = (unsigned char) C_FG_LIGHT_CYAN;
                        p[y][VIDEO_COLS-3].c = (unsigned char) 'I';
                        p[y][VIDEO_COLS-2].a = (unsigned char) C_FG_LIGHT_CYAN;
                        p[y][VIDEO_COLS-2].c = (unsigned char) 'F';
                        p[y][VIDEO_COLS-1].a = (unsigned char) C_FG_LIGHT_CYAN;
                        p[y][VIDEO_COLS-1].c = (unsigned char) 'T';
                break;
                case 0x36:  //Rshift
                        p[y][VIDEO_COLS-6].a = (unsigned char) C_FG_LIGHT_CYAN;
                        p[y][VIDEO_COLS-6].c = (unsigned char) 'R';
                        p[y][VIDEO_COLS-5].a = (unsigned char) C_FG_LIGHT_CYAN;
                        p[y][VIDEO_COLS-5].c = (unsigned char) 'S';
                        p[y][VIDEO_COLS-4].a = (unsigned char) C_FG_LIGHT_CYAN;
                        p[y][VIDEO_COLS-4].c = (unsigned char) 'H';
                        p[y][VIDEO_COLS-3].a = (unsigned char) C_FG_LIGHT_CYAN;
                        p[y][VIDEO_COLS-3].c = (unsigned char) 'I';
                        p[y][VIDEO_COLS-2].a = (unsigned char) C_FG_LIGHT_CYAN;
                        p[y][VIDEO_COLS-2].c = (unsigned char) 'F';
                        p[y][VIDEO_COLS-1].a = (unsigned char) C_FG_LIGHT_CYAN;
                        p[y][VIDEO_COLS-1].c = (unsigned char) 'T';
                break;
		//~ case
	}
	
	return 1;
}


void mostrar_clock(unsigned int indice) {
	ca (*p)[VIDEO_COLS] = (ca (*)[VIDEO_COLS]) VIDEO;

	pirata_t pirata;

	if (jugadorJugando == 0){
		pirata = piratasA[indice];
	}else{
		pirata = piratasB[indice];
	}
	
	int y = VIDEO_FILS-2;
	int x = (2*pirata.indice);
	if (pirata.jugador == 0){
		x =  3 + x;
	}else{
		x = 59 + x;
	}
	
	p[y][x].a = (unsigned char) C_FG_LIGHT_GREY | (unsigned char) C_BG_BLACK;

    if(!pirata.vivo){
		p[y][x].c = 'X';
	}else{
    
		switch (pirata.clock) {
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
		piratasA[indice].clock = (pirata.clock + 1) % 4;;
	}else{
		piratasB[indice].clock = (pirata.clock + 1) % 4;;
	}
}

void screen_pintar_pirata(jugador_t *j, pirata_t *pirata){
    posicion p = pirata->posicion;
    unsigned char color = screen_color_jugador(j);
    unsigned char colorFondo= j->color;
    unsigned char caracter = screen_caracter_pirata(pirata->tipo);
   
    screen_pintar_rect('q', colorFondo, p.y - 1, p.x - 1, 3, 3); // pinte un rectangulo con el color del jugador de 3x3
    screen_pintar(caracter, C_FG_WHITE , p.y, p.x); // ahi puse el caracter en el medio
    screen_pintar(' ', color, p.y, p.x); //ahi le puse de background el color del pirata
}

void screen_borrar_pirata(jugador_t *j, pirata_t *pirata){
     //borra la posicion actual 
     posicion p = pirata->posicion;
     unsigned char caracter = screen_caracter_pirata(pirata->tipo);
     screen_pintar(caracter, j->color, p.y, p.x); // ahi pinte el background del mismo color
}

unsigned char screen_color_jugador(jugador_t *j){
    
    return j->colorLetra;
}

unsigned char screen_caracter_pirata(unsigned int tipo){
   
    if(tipo == 0) {
        return 'E';
    }else{
        return 'M';
    }
}
void screen_pintar_rect(unsigned char c, unsigned char color, int fila, int columna, int alto, int ancho){
    int i = 0;
    for(i = 0; i<alto; i++){
        screen_pintar_linea_h(c,color,(fila + i), columna, ancho);
    }
}
void screen_pintar_linea_h(unsigned char c, unsigned char color, int fila, int columna, int ancho){
    int i = 0;
    for(i = 0; i<ancho; i++){
        screen_pintar(c,color,fila, (columna + i));
    }
}
void screen_pintar_linea_v(unsigned char c, unsigned char color, int fila, int columna, int alto){
    int i = 0;
    for(i = 0; i<alto; i++){
        screen_pintar(c,color,(fila + i), columna);
    }
}

void screen_pintar_puntajes(){
    unsigned int puntajeJ1 = jugadores[0].puntaje;
    unsigned int puntajeJ2 = jugadores[1].puntaje;
    print_dec(puntajeJ1,3,47,36,C_FG_WHITE);
    print_dec(puntajeJ2,3,47,41,C_FG_WHITE);
}
 
//void screen_inicializar(); // creo que esto es inic_video
//void screen_actualizar_reloj_pirata (jugador_t *j, pirata_t *pirata); // creo que esto es mostrar_clock
//void screen_pintar_reloj_pirata(jugador_t *j, pirata_t *pirata);//esto tambien lo hace mostrar_clock ? 
//void screen_pintar_reloj_piratas(jugador_t *j); //esto tambien lo hace mostrar_clock ? 
//void screen_pintar_relojes(); // esto lo hacemos solo una vez en inic video? 

//void screen_actualizar_posicion_mapa(uint x, uint y); // esto no se que deberia hacer

void screen_stop_game_show_winner(jugador_t *j){
    unsigned int inicioX = VIDEO_COLS/2 - 15;
    unsigned int inicioY = VIDEO_FILS/2 - 10 ;
    screen_pintar_rect(' ', C_BG_BLUE, inicioY, inicioX, 20 , 30); // rectangulo de 20x30 con el color del jugador 
    print_dec((unsigned int)(j->puntaje),3 , inicioX + 13, inicioY + 10,  C_FG_WHITE); // escribo el puntaje calculando 3 pixeles para el mismo 
}  

void screen_inicializar_reloj_pirata(){
    unsigned int i;
    unsigned int columna1 = 4;
    unsigned int columna2 = 59;
    for(i=1;i<9;i++){
        print_dec(i,1,columna1,46,C_FG_WHITE);
        print_dec(i,1,columna2,46,C_FG_WHITE);
        screen_pintar('-',C_FG_WHITE, 48, columna1 );
        screen_pintar('-',C_FG_WHITE, 48, columna2 );
        columna1 += 2;
        columna2 += 2;
    }
}  

