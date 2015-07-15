#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "test.h"
#include "../bmp/bmp.h"
#include "../filters/filters.h"
#include <assert.h>
	/* 
		Los parametros que se van a pasar a correr test:
			parametro uno : 0 es blur 1 es merge y 2 es hsl
			parametro dos : 0 es c 1 es asm1 2 es asm2
			parametro tres : imagen src
			parametro cuatro: numero de iteraciones
			parametro cinco: nombre del archivo donde guardar el resultado
			parametro seis : merge--> float  hsl-->hh
			parametro siete : hsl --> ss merge --> la otra imagen que me olvide XD 
			parametro ocho : hsl --> ll
			
			todos los resultados de los filtros quedan en coloresR.bmp
	*/
int main(int argc, char* argv[] ){
	// conversion de parametros
	assert(argc > 5);
	int iteraciones = atoi(argv[4]);
	int filtro = atoi(argv[1]);
	int implementacion = atoi(argv[2]);

	assert(iteraciones >= 0);
	assert(implementacion >=0);
	assert(implementacion < 3);
	if (filtro == 0){
		assert(argc == 6);

		run_blur(implementacion,argv[3],"coloresR.bmp",iteraciones,argv[5]);
	}else if (filtro==1){
		assert(argc == 8);
		float value = atof(argv[6]);

		run_merge(implementacion,argv[3],argv[7],"coloresR.bmp",value,iteraciones,argv[5]);
	}else if (filtro==2){
		assert(argc == 9);
		float hh = atof(argv[6]);
		float ss = atof(argv[7]);
		float ll = atof(argv[8]);

		run_hsl(implementacion,argv[3],"coloresR.bmp",hh,ss,ll,iteraciones,argv[5]);
	}
	return 0;
}
