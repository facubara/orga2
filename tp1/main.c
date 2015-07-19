#include "altaLista.h"
#include <stdio.h>
#include <assert.h>
void prueba_stringLongitud(){
	char * s0 = "";
	char * s1 = "H";
	char * s2 = "HO";
	char * s3 = "cac";
	char * s4 = "meca";
	assert(string_longitud(s0)==0);
	assert(string_longitud(s1)==1);
	assert(string_longitud(s2)==2);
	assert(string_longitud(s3)==3);
	assert(string_longitud(s4)==4);
	printf("%s\n","string_longitud correcto");
}

void prueba_stringCopia(){
	char * s0 = "";
	char * s1 = "H";
	char * s2 = "HO";
	char * s3 = "cac";
	char * s4 = "meca";
	char * c0 = string_copiar(s0);
	char * c1 = string_copiar(s1);
	char * c2 = string_copiar(s2);
	char * c3 = string_copiar(s3);
	char * c4 = string_copiar(s4);
	// me fijo si se copiaron
	assert(string_iguales(string_copiar(c0),""));
	assert(string_iguales(string_copiar(c1),"H"));
	assert(string_iguales(string_copiar(c2),"HO"));
	assert(string_iguales(string_copiar(c3),"cac"));
	assert(string_iguales(string_copiar(c4),"meca"));
	s0 = "jaka"; 
	s1 = "jaka";
	s2 = "jaka";
	s3 = "jaka";
	s4 = "jaka";
	// me fijo si no cambian
	assert(string_iguales(string_copiar(c0),""));
	assert(string_iguales(string_copiar(c1),"H"));
	assert(string_iguales(string_copiar(c2),"HO"));
	assert(string_iguales(string_copiar(c3),"cac"));
	assert(string_iguales(string_copiar(c4),"meca"));
	printf("%s\n", "string_copiar correcto" );

	//borremos lo pedido
}

void prueba_stringMenor(){
	char * s0 = "hola";
	char * s1 = "hola";
	char * s2 = "merced";
	char * s3 = "mercurio";
	char * s4 = "perro";
	char * s5 = "zorro";
	char * s6 = "senior";
	char * s7 = "seniora";
	char * s8 = "caZa";
	char * s9 = "casa";
	// reviso con los ejemplos del enunciado
	assert(!string_menor(s0,s1));
	assert(string_menor(s2,s3));
	assert(string_menor(s4,s5));
	assert(string_menor(s6,s7));
	assert(string_menor(s8,s9));
	printf("%s\n", "string_menor correcto");
}

void prueba_estudianteCreacion(){
	unsigned int edad0 = 20;
	unsigned int edad1 = 40;
	char * nombre0 = "juan";
	char * nombre1 = "marta";
	char * grupo0 = "swinger";
	char * grupo1 = "monjes";
	estudiante * e0 = estudianteCrear(nombre0, grupo0, edad0);
	estudiante * e1 = estudianteCrear(nombre1, grupo1, edad1);
	// me fijo que todos los parametros esten correctamente copiados
	assert(string_iguales(e0->nombre, nombre0));
	assert(string_iguales(e0->grupo, grupo0));
	assert(e0->edad == edad0);
	assert(string_iguales(e1->nombre, nombre1));
	assert(string_iguales(e1->grupo, grupo1));
	assert(e1->edad == edad1);
	estudianteBorrar(e0);
	estudianteBorrar(e1);
	printf("%s\n","prueba_estudianteCreacion exitosa");
}

