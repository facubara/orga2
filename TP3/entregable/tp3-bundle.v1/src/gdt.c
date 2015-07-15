/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de la tabla de descriptores globales
*/

#include "gdt.h"




/* Definicion de la GDT */
/* -------------------------------------------------------------------------- */

gdt_entry gdt[GDT_COUNT] = {
    /* Descriptor nulo*/
    /* Offset = 0x00 */
    [GDT_IDX_NULL_DESC] = (gdt_entry) {
        (unsigned short)    0x0000,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)     0x00,           /* base[23:16]  */
        (unsigned char)     0x00,           /* type         */
        (unsigned char)     0x00,           /* s            */
        (unsigned char)     0x00,           /* dpl          */
        (unsigned char)     0x00,           /* p            */
        (unsigned char)     0x00,           /* limit[16:19] */
        (unsigned char)     0x00,           /* avl          */
        (unsigned char)     0x00,           /* l            */
        (unsigned char)     0x00,           /* db           */
        (unsigned char)     0x00,           /* g            */
        (unsigned char)     0x00,           /* base[31:24]  */
    },


	
		 /* codigo kernel
		 */
        [8] = (gdt_entry) {
        (unsigned short)    0xF3FF,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)     0x00,           /* base[23:16]  */
        (unsigned char)     0x08,           /* type         */ 
        (unsigned char)     0x01,           /* s            */ 
        (unsigned char)     0x00,           /* dpl          */
        (unsigned char)     0x01,           /* p            */
        (unsigned char)     0x01,           /* limit[16:19] */
        (unsigned char)     0x00,           /* avl          */
        (unsigned char)     0x00,           /* l            */
        (unsigned char)     0x01,           /* db           */ 
        (unsigned char)     0x01,           /* g            */
        (unsigned char)     0x00,           /* base[31:24]  */
    },


	/*
		 * codigo user
		 */
        [9] = (gdt_entry) {
        (unsigned short)    0xF3FF,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)     0x00,           /* base[23:16]  */
        (unsigned char)     0x08,           /* type         */ 
        (unsigned char)     0x01,           /* s            */ 
        (unsigned char)     0x03,           /* dpl          */
        (unsigned char)     0x01,           /* p            */
        (unsigned char)     0x01,           /* limit[16:19] */
        (unsigned char)     0x00,           /* avl          */
        (unsigned char)     0x00,           /* l            */
        (unsigned char)     0x01,           /* db           */ 
        (unsigned char)     0x01,           /* g            */
        (unsigned char)     0x00,           /* base[31:24]  */
    },

	/*
		 * datos kernel
		 */
        [10] = (gdt_entry) {
        (unsigned short)    0xF3FF,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)     0x00,           /* base[23:16]  */
        (unsigned char)     0x02,           /* type         */ 
        (unsigned char)     0x01,           /* s            */ 
        (unsigned char)     0x00,           /* dpl          */
        (unsigned char)     0x01,           /* p            */
        (unsigned char)     0x01,           /* limit[16:19] */
        (unsigned char)     0x00,           /* avl          */
        (unsigned char)     0x00,           /* l            */
        (unsigned char)     0x01,           /* db           */ 
        (unsigned char)     0x01,           /* g            */
        (unsigned char)     0x00,           /* base[31:24]  */
    },


	/*
		 * datos user
		 */
        [11] = (gdt_entry) {
        (unsigned short)    0xF3FF,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)     0x00,           /* base[23:16]  */
        (unsigned char)     0x02,           /* type         */ 
        (unsigned char)     0x01,           /* s            */ 
        (unsigned char)     0x03,           /* dpl          */
        (unsigned char)     0x01,           /* p            */
        (unsigned char)     0x01,           /* limit[16:19] */
        (unsigned char)     0x00,           /* avl          */
        (unsigned char)     0x00,           /* l            */
        (unsigned char)     0x01,           /* db           */ 
        (unsigned char)     0x01,           /* g            */
        (unsigned char)     0x00,           /* base[31:24]  */
    },


    /*segmento video: 
         
         */
        [12] = (gdt_entry) {
        (unsigned short)    0x0FFF,         /* limit[0:15]  */
        (unsigned short)    0x8000,         /* base[0:15]   */
        (unsigned char)     0x0B,           /* base[23:16]  */
        (unsigned char)     0x02,           /* type         */ 
        (unsigned char)     0x01,           /* s            */ 
        (unsigned char)     0x00,           /* dpl          */
        (unsigned char)     0x01,           /* p            */
        (unsigned char)     0x00,           /* limit[16:19] */
        (unsigned char)     0x00,           /* avl          */
        (unsigned char)     0x00,           /* l            */
        (unsigned char)     0x01,           /* db           */ 
        (unsigned char)     0x00,           /* g            */
        (unsigned char)     0x00,           /* base[31:24]  */
    },
      
    /*  
		 * tarea inicial
		 */ 
        [13] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* 
		 * tss idle
		 */ 
        [14] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss A1
		 */ 
        [15] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss A2
		 */ 
        [16] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss A3
		 */ 
        [17] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss A4
		 */ 
        [18] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss A5
		 */ 
        [19] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss A6
		 */ 
        [20] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss A7
		 */ 
        [21] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss A8
		 */ 
        [22] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss B1
		 */ 
        [23] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss B2
		 */ 
        [24] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss B3
		 */ 
        [25] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss B4
		 */ 
        [26] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss B5
		 */ 
        [27] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss B6
		 */ 
        [28] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss B7
		 */ 
        [29] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
    	/* tss B8
		 */ 
        [30] = (gdt_entry) {
        (unsigned short)    0x0067,         /* limit[0:15]  */
        (unsigned short)    0x0000,         /* base[0:15]   */
        (unsigned char)       0x00,         /* base[23:16]  */
        (unsigned char)       0x09,         /* type         */ 
        (unsigned char)       0x00,         /* s            */ 
        (unsigned char)       0x00,         /* dpl          */
        (unsigned char)       0x01,         /* p            */
        (unsigned char)       0x00,         /* limit[16:19] */
        (unsigned char)       0x00,         /* avl          */
        (unsigned char)       0x00,         /* l            */
        (unsigned char)       0x00,         /* db           */ 
        (unsigned char)       0x00,         /* g            */
        (unsigned char)       0x00,         /* base[31:24]  */
    },
    
};

gdt_descriptor GDT_DESC = {
    sizeof(gdt) - 1,
    (unsigned int) &gdt
};
