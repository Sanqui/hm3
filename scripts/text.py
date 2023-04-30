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


LABELS = {0xd400: "wPlayerName",
    0xd410: "wPartnerName"}

def tolabel(string):
    return string.replace("/", " ").replace("_", " ").title().replace(" ", "")

def dumb_smart_quotes(string):
    even = False
    while '"' in string:
        if even:
            string = string.replace('"', '“')
        else:
            string = string.replace('"', '”')
        even = not even
    return string

def fixup_string(string:str) -> str:
    '''
        Fix some common mistakes in the string to be less of a bother.
    '''
    string = string.strip()
    string = string.replace("<var0>", "<var>0")
    string = string.replace("<var1>", "<var>1")
    string = string.replace("<var2>", "<var>2")
    string = string.replace("<var3>", "<var>3")
    return string

BREAK_CHARS = ("\\n", "<clear>",)
END_CHARS = ("@", "<end>",  None)

TABLES = [
 (gbaddr("4a:4089"), 42, "strings/names"),
]
NAMES_TABLE = gbaddr("4a:4089")
names = []

FORCE_NEW = True

METATABLES = [
 (gbaddr("79:44a0"), 368 - (48 - 7), (
    """strings/dummy
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
    <dialogue/endings
    <strings/character_choice
    <strings/save""".split()
 )),
 (gbaddr("2e:400f"), 126,
  "dialogue/town dialogue/town2 dialogue/billy dialogue/town3".split()),
 (gbaddr("43:401f"), 177,
  "dialogue/house dialogue/partner_assignments strings/assignments dialogue/caught\
  dialogue/house2 dialogue/weather dialogue/partner dialogue/partner_feelings".split()),
 (gbaddr("7c:55f7"), 55,
  (None, None, None, None, None,
  None, None, None, "dialogue/partner_events", "dialogue/missing")),
 (gbaddr("18:400f"), 68,
  "dialogue/restaurant dialogue/seed_shop dialogue/book_shop \
  dialogue/mall dialogue/theater".split()),
 (gbaddr("50:5804"), 63,
  ("dialogue/farmers_union",)),
 (gbaddr("42:401f"), 130,
  "dialogue/player_found dialogue/thanks dialogue/partner_love\
  dialogue/ferry fishing dialogue/assorted".split()),
 (gbaddr("50:6878"), 41,
  (None, None, None, None,
  None, None, "dialogue/assorted2")),
 (gbaddr("4b:400f"), 190,
  "books dialogue/lucas dialogue/thanks2 dialogue/thanks3 \
  dialogue/assorted3 dialogue/pak dialogue/snowboarding strings/buildings".split()),
 (gbaddr("17:400f"), 15,
  ("strings/locations_island", "strings/locations_mainland",)),
 (gbaddr("50:4b7e"), 15+2+9+10+8,
  (*(None,)*11,
  ">dialogue/endings", ">strings/character_choice", ">strings/save",
  "strings/main_menu", "dialogue/partner_introductions",
  "dialogue/wedding_boy", "dialogue/wedding_girl",
  "dialogue/evaluation")
 ),
 (gbaddr("4b:6c1f"), 17,
  ("dialogue/naysaying",)
 ),
 (gbaddr("07:400f"), 16+1+16+16+2+4,
  ("signs/farm", "signs/garden", "signs/barns", "signs/backyard",
   "signs/hot_spring", "signs/outside", *(None,)*13)
 ),
 (gbaddr("7c:437a"), 24+32+19+47+2,
  ("dialogue/snowboard", "dialogue/market", "dialogue/tutorial",
   "strings/credits", "dialogue/sound_test")),
 (gbaddr("01:52f9"), 5+48+64,
  ("strings/test", "strings/debug", "strings/items_select", )),
 (gbaddr("20:400f"), 81,
  ("dialogue/animals",)),
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
charmap_r = {}
for line in open("build/charmap.asm"):
    if line.startswith("charmap"):
        line = line.split(" ", 1)[1]
        string, num = line.split(", $", 1)
        string = string.strip()[1:-1]
        num = int(num.strip().lstrip("$"), 16)
        charmap[num] = string
        charmap_r[string] = num

vwflength = []
for line in open("src/hack/vwftable.asm"):
    line = line.split(';')[0]
    line = line.strip()
    if line.startswith("db "):
        line = line.split("db ")[1]
        vwflength += [int(w) for w in line.split(',')]

rom = open("baserom.gbc", "br")

#pprint(metapointers)

#stringtables = []
metatables = {}
tables = {}
tables_by_name = {}
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

metatable_subtable_addresses = {}
subtable_string_counts = {}
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
    
    metatable_subtable_addresses[metatable_address] = subtable_addresses
    
    metatable_string_count = 0
    for (i, ((staddr, stname), (staddrnext, stnamenext))) \
      in enumerate(zip(subtable_addresses, subtable_addresses[1:]+[(None, None)])):
        if stname == None: continue
        if stname.startswith(">"): continue
        rom.seek(staddr)
        string_addresses = []
        while True:
            if staddrnext and stnamenext and rom.tell() >= staddrnext:
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
        tables_by_name[stname] = string_addresses
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
        if stringtablenext:
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
        if addressnext and addressnext > 0 and addressnext-trash_address > 0 and (0 < addressnext-trash_address < 32 or (address//0x4000 == 1 and addressnext//0x4000 == 1)):
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
        if name.startswith(">"): continue
        name = name.lstrip("<")
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
                            r"\s*<arrow>0<waita>@$",
                            r"\s*<arrow>2<waita>@$",
                            r"\s*<arrow>0<waita><clear>$",
                            r"\s*<arrow>2<waita><clear>$",
                            r"\s*<fc><f0><clear>$",
                            r"\s*<waita>@$",
                            r"\s*<ask>.......@$",
                            r"\s*<fc>.<clear>$",
                            r"\s*<fc>.@$",
                            r"\s*@$"
                        ]
                        matched = False
                        for nltype in NEWLINE_TYPES:
                            match = re.findall(nltype, line)
                            if match:
                                m = match[0]
                                if m.startswith("<ask>"):
                                    m = m[5:]
                                newline_types.append(m)
                                line = line[:-len(m)]
                                matched = True
                                break
                        if not matched:
                            newline_types.append("")
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
                    name = names[name_i]
                stringend = stringends[address] if address in stringends else -1
                fcsv.writerow([i, hex(address), hex(stringend), name_i, json.dumps(newline_types), name, string])
                if trash != None:
                    fcsv.writerow([f"{i}-TRASH", hex(stringends[address]), hex(stringends[stringends[address]]), "", "", "", "\n".join(stringtrash[address])])
    
    print("; Wrote CSV files")

def print_strings_from_csvs():
    def calculate_newlines(string):
        LINELEN = 16*8-1
        def xlen(string):
            string = (c for c in string)
            l = 0
            while True:
                try:
                    c = next(string)
                except StopIteration:
                    break
                if c != "<":
                    if c in charmap_r:
                        cnum = charmap_r[c]
                    else:
                        print(f"Warning: {c} not in charmap_r")
                        cnum = 8
                    if cnum >= 0x100:
                        cnum = (cnum & 0xff) + 0xf0
                    l += vwflength[cnum]
                else:
                    code = ""
                    while c != ">":
                        c = next(string)
                        code += c
                    code =code.rstrip(">")
                    if code == "player":
                        l += 8*6
                    elif code == "partner":
                        l += 8*6
                    elif code == "var":
                        l += 4*6
                    else:
                        l += 0
            return l
        
        lines = []
        for oline in string.split('\n'):
            owords = oline.split(" ")
            line = ""
            for wordi, word in enumerate(owords):
                #print(f"; DEBUG \"{line}\" ({xlen(line)}) + \"{word}\" = {xlen(line+word)}")
                if xlen(line + word) == LINELEN:
                    line += word
                    lines.append(line)
                    line = ""
                    continue
                elif xlen(line + word) > LINELEN:
                    lines.append(line)
                    line = word
                    if wordi < len(owords)-1:
                        line += " "
                else:
                    line += word
                    if wordi < len(owords)-1:
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
    csvfilestringaddresses = {}
    for filename in filenames:
        if not filename: continue
        if filename.startswith("<"): continue
        filename = filename.lstrip(">")
        with open("text/"+filename+".csv", "r") as f:
            csvfilestringaddresses[filename] = []
            fcsv = csv.reader(f)
            next(fcsv)
            for row in fcsv:
                newstring = None
                new = False
                if len(row) > 8:
                    # Extra columns are probably comments, ignore
                    row = row[:8]
                if len(row) == 7:
                    csvi, address, end, name_i, newlines, name, string = row
                else:
                    csvi, address, end, name_i, newlines, name, string, newstring = row
                if newlines:
                    newlines = json.loads(newlines)
                else:
                    newlines = []
                
                verbose = False
                if "ferry is going" in string.replace("\n", " "):
                    verbose = False
                
                if verbose:
                    print("\n=================")
                    print(string)
                    print("=================\n")
                
                if newstring != None and newstring != "":
                    new = True
                    origstring = string
                    string = newstring
                elif FORCE_NEW:
                    newstring = ""
                    if string.endswith("<ask>"):
                        nl = newlines[-1]
                        if nl == "@": nl = newlines[-2]
                        axis = int(nl[6])
                        hardlines = [-1, -2][axis]
                        newstring = " ".join(string.split("\n")[0:-2])+" "
                        newstring += "\n".join(string.split("\n")[-2:])
                        string = newstring
                    else:
                        string = string.replace("\n", " ")
                    new = True
                #if i != "TRASH":
                #    i = int(i)
                csvi = csvi.replace("-", "_")
                address = int(address, 16)
                end = int(end, 16)
                if name_i:
                    name_i = int(name_i)
                else:
                    name_i = None
                string = dumb_smart_quotes(string)
                string = fixup_string(string)
                csvstring = ""
                if name_i is not None:
                    csvstring += "<name>" + charmap[name_i]
                ask = False
                if string.endswith("<ask>"):
                    nl = newlines[-1]
                    if nl == "@": nl = newlines[-2]
                    axis = int(nl[6])
                    ask = True
                if newlines:
                    if not new:
                        for line, newline in zip(string.split("\n"), newlines):
                            csvstring += line + newline + "\n"
                    else:
                        string = calculate_newlines(string)
                        numlines = len(string.split("\n"))
                        if ask:
                            string = string.split('\n')
                            if axis == 0 and numlines % 2 == 1:
                                string.insert(-1, '')
                                numlines += 1
                            elif axis == 1 and numlines % 2 == 1:
                                string.insert(-2, '')
                                numlines += 1
                            string = '\n'.join(string)
                        if numlines > 1 and len(newlines) < 2:
                            stderr.write(f"WARNING: {address:x} needs an extra newline.  Guessing \\n\n{string}\n")
                            newlines.insert(0, "\\n")
                        for linei, line in enumerate(string.split("\n")):
                            if linei == numlines-1:
                                #print("; last: ", newlines[-1])
                                if "<ask>" in line and axis == 0:
                                    if "  " in line:
                                        splitby = "  "
                                    else:
                                        splitby = " "
                                    questions = [q.strip() for q in line[:-5].strip().split(splitby) if q]
                                    #print(questions)
                                    line = f"<sp8>{questions[0]}<question2><sp8>{questions[1]}"
                                    newline = "<ask>10"+charmap[0x10]+charmap[0x19]+"000@"
                                else:
                                    newline = newlines[-1]
                                
                            else:
                                newline = newlines[linei%2] + "\n"
                            csvstring += line.rstrip(" ")
                            csvstring += newline + "\n"
                else:
                    csvstring = string+"\n"
                csvstring = csvstring[:-1].split("\n")
                csvstrings[address] = csvstring
                csvstringends[address] = end
                if address not in csvstringindexes:
                    csvstringindexes[address] = []
                csvstringindexes[address].append((filename, csvi))
                csvfilestringaddresses[filename].append(address)
    
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
    
    Path.mkdir(Path(f"build/text/"), parents=True, exist_ok=True)
    open(f"build/text/dummy.asm", "w").write("; OK\n")
    
    for metatable in sorted(METATABLES + TABLES, key=lambda t: t[0]):
        metatable_address, count, subtable_names = metatable
        bank = metatable_address//0x4000
        pointer = metatable_address%0x4000+0x4000
        
        metatable_file = open(f"build/text/{bank:02x}_{pointer:04x}.asm", "w")
        metatable_addresses = []
        if type(subtable_names) == str:
            # XXX hack: not a metatable, just a table :)
            metatable_addresses += csvfilestringaddresses[subtable_names]
        else:
            for i, (table_address, table_name) in enumerate(metatables[metatable_address]):
                if table_name and not table_name.startswith("<"):
                    table_name = table_name.lstrip(">")
                    metatable_addresses += csvfilestringaddresses[table_name]
    
        last_address = None
        
        for address in sorted(set(metatable_addresses)):
            if address < -1: continue
            indexes = csvstringindexes[address]
            string = csvstrings[address]
            #print(address, index)
            if last_address != address:
                pass
                #if last_address:
                #    metatable_file.write(f"; {gbswitch(last_address)}\n\n")
                #metatable_file.write("SECTION \"Text at {1:02x}:{0:04x}\", ROMX[${0:04x}], BANK[${1:02x}]\n".format(address%0x4000 + 0x4000, address//0x4000))
            for tname, i in indexes:
                #label = "String{}_{}".format(ih, il)
                label = f"String{tolabel(tname)}_{i}"
                metatable_file.write("{}::\n".format(label))
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
                metatable_file.write(f'\tdb "{outline}"\n')
            last_address = csvstringends[address]
            #print(f"; {gbswitch(last_address)}")
            metatable_file.write("\n")

def print_pointer_tables():
    for metatable in METATABLES:
        metatable_address, count, subtable_names = metatable
        bank = metatable_address//0x4000
        pointer = metatable_address%0x4000+0x4000
        #print("SECTION \"Text pointer metatable at {}\", ROMX[${:04x}], BANK[${:02x}]".format(gbswitch(metatable_address), metatable_address%0x4000 + 0x4000, bank))
    
        table_filename = f"build/text/{bank:02x}_{pointer:04x}_table.asm"
        metatable_file = open(table_filename, "w")
        
        metatable_file.write(f"Metatable{bank:02x}_{pointer:04x}:: ; {gbswitch(metatable_address)}\n")
        last_subtable_name = None
        for i, (subtable_name, subtable_address) in enumerate(zip(subtable_names, metatable_subtable_addresses[metatable_address])):
            subtable_address = subtable_address[0]
            if not subtable_name:
                subtable_name = last_subtable_name
            if subtable_name and not subtable_name.startswith("<"):
                subtable_name = subtable_name.lstrip(">")
                metatable_file.write(f"    dw Table{tolabel(subtable_name)}\t; {gbswitch(subtable_address)}\n")
                last_subtable_name = subtable_name
            else:
                metatable_file.write(f"    dw ${subtable_address%0x4000 + 0x4000:04x}\n")
        
        metatable_file.write("\n")
        last_table_name = None
        for i, (table_address, table_name) in enumerate(metatables[metatable_address]):
            if table_name and table_name != last_table_name and not table_name.startswith("<"):
                if ">" in table_name:
                    table_name = "<"+table_name.lstrip(">")
                metatable_file.write("\n")
                metatable_file.write(f"Table{tolabel(table_name.lstrip('<'))}:: ; {gbswitch(subtable_address)}\n")
            if table_name in tables_by_name:
                for i, address in enumerate(tables_by_name[table_name]):
                    if table_name:
                        assert not table_name.startswith(">")
                        table_name = table_name.lstrip("<")
                        metatable_file.write(f"    dw String{tolabel(table_name)}_{i}\n")
                    else:
                        continue
            last_table_name = table_name

    
    for table in TABLES:
        address, count, name = table
        bank = address // 0x4000
        pointer = address % 0x4000 + 0x4000
        table_filename = f"build/text/{bank:02x}_{pointer:04x}_table.asm"
        table_file = open(table_filename, "w")
        #print(f'SECTION "Text pointer table for {name}", ROMX[${pointer:04x}], BANK[${bank:02x}]')
        table_file.write('\n')
        table_file.write(f"Table{tolabel(name)}:: ; {gbswitch(address)}\n")
        for i, address in enumerate(tables[address]):
            if address > 0:
                table_file.write(f"    dw String{tolabel(name)}_{i}\n")
            else:
                if -address in LABELS:
                    table_file.write(f"    dw {LABELS[-address]}\n")
                else:
                    table_file.write(f"    dw ${-address:04x}\n")
    
        if name == "strings/names":
            table_file.write('; dummy name (TRASH)\n')
            table_file.write('    db "012@"\n')
        #table_file.write('\n')
        #table_file.write(f'INCLUDE "build/text/{bank:02x}_{pointer:04x}.asm"\n')
        table_file.write('\n')

def print_sections():
    print()
    print('INCLUDE "build/text/dummy.asm"')
    print()
    for metatable in sorted(METATABLES + TABLES, key=lambda t: t[0]):
        metatable_address, count, subtable_names = metatable
        bank = metatable_address//0x4000
        pointer = metatable_address%0x4000+0x4000
        meta = type(subtable_names) is not str
        print("SECTION \"Text pointer {}table at {}\", ROMX[${:04x}], BANK[${:02x}]".format("meta" if meta else "",gbswitch(metatable_address), metatable_address%0x4000 + 0x4000, bank))
        if meta:
            print("; covers: {}".format(", ".join(str(n) for n in subtable_names)))
        else:
            print("; is {}".format(subtable_names))
        print(f'    INCLUDE "build/text/{bank:02x}_{pointer:04x}_table.asm"')
        print(f'    INCLUDE "build/text/{bank:02x}_{pointer:04x}.asm"')
        print(f'TextSection{bank:02x}_{pointer:04x}_END:')
        print()

if __name__ == "__main__":
    # comment/uncomment whichever you want

    #pprint(dict(enumerate(strings)))
    #strings_to_csv()
    if argv[1] == "csv":
        strings_to_csv()
    elif argv[1] == "asm_from_csv":
        print_strings_from_csvs()
    elif argv[1] == "pointer_tables":
        #print("; Warning: This was a one-off and was later corrected by hand.")
        print_pointer_tables()
    elif argv[1] == "sections":
        print_sections()
    else:
        print("?")
        exit(1)
    #print_pointer_table()
