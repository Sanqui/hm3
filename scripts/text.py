#!/usr/bin/python3
import struct
import csv
import re
import json
from sys import argv
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
def readchar(w_length=False):
    l = 0
    char = rom.read(1)
    l += 1
    nextchar = rom.read(1)
    rom.seek(-1, 1)
    # XXX THIS WHOLE THING IS BROKEN
    if ord(char) != 0 and (ord(char)<<8) + ord(nextchar) in charmap:
        char = charmap[(ord(char)<<8) + ord(nextchar)]
        rom.read(1)
        l += 1
    elif ord(char) in charmap:
        char = charmap[ord(char)]
    else:
        stderr.write("Unknown character: {:02x}\n".format(ord(char)))
        return None
        #char = "<:02x>".format(ord(char))
    if w_length:
        return char, l
    else:
        return char

def readstring(length=None):
    string = []
    line = ""
    i = 0
    while True:
        if length is not None and i >= length:
            string.append(line)
            break
        char, l = readchar(w_length=1)
        i += l
        #if char == "<name>":
        #    name_i = readbyte()
        #    char = f"<name:{name_i}>"
        #    i += 1
        if char != None:
            line += char
        if char in BREAK_CHARS:
            string.append(line)
            line = ""
        if length is None and char in END_CHARS:
            string.append(line)
            break
    return string

def peekchar():
    char = readchar()
    rom.seek(-1, 1)
    return char

def seekba(bank, address):
    rom.seek(bank*0x4000 + address % 0x4000)

charmap = {}
for line in open("build/charmap.asm"):
    if line.startswith("charmap"):
        line = line.split(" ", 1)[1]
        string, num = line.split(", $", 1)
        string = string.strip()[1:-1]
        num = int(num.strip().lstrip("$"), 16)
        charmap[num] = string
charmap_r = dict([[v,k] for k,v in charmap.items()])

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
    #print(f"Reading metatable 0x{gbswitch(metatable_address)} w/ {count} strings")
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
stringtrash = {}
stringindexes = {}
stringends = {}
tablekeys = sorted(list(tables.keys()))
for sti, (tpointer, tpointernext) in enumerate(zip(tablekeys, tablekeys[1:]+[None])):
    stringtable = tables[tpointer]
    stringtablenextfirst = None
    if tpointernext:
        stringtablenext = tables[tpointernext]
        stringtablenextfirst = stringtablenext[0]
    for pti, (address, addressnext) in enumerate(zip(stringtable, stringtable[1:]+[stringtablenextfirst])):
        if address < 0: continue
        rom.seek(address)
        string = readstring()
        end_address = rom.tell()
        if addressnext and addressnext > 0 and addressnext < end_address:
            rom.seek(address)
            string = readstring(addressnext-address)
            #print("new end:", hex(rom.tell()), gbswitch(rom.tell()))
            end_address = rom.tell()
        strings[address] = string
        stringends[address] = end_address
        if address not in stringindexes:
            stringindexes[address] = []
        stringindexes[address].append((tpointer, pti))
        trash_address = end_address
        if addressnext and addressnext > 0 and 0 < addressnext-trash_address < 64:
            stringtrash[address] = readstring(addressnext-trash_address)
            stringends[trash_address] = rom.tell()

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

def strings_to_csv():
    for sti, (sp, stringtable) in enumerate(tables.items()):
        name = tablenames[sp]
        if name == None: continue
        print(f"; Table {name} has {len(stringtable)} strings")
        path = "/".join(name.split("/")[0:-1])
        Path.mkdir(Path(f"text/{path}"), parents=True, exist_ok=True)
        with open(f"text/{name}.csv", "w") as f:
            fcsv = csv.writer(f)
            fcsv.writerow("i address end name_i newlines name string".split())
            for i, address in enumerate(stringtable):
                name_i = None
                name = None
                trash = None
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
                            r"\s*<fc><f0><clear>$",
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
                    trash = stringtrash[address] if address in stringtrash else None
                #if string.startswith("<name:"):
                #    name_code, string = string.split(">", 1)
                #    name_i = name_code.split(":")[1]
                #    name_i = int(name_i)
                #    name = names[name_i]
                if string.startswith("<name>"):
                    name_i = charmap_r[string[6]]
                    string = string[7:]
                stringend = stringends[address] if address in stringends else -1
                fcsv.writerow([i, hex(address), hex(stringend), name_i, json.dumps(newline_types), name, string])
                if trash != None:
                    fcsv.writerow([f"{i}-TRASH", hex(stringends[address]), hex(stringends[stringends[address]]), "", "", "", "\n".join(stringtrash[address])])
    
    print("; Wrote CSV files")

