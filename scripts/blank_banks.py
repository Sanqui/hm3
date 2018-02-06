#!/usr/bin/python3

with open("baserom.gbc", "rb") as rom:
    bank = 0
    for i in range(128):
        bank = rom.read(0x4000)
        zeroes = bank.count(b'\x00')
        print(f"{i:02x}: {zeroes:04x}/4000 ({zeroes/0x4000 * 100: .4} %)")
