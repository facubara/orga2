import fileinput
import math

suma = 0
lines = 0
promedio = 0
for line in fileinput.input():	
		suma = suma + int(line)
		lines = lines + 1
promedio=suma//lines

suma = 0	
for line in fileinput.input():
	suma = suma + (int(line)-promedio)**2
suma = suma//lines
suma = math.sqrt(suma);
print(int(suma))

