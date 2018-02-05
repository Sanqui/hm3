#!/bin/python3
from sys import argv

def gbaddr(arg):
    if ":" in arg:
        bank, pointer = arg.split(":")
        bank = int(bank, 16)
        pointer = int(pointer, 16)
        address = None
        if bank == 0 and pointer < 0x4000:
            address = pointer
        elif 0x4000 <= pointer < 0x8000:
            address = bank * 0x4000 + pointer - 0x4000
        else:
            print("ERR", end=" ")
        
        return address
        if address:
            print(f"{address:x}", end=" ")
            
    else:
        address = int(arg, 16)
        return address
    
def gbswitch(arg):
    if ":" in arg:
        address = gbadr(arg)
        return f"{address:x}"
    else:
        bank = address//0x4000
        
        if bank > 0:
            pointer = address%0x4000 + 0x4000
        else:
            pointer = address
        
        return f"{bank:02x}:{pointer:04x}"

if __name__=="__main__":
    for arg in argv[1:]:
        string = arg
        print(f"{string}", end=" ")

    print()
