#!/bin/bash
tmp=tmp.txt

for file in ./mem/*
do 
	sort -g $file>$tmp
	sed '1,200d' $tmp>$file
	sort -g -r $file>$tmp
	sed '1,200d' $tmp>$file
	rm $tmp
done
