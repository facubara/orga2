#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "test.h"
#include "bmp/bmp.h"
#include "filters/filters.h"


int main(){
	float hh,ss,ll;
	hh = 31.0;
	ss = 1.0;
	ll = 0.2;
	run_hsl(0,"colores.204x204.orig.bmp", "coloresR.bmp", hh, ss, ll, 1000 );
	return 0;
}
