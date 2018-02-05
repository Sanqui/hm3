#!/usr/bin/python3
import struct
import csv
from pprint import pprint
from sys import stderr
from pathlib import Path
from gbaddr import gbaddr

BANK_NAMES = """strings/dummy strings/items strings/strings strings/goods strings/animals
dialogue/maomao dialogue/girl_intro dialogue/story dialogue/record dialogue/comedians
dialogue/boy_intro dialogue/endings strings/character_choice strings/save
""".split()

BREAK_CHARS = ("\\n", "<fd>",)
END_CHARS = ("@", "<end>",  None)
BANK = 0x79
POINTER_TABLE_ADDRESS = 0x1e44a0
NUMTABLE = 0x16
NUMSENSE = 14

EXTRA_TABLES = [
 (gbaddr("2e:400f"), 4, 130, "dialogue0"),
 (gbaddr("43:401f"), 8, 185, "dialogue1"),
 (gbaddr("7c:55f7"), 10, 65, "dialogue1alt"),
 (gbaddr("18:400f"), 5, 74, "dialogue2"),
 (gbaddr("50:57f6"), 8, 71, "dialogue3"),
 (gbaddr("42:401f"), 6, 136, "dialogue4"),
 (gbaddr("50:6878"), 7, 49, "dialogue4alt"),
 (gbaddr("4b:400f"), 8, 198, "dialogue5"),
 (gbaddr("4a:4089"), 0, 41, "names")]
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

#pprint(metapointers)

#stringtables = []
tables = {}
tablenames = {}

for i, (metapointer, metapointer2) in enumerate(zip(metapointers, metapointers[1:]+[None])):
    if i >= NUMSENSE: break
    #print(hex(i), hex(metapointer), hex(metapointer2) if metapointer2 else None)
    seekba(BANK, metapointer)
    addresses = []
    while True:
        pointer = readshort()
        if not metapointer2:
            break
        elif rom.tell() % 0x4000 + 0x4000 > metapointer2:
            break
        addresses.append(BANK*0x4000 + pointer%0x4000)
    tables[metapointer] = addresses
    tablenames[metapointer] = BANK_NAMES[i]

for table, skip, count, name in EXTRA_TABLES:
    rom.seek(table)
    a = []
    addresses = []
    for i in range(count):
        pointer = readshort()
        if pointer > 0x8000 or i < skip:
            addresses.append(-pointer)
        else:
            addresses.append(table//0x4000*0x4000 + pointer%0x4000)
    tables[table] = addresses
    tablenames[table] = name
#pprint(stringtables)

strings = {}
stringindexes = {}
stringends = {}
for sti, (tpointer, stringtable) in enumerate(tables.items()):
    for pti, address in enumerate(stringtable):
        if address < 0: continue
        rom.seek(address)
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
        strings[address] = string
        stringends[address] = rom.tell()
        if address not in stringindexes:
            stringindexes[address] = []
        stringindexes[address].append((sti, pti))

for sti, (sp, stringtable) in enumerate(tables.items()):
    name = tablenames[sp]
    print(f"Table {name} has {len(stringtable)} strings")
    path = "/".join(name.split("/")[0:-1])
    Path.mkdir(Path(f"text/{path}"), parents=True, exist_ok=True)
    with open(f"text/{name}.csv", "w") as f:
        for i, address in enumerate(stringtable):
            if address < 0:
                string = ""
            else:
                string = "\n".join(strings[address]).rstrip("@")
            fcsv = csv.writer(f)
            fcsv.writerow([i, hex(address), string])

def print_strings():
    last_address = None
    
    for address in sorted(strings):
        if address < -1: continue
        indexes = stringindexes[address]
        string = strings[address]
        #print(address, index)
        if last_address != address:
            print("SECTION \"Text at {1:02x}:{0:04x}\", ROMX[${0:04x}], BANK[${1:02x}]".format(address%0x4000 + 0x4000, address//0x4000))
        for ih, il in indexes:
            label = "String{}_{}".format(ih, il)
            print("{}::".format(label))
        for line in string:
            print("\tdb \"{}\"".format(line))
        last_address = stringends[address]
        print("; {:02x}:{:x}".format(BANK, last_address))
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
