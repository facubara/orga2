#!/bin/bash
DIR=(log mem txt ult)

tmp=tmp.txt

for dir in ${DIR[*]};
do 
	rm $dir/*.promedio
	for file in $dir/*
	do 
		echo "quitando outliers de $file en $$dir"
		sort -g $file>$tmp
		sed '1,200d' $tmp>$file
		sort -g -r $file>$tmp
		sed '1,200d' $tmp>$file
		rm $tmp
	done

	
	for file in $dir/*
	do 	
		echo "calculando promedio $file en $dir"
		python2 algo.py $file>$file.promedio
	done
done
exit 0
