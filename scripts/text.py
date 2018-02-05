#!/usr/bin/python3
import struct
import csv
from pprint import pprint
from sys import stderr

BANK_NAMES = """strings/dummy strings/items strings/strings strings/goods strings/animals
dialogue/maomao dialogue/girl_intro dialogue/story dialogue/record dialogue/comedians
dialogue/boy_intro dialogue/endings strings/character_choice strings/save
"""

BREAK_CHARS = ("\\n", "<fd>",)
END_CHARS = ("@", "<end>",  None)
BANK = 0x79
POINTER_TABLE_ADDRESS = 0x1e44a0
NUMTABLE = 0x16
NUMSENSE = 14

EXTRA_TABLES = [(0x10c089, 16, "strings/characters"]
#BANK_TABLE_ADDRESS = 0x1c*0x4000 + 0x0741

def readbyte():  return struct.unpack("B",  rom.read(1))[0]
def readshort(): return struct.unpack("<H", rom.read(2))[0]
def readchar():
    char = rom.read(1)
    nextchar = rom.read(1)
    rom.seek(-1, 1)
    if (ord(char)<<8) + ord(nextchar) in charmap:
        char = charmap[(ord(char)<<8) + ord(nextchar)]
        rom.read(1)
    elif ord(char) in charmap:
        char = charmap[ord(char)]
    else:
        stderr.write("Unknown character: {:02x}\n".format(ord(char)))
        return None
        #char = "<:02x>".format(ord(char))
    return char

def peekchar():
    char = readchar()
    rom.seek(-1, 1)
    return char

def seekba(bank, address):
    rom.seek(bank*0x4000 + address % 0x4000)

charmap = {}
for line in open("charmap.asm"):
    if line.startswith("charmap"):
        line = line.split(" ", 1)[1]
        string, num = line.split(", $", 1)
        string = string.strip()[1:-1]
        num = int(num.strip().lstrip("$"), 16)
        charmap[num] = string
    

rom = open("baserom.gbc", "br")

rom.seek(POINTER_TABLE_ADDRESS)
metapointers = []

for i in range(NUMTABLE):
    pointer = readshort()
    metapointers.append(pointer)
    #print(i, hex(offset))

pprint(metapointers)

stringtables = []
extratables = {}

for i, (metapointer, metapointer2) in enumerate(zip(metapointers, metapointers[1:]+[None])):
    if i >= NUMSENSE: break
    print(hex(i), hex(metapointer), hex(metapointer2) if metapointer2 else None)
    seekba(BANK, metapointer)
    pointers = []
    while True:
        pointer = readshort()
        if not metapointer2:
            break
        elif rom.tell() % 0x4000 + 0x4000 > metapointer2:
            break
        pointers.append(pointer)
    stringtables.append(pointers)

for table, count, name in EXTRA_TABLES:
    rom.seek(table)
    pointers = []
    for i in range(count):
        pointer = readshort()
        pointers.append(pointer)
    extratables[table] = pointers
#pprint(stringtables)

strings = {}
stringindexes = {}
stringends = {}
for sti, stringtable in enumerate(stringtables):
    for pti, pointer in enumerate(stringtable):
        seekba(BANK, pointer)
        string = []
        line = ""
        while True:
            char = readchar()
            if char != None:
                line += char
            if char in BREAK_CHARS:
                string.append(line)
                line = ""
            if char in END_CHARS:
                string.append(line)
                break
        strings[pointer] = string
        stringends[pointer] = rom.tell()
        if pointer not in stringindexes:
            stringindexes[pointer] = []
        stringindexes[pointer].append((sti, pti))

for sti, stringtable in enumerate(stringtables):
    print(f"Table {sti} has {len(stringtable)} strings")
    with open(f"text/{sti}.csv", "w") as f:
        for i, pointer in enumerate(stringtable):
            string = "\n".join(strings[pointer]).rstrip("@")
            fcsv = csv.writer(f)
            fcsv.writerow([i, hex(pointer), string])

def print_strings():
    last_pointer = None
    
    for pointer in sorted(strings):
        indexes = stringindexes[pointer]
        string = strings[pointer]
        #print(address, index)
        if last_pointer != pointer:
            print("SECTION \"Text at {0:04x}\", ROMX[${0:04x}], BANK[${1:02x}]".format(pointer, BANK))
        for ih, il in indexes:
            label = "String{}_{}".format(ih, il)
            print("{}::".format(label))
        for line in string:
            print("\tdb \"{}\"".format(line))
        last_pointer = stringends[pointer] % 0x4000 + 0x4000
        print("; {:02x}:{:x}".format(BANK, last_pointer))
        print()

def print_pointer_table():
    bank = POINTER_TABLE_ADDRESS // 0x4000
    pointer = POINTER_TABLE_ADDRESS % 0x4000 + 0x4000
    print("SECTION \"Text pointer table\", ROMX[${:04x}], BANK[${:02x}]".format(pointer, bank))
    for i in range(NUMSTRINGS):
        print("\tdw Dialogue{}".format(i))
    
    print()
    bank = BANK_TABLE_ADDRESS // 0x4000
    pointer = BANK_TABLE_ADDRESS % 0x4000 + 0x4000
    print("SECTION \"Text bank table\", ROMX[${:04x}], BANK[${:02x}]".format(pointer, bank))
    for i in range(NUMSTRINGS):
        bank = banks[i]
        bank_high = bank & 0xc0
        if bank_high:
            print("\tdb BANK(Dialogue{}) | ${:02x}".format(i, bank_high))
        else:
            print("\tdb BANK(Dialogue{})".format(i))

if __name__ == "__main__":
    # comment/uncomment whichever you want

    #pprint(dict(enumerate(strings)))
    print_strings()
    #print_pointer_table()
