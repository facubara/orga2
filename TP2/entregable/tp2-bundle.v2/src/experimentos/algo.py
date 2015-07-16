import fileinput

suma = 0
lines = 0
for line in fileinput.input():	
	suma = suma + int(line)
	lines = lines + 1
print(suma//lines)

