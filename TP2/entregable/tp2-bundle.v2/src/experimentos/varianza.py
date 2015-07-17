import fileinput
import math

suma = 0
lines = 0
for line in fileinput.input():	
	suma = suma + int(line)**2
	lines = lines + 1
suma = suma//lines
suma = math.sqrt(suma);
print(suma)

