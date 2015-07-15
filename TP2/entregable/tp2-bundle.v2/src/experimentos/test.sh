#!/bin/bash

# Esto es para correr aun mas facil

PROGRAMA = ../../bin/correrTest
IMAGENES = (colores.204x204.orig.bmp otraImagen)

echo "corriendo test 1"
$PROGRAMA 0 1 $IMAGENES[0] 1000 "probando.txt"