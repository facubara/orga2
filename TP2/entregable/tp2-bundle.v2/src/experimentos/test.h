/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Definiciones de funciones de ejecucion de filtros                       */
/*                                                                           */
/* ************************************************************************* */

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "../bmp/bmp.h"
#include "../filters/filters.h"
#include "../rdtsc.h"

unsigned int run_blur(int c, char* src, char* dst, int iteraciones, char * archivo);

unsigned int run_merge(int c, char* src1, char* src2, char* dst, float value, int iteraciones, char * archivo);

unsigned int run_hsl(int c, char* src, char* dst, float hh, float ss, float ll, int iteraciones, char * archivo);