def print_strings_from_csvs():
    def calculate_newlines(string):
        LINELEN = 16
        def xlen(string):
            string = (c for c in string)
            l = 0
            while True:
                try:
                    c = next(string)
                except StopIteration:
                    break
                if c != "<":
                    l += 1
                else:
                    code = ""
                    while c != ">":
                        c = next(string)
                        code += c
                    if code == "player":
                        l += 4
                    elif code == "var":
                        l += 4
                    else:
                        l += 0
            return l
        
        lines = []
        for oline in string.split('\n'):
            owords = oline.split(" ")
            line = ""
            for wordi, word in enumerate(owords):
                if xlen(line + word) == LINELEN:
                    line += word
                    lines.append(line)
                    line = ""
                    continue
                elif xlen(line + word) > LINELEN:
                    lines.append(line)
                    line = word
                    if wordi < len(owords):
                        line += " "
                else:
                    line += word
                    if wordi < len(owords):
                        line += " "
            lines.append(line)
        
        return "\n".join(lines)

    filenames = []
    for _, _, subtables in METATABLES:
        filenames += subtables
    for _, _, table in TABLES:
        filenames.append(table)
    
    csvstrings = {}
    csvstringindexes = {}
    csvstringends = {}
    for filename in filenames:
        if not filename: continue
        with open("text/"+filename+".csv", "r") as f:
            fcsv = csv.reader(f)
            next(fcsv)
            for row in fcsv:
                newstring = None
                new = False
                if len(row) == 7:
                    csvi, address, end, name_i, newlines, name, string = row
                else:
                    csvi, address, end, name_i, newlines, name, string, newstring = row
                if newstring != None and newstring != "":
                    new = True
                    string = newstring
                #if i != "TRASH":
                #    i = int(i)
                csvi = csvi.replace("-", "_")
                address = int(address, 16)
                end = int(end, 16)
                if name_i:
                    name_i = int(name_i)
                else:
                    name_i = None
                if newlines:
                    newlines = json.loads(newlines)
                else:
                    newlines = []
                csvstring = ""
                if name_i is not None:
                    csvstring += "<name>" + charmap[name_i]
                if newlines:
                    if not new:
                        for line, newline in zip(string.split("\n"), newlines):
                            csvstring += line + newline + "\n"
                    else:
                        string = calculate_newlines(string)
                        numlines = len(string.split("\n"))
                        for linei, line in enumerate(string.split("\n")):
                            csvstring += line
                            if linei == numlines-1:
                                csvstring += newlines[-1]
                            else:
                                csvstring += newlines[linei%2]
                else:
                    csvstring = string+"\n"
                csvstring = csvstring[:-1].split("\n")
                csvstrings[address] = csvstring
                csvstringends[address] = end
                if address not in csvstringindexes:
                    csvstringindexes[address] = []
                csvstringindexes[address].append((filename, csvi))
    
    SANIT_CHECK = False
    if SANIT_CHECK:
        for string_address in strings:
            if string_address not in csvstrings:
                print(f"; {gbswitch(string_address)} not in csvstrings")
            else:
                if strings[string_address] != csvstrings[string_address]:
                    pprint(strings[string_address])
                    pprint(csvstrings[string_address])
                    print()
                else:
                    pass
                    print("; OK")
    
    last_address = None
    
    for address in sorted(csvstrings):
        if address < -1: continue
        indexes = csvstringindexes[address]
        string = csvstrings[address]
        #print(address, index)
        if last_address != address:
            if last_address:
                print(f"; {gbswitch(last_address)}\n")
            print("SECTION \"Text at {1:02x}:{0:04x}\", ROMX[${0:04x}], BANK[${1:02x}]".format(address%0x4000 + 0x4000, address//0x4000))
        for tname, i in indexes:
            #label = "String{}_{}".format(ih, il)
            label = f"String{tolabel(tname)}_{i}"
            print("{}::".format(label))
        for line in string:
            outline = ""
            for character in line:
                if character not in charmap_r or \
                  charmap_r[character] < 0x100:
                    outline += character
                else:
                    c = charmap_r[character]
                    hi = c >> 8
                    lo = c & 0xff
                    outline += f'", ${hi:02x}, ${lo:02x}, "'
            print(f'\tdb "{outline}"')
        last_address = csvstringends[address]
        #print(f"; {gbswitch(last_address)}")
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
    #strings_to_csv()
    if argv[1] == "asm_from_csv":
        print_strings_from_csvs()
    #print_pointer_table()