void prueba_estudianteComparacion(){
	unsigned int edad0 = 20;
	unsigned int edad1 = 40;
	char * nombre0 = "hola";
	char * nombre1 = "hola";
	char * nombre2 = "seniora";
	char * nombre3 = "senior";
	char * nombre4 = "caZa";
	char * nombre5 = "casa";
	char * grupo0 = "swinger";
	char * grupo1 = "monjes";
	estudiante * e0 = estudianteCrear(nombre0, grupo0, edad0);
	estudiante * e1 = estudianteCrear(nombre1, grupo1, edad1);
	estudiante * e2 = estudianteCrear(nombre2, grupo1, edad1);
	estudiante * e3 = estudianteCrear(nombre3, grupo1, edad1);
	estudiante * e4 = estudianteCrear(nombre4, grupo1, edad1);
	estudiante * e5 = estudianteCrear(nombre5, grupo1, edad1);
	// me fijo en  si desempata en la igualdad
	// que pasa con uno que es mayor 
	// que pasa con uno que es menor
	assert(menorEstudiante(e0,e1));
	assert(!menorEstudiante(e2,e3));
	assert(menorEstudiante(e4,e5));
	printf("%s\n","menorEstudiante correcto" );

	//borro lo pedido
	estudianteBorrar(e0);
	estudianteBorrar(e1);
	estudianteBorrar(e2);
	estudianteBorrar(e3);
	estudianteBorrar(e4);
	estudianteBorrar(e5);
	// lo probe y lo imprime, pero me da segmentation fault al final
}

void f(char * s){
	s[0] = s[0];
}

void g( char *s ){ 
	if( s[0] != 0 ) s[0] = 'X';
}

void prueba_estudianteFormato(){
	unsigned int edad0 = 20;
	char * nombre0 = "hola";
	char * grupo0 = "monjes";
	estudiante * e0 = estudianteCrear(nombre0, grupo0, edad0);
	// me fijo si no se modifico
	estudianteConFormato(e0,f);
	assert(string_iguales(e0->nombre, nombre0));
	assert(string_iguales(e0->grupo, grupo0));
	assert(e0->edad == edad0);
	estudianteConFormato(e0,g);
	char * n0 = "Xola";
	char * g0 = "Xonjes";
	// me fijo si se produjeron las modificaciones
	assert(string_iguales(e0->nombre, n0));
	assert(string_iguales(e0->grupo, g0));
	assert(e0->edad == edad0);
	printf("%s\n","estudianteConFormato correcto" );

	// borro lo pedido
	estudianteBorrar(e0);
}

void prueba_crearNodo(){
	unsigned int edad0 = 20;
	char * nombre0 = "hola";
	char * grupo0 = "monjes";
	estudiante * e0 = estudianteCrear(nombre0, grupo0, edad0);
	nodo *n0 = nodoCrear(e0);
	assert(n0->siguiente == NULL);
	assert(n0->anterior == NULL);
	assert(n0->dato == e0);
	nodoBorrar(n0, (tipoFuncionBorrarDato) estudianteBorrar);
	printf("%s\n", "crearNodo correcto" );
}

