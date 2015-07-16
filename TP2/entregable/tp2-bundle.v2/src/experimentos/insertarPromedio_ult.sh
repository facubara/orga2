#!/bin/bash
for file in ./ult/*
do 	
	python2 algo.py $file>$file.promedio
done
