#!/bin/bash
for file in ./log/*
do 	
	python2 algo.py $file>$file.promedio
done
