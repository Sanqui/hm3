import sys

for line in open(sys.argv[1]):
    hex, char = line.strip("\r\n").split('=', 1)
    if char == '"': char = '\\"'
    print('charmap "{}", ${}'.format(char, hex))
