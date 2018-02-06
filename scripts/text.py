#!/usr/bin/python3
import struct
import csv
import re
from pprint import pprint
from sys import stderr
from pathlib import Path
from gbaddr import gbaddr, gbswitch


def tolabel(string):
    return string.replace("/", " ").replace("_", " ").title().replace(" ", "")

BREAK_CHARS = ("\\n", "<clear>",)
END_CHARS = ("@", "<end>",  None)

TABLES = [
 (gbaddr("4a:4089"), 41, "strings/names"),
]
NAMES_TABLE = gbaddr("4a:4089")
names = []

METATABLES = [
 (gbaddr("79:44a0"), float("inf"), (
    *"""strings/dummy
    strings/items
    strings/strings
    strings/goods
    strings/animals
    dialogue/maomao
    dialogue/girl_intro
    dialogue/story
    dialogue/record
    dialogue/comedians
    dialogue/boy_intro
    dialogue/endings
    strings/character_choice
    strings/save""".split(),
    *((None,)*8)
 )),
 (gbaddr("2e:400f"), 126,
  "dialogue/town dialogue/town2".split()),
 (gbaddr("43:401f"), 177,
  "dialogue/house dialogue/house_partner_assignments strings/assignments dialogue/farming".split()),
 (gbaddr("7c:55f7"), 55,
  (None, None, None, None, "dialogue/partner_events")),
 (gbaddr("18:400f"), 68,
  "dialogue/restaurant dialogue/seed_shop dialogue/book_shop".split()),
 (gbaddr("50:5804"), 67,
  ("dialogue/farmers_union", None, None, None)),
 (gbaddr("42:401f"), 130,
  "dialogue/player_found dialogue/thanks assorted".split()),
 (gbaddr("50:6878"), 41,
  (None, None, None, "dialogue/assorted")),
 (gbaddr("4b:400f"), 190,
  "books dialogue/lucas dialogue/thanks2 dialogue/thanks3".split()),
 (gbaddr("17:400f"), 15,
  ("strings/locations",)),
]

def readbyte():  return struct.unpack("B",  rom.read(1))[0]
def readshort(): return struct.unpack("<H", rom.read(2))[0]
def readchar():
    char = rom.read(1)
    nextchar = rom.read(1)
    rom.seek(-1, 1)
    # XXX THIS WHOLE THING IS BROKEN
    if ord(char) != 0 and (ord(char)<<8) + ord(nextchar) in charmap:
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

#pprint(metapointers)

#stringtables = []
metatables = {}
tables = {}
tablenames = {}

names = []

for table, count, name in TABLES:
    rom.seek(table)
    a = []
    addresses = []
    for i in range(count):
        pointer = readshort()
        if pointer > 0x8000:
            addresses.append(-pointer)
        else:
            addresses.append(table//0x4000*0x4000 + pointer%0x4000)
    tables[table] = addresses
    tablenames[table] = name

for metatable in METATABLES:
    metatable_address, count, subtable_names = metatable
    print(f"Reading metatable 0x{gbswitch(metatable_address)} w/ {count} strings")
    bank = metatable_address // 0x4000
    rom.seek(metatable_address)
    subtable_addresses = []
    for subtable_name in subtable_names:
        ptr = readshort()
        assert 0x4000 <= ptr < 0x8000
        subtable_address = bank * 0x4000 + ptr - 0x4000
        subtable_addresses.append((subtable_address, subtable_name))
    
    
    metatable_string_count = 0
    for (i, ((staddr, stname), (staddrnext, stnamenext))) \
      in enumerate(zip(subtable_addresses, subtable_addresses[1:]+[(None, None)])):
        if stname == None: continue
        rom.seek(staddr)
        string_addresses = []
        while True:
            if staddrnext and rom.tell() >= staddrnext:
                break
            if metatable_string_count >= count:
                break
            ptr = readshort()
            if not 0x4000 <= ptr < 0x8000:
                string_address = -ptr
            else:
                string_address = bank * 0x4000 + ptr - 0x4000
            string_addresses.append(string_address)
            metatable_string_count += 1
        metatables[metatable_address] = subtable_addresses
        tables[staddr] = string_addresses
        tablenames[staddr] = stname
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
            if char == "<name>":
                name_i = readbyte()
                char = f"<name:{name_i}>"
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
        stringindexes[address].append((tpointer, pti))

# rip names for use in csvs
for string_address in tables[NAMES_TABLE]:
    if string_address > 0:
        names.append(strings[string_address][0].rstrip("@"))
    else:
        names.append(f"<{string_address:x}>")

names[0] = "<player>"
names[1] = "<partner>"
names[2] = "<2>"
names[3] = "<3>"

for sti, (sp, stringtable) in enumerate(tables.items()):
    name = tablenames[sp]
    if name == None: continue
    print(f"Table {name} has {len(stringtable)} strings")
    path = "/".join(name.split("/")[0:-1])
    Path.mkdir(Path(f"text/{path}"), parents=True, exist_ok=True)
    with open(f"text/{name}.csv", "w") as f:
        fcsv = csv.writer(f)
        fcsv.writerow("i address name_i newline_types name string".split())
        for i, address in enumerate(stringtable):
            namei = None
            name = None
            newline_types = []
            if address < 0:
                string = ""
            else:
                string = ""
                for line in strings[address]:
                    NEWLINE_TYPES = [
                        r"\s*\\n$",
                        r"\s*<arrow>0<waita><clear>$",
                        r"\s*<arrow>2<waita><clear>$",
                        r"\s*<waita>@$",
                        r"\s*<ask>.......@$",
                        r"\s*<fc>.<clear>$",
                        r"\s*<fc>.@$",
                        r"\s*@$"
                    ]
                    for nltype in NEWLINE_TYPES:
                        match = re.findall(nltype, line)
                        if match:
                            m = match[0]
                            if m.startswith("<ask>"):
                                m = m[5:]
                            newline_types.append(m)
                            line = line[:-len(m)]
                            break
                    string += line+"\n"
                string = string[:-1]
            if string.startswith("<name:"):
                name_code, string = string.split(">", 1)
                name_i = name_code.split(":")[1]
                name_i = int(name_i)
                name = names[name_i]
            fcsv.writerow([i, hex(address), name_i, newline_types, name, string])

def print_strings():
    last_address = None
    
    for address in sorted(strings):
        if address < -1: continue
        indexes = stringindexes[address]
        string = strings[address]
        #print(address, index)
        if last_address != address:
            print("SECTION \"Text at {1:02x}:{0:04x}\", ROMX[${0:04x}], BANK[${1:02x}]".format(address%0x4000 + 0x4000, address//0x4000))
        for tpointer, i in indexes:
            #label = "String{}_{}".format(ih, il)
            label = f"String{tolabel(tablenames[tpointer])}_{i}"
            print("{}::".format(label))
        for line in string:
            print("\tdb \"{}\"".format(line))
        last_address = stringends[address]
        print(f"; {gbswitch(last_address)}")
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