void prueba_altaListaCrear(){
	remove("a0.txt");
	altaLista *a0 = altaListaCrear();
	assert(a0->primero == NULL);
	assert(a0->ultimo == NULL);
	altaListaImprimir( a0, "a0.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	altaListaBorrar( a0, (tipoFuncionBorrarDato)estudianteBorrar );
	printf("%s\n", "altaLIstaCrear correcto");
}

void prueba_altaListaConUno(){
	remove("a1.txt");
	altaLista *a0 = altaListaCrear();
	char * n0 = "leila";
	char * g0 = "entrania";
	unsigned char edad = 21;
	estudiante *e0 = estudianteCrear(n0, g0, edad);
	insertarAtras( a0, e0);
	assert(a0->primero->siguiente == NULL);
	assert(a0->primero->anterior == NULL);
	assert(a0->primero->dato == e0);
	assert(a0->ultimo->siguiente == NULL);
	assert(a0->ultimo->anterior == NULL);
	altaListaImprimir( a0, "a1.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	altaListaBorrar( a0, (tipoFuncionBorrarDato)estudianteBorrar );
	printf("%s\n", "altaListaConUno correcto");
}


void prueba_altaListaConDos(){
	remove("a2.txt");
	altaLista *a0 = altaListaCrear();
	char * n0 = "leila";
	char * g0 = "entrania";
	unsigned char edad = 21;
	char *n1 = "ian";
	estudiante *e0 = estudianteCrear(n0, g0, edad);
	estudiante *e1 = estudianteCrear(n1, g0, edad);
	insertarAtras( a0, e0);
	insertarAtras( a0, e1);
	assert(a0->primero->siguiente != NULL);
	assert(a0->primero->anterior == NULL);
	assert(a0->primero->dato == e0);
	assert(a0->ultimo->siguiente == NULL);
	assert(a0->ultimo->anterior != NULL);
	assert(a0->ultimo->dato == e1);
	altaListaImprimir( a0, "a2.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	altaListaBorrar( a0, (tipoFuncionBorrarDato)estudianteBorrar );
	printf("%s\n", "altaListaConDos correcto");
}
void prueba_edadMedia(){
	printf("%s\n","Probando edad media" );
	altaLista *a0 = altaListaCrear();
	unsigned int edad0 = 20;
	unsigned int edad1 = 40;
	char * nombre0 = "hola";
	char * nombre1 = "hola";
	char * nombre2 = "seniora";
	char * nombre3 = "senior";
	char * grupo0 = "swinger";
	char * grupo1 = "monjes";
	estudiante * e0 = estudianteCrear(nombre0, grupo0, edad0);
	estudiante * e1 = estudianteCrear(nombre1, grupo1, edad1);
	estudiante * e2 = estudianteCrear(nombre2, grupo1, edad1);
	estudiante * e3 = estudianteCrear(nombre3, grupo1, edad1);
	insertarAtras( a0, e0);
	printf("%s%f\n","Con uno deberia dar 20 y dio ",edadMedia(a0));
	insertarAtras( a0, e1);
	printf("%s%f\n","Con dos deberia dar 30 y dio ",edadMedia(a0));
	insertarAtras( a0, e2);
	printf("%s%f\n","Con tres deberia dar 33.33 y dio ",edadMedia(a0));
	insertarAtras( a0, e3);
	printf("%s%f\n","Con cuatro deberia dar 35 y dio ",edadMedia(a0));
	printf("%s\n","edad Media correcto?" );
	altaListaBorrar(a0, (tipoFuncionBorrarDato)estudianteBorrar);
}
void prueba_insertarOrdenado(){
	remove("aO1.txt");
	printf("%s\n","Probando insertarOrdenado" );
	altaLista *a0 = altaListaCrear();
	unsigned int edad0 = 20;
	unsigned int edad1 = 40;
	char * nombre0 = "hola";
	char * nombre1 = "hola";
	char * nombre2 = "seniora";
	char * nombre3 = "senior";
	char * nombre4 = "caZa";
	char * nombre5 = "casa";
	char * grupo0 = "swinger";
	char * grupo1 = "monjes";
	estudiante * e0 = estudianteCrear(nombre0, grupo0, edad0);
	estudiante * e1 = estudianteCrear(nombre1, grupo1, edad1);
	estudiante * e2 = estudianteCrear(nombre2, grupo1, edad1);
	estudiante * e3 = estudianteCrear(nombre3, grupo1, edad1);
	estudiante * e4 = estudianteCrear(nombre4, grupo1, edad1);
	estudiante * e5 = estudianteCrear(nombre5, grupo1, edad1);
	insertarOrdenado( a0, e0, (tipoFuncionCompararDato)menorEstudiante );
	altaListaImprimir( a0, "aO1.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	insertarOrdenado( a0, e1, (tipoFuncionCompararDato)menorEstudiante );
	altaListaImprimir( a0, "aO1.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	insertarOrdenado( a0, e2, (tipoFuncionCompararDato)menorEstudiante );
	altaListaImprimir( a0, "aO1.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	insertarOrdenado( a0, e3, (tipoFuncionCompararDato)menorEstudiante );
	altaListaImprimir( a0, "aO1.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	insertarOrdenado( a0, e4, (tipoFuncionCompararDato)menorEstudiante );
	altaListaImprimir( a0, "aO1.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	insertarOrdenado( a0, e5, (tipoFuncionCompararDato)menorEstudiante );
	altaListaImprimir( a0, "aO1.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	altaListaBorrar(a0, (tipoFuncionBorrarDato)estudianteBorrar);
	printf("%s\n","insertarOrdenado correcto?" );
}

void prueba_filtrar(){
	remove("af.txt");
	printf("%s\n","Probando filtrar" );
	altaLista *a0 = altaListaCrear();
	unsigned int edad0 = 20;
	unsigned int edad1 = 40;
	char * nombre0 = "hola";
	char * nombre1 = "hola";
	char * nombre2 = "seniora";
	char * nombre3 = "senior";
	char * nombre4 = "caZa";
	char * nombre5 = "casa";
	char * grupo0 = "swinger";
	char * grupo1 = "monjes";
	estudiante * e0 = estudianteCrear(nombre0, grupo0, edad0);
	estudiante * e1 = estudianteCrear(nombre1, grupo1, edad1);
	estudiante * e2 = estudianteCrear(nombre2, grupo1, edad1);
	estudiante * e3 = estudianteCrear(nombre3, grupo1, edad1);
	estudiante * e4 = estudianteCrear(nombre4, grupo1, edad1);
	estudiante * e5 = estudianteCrear(nombre5, grupo1, edad1);
	estudiante * e6 = estudianteCrear(nombre4, grupo1, edad0);
	insertarOrdenado( a0, e0, (tipoFuncionCompararDato)menorEstudiante );
	insertarOrdenado( a0, e1, (tipoFuncionCompararDato)menorEstudiante );
	insertarOrdenado( a0, e2, (tipoFuncionCompararDato)menorEstudiante );
	insertarOrdenado( a0, e3, (tipoFuncionCompararDato)menorEstudiante );
	insertarOrdenado( a0, e4, (tipoFuncionCompararDato)menorEstudiante );
	insertarOrdenado( a0, e5, (tipoFuncionCompararDato)menorEstudiante );
	// tengo e4,e5,e0,e1,e3,e2
	altaListaImprimir( a0, "af.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	filtrarAltaLista(a0,(tipoFuncionCompararDato)menorEstudiante,e3);
	// ahora tengo e4,e5,e0,e1,e3
	altaListaImprimir( a0, "af.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	filtrarAltaLista(a0,(tipoFuncionCompararDato)menorEstudiante,e0);
	//ahora tengo e4,e5,e0
	altaListaImprimir( a0, "af.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	filtrarAltaLista(a0,(tipoFuncionCompararDato)menorEstudiante,e5);
	// ahora tengo e4,e5
	altaListaImprimir( a0, "af.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	filtrarAltaLista(a0,(tipoFuncionCompararDato)menorEstudiante,e6);
	//ahora no tengo nada
	altaListaImprimir( a0, "af.txt", (tipoFuncionImprimirDato)estudianteImprimir );
	altaListaBorrar(a0, (tipoFuncionBorrarDato)estudianteBorrar);
	printf("%s\n","filtrar correcto?" );
	estudianteBorrar(e6);

}


int main (void){
	// COMPLETAR AQUI EL CODIGO
	prueba_stringLongitud();
	//prueba_stringCopia();
	prueba_stringMenor();
	prueba_estudianteCreacion();
	prueba_estudianteComparacion();
	prueba_estudianteFormato();
	prueba_crearNodo();
	prueba_altaListaCrear();
	prueba_altaListaConUno();
	prueba_altaListaConDos();
	prueba_edadMedia();
	prueba_insertarOrdenado();
	prueba_filtrar();
	return 0;
}

