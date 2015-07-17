#!/bin/bash
DIR=(log mem txt ult blue hsl1ch)



#reciben un directorio valido

function quitarOutliers()
{
	tmp=tmp.txt
	for file in $1/*
	do 
		echo "quitando outliers de $file en $1"
		sort -g $file>$tmp
		sed '1,200d' $tmp>$file
		sort -g -r $file>$tmp
		sed '1,200d' $tmp>$file
		rm $tmp
	done
	
}

function Promedios()
{
	rm $1/*.stats
	for file in $1/*
	do
		echo "calculando promedio y varianza $file en $1"
		python3 promedio.py $file>>$file.stats
		python3 desvio.py $file>>$file.stats
	done
	
}

#no reciben nada
function promediarParaTodos()
{
	for dir in ${DIR[*]};
	do 
		Promedios $dir
	done
	
}

function quitarOutliersParaTodos()
{
	for dir in ${DIR[*]};
	do 
		quitarOutliers $dir
	done
	
}

function sacarPromediosViejos()
{
	for dir in ${DIR[*]};
	do 
		rm $dir/*promedio
	done
	
}

