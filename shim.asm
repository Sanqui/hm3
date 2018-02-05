SECTION "Shim for JumpTable", ROM0[$0]
JumpTable::


SECTION "Shim for JumpTable_", ROM0[$98c]
JumpTable_::


SECTION "Shim for AddHL_A", ROM0[$38]
AddHL_A::


SECTION "Shim for VBlankInt", ROM0[$40]
VBlankInt::


SECTION "Shim for VBlank", ROM0[$4a0]
VBlank::


SECTION "Shim for LCDInt", ROM0[$48]
LCDInt::


SECTION "Shim for SerialInt", ROM0[$58]
SerialInt::


SECTION "Shim for Start", ROM0[$100]
Start::


SECTION "Shim for PrintStringID", ROMX[$41ba], BANK[$79]
PrintStringID::


SECTION "Shim for PrintString", ROMX[$43b5], BANK[$79]
PrintString::


SECTION "Shim for PrintString.next", ROMX[$43c1], BANK[$79]
PrintString.next::


SECTION "Shim for StringIDToPointer", ROMX[$4477], BANK[$79]
StringIDToPointer::


SECTION "Shim for StringPointerTable", ROMX[$44a0], BANK[$79]
StringPointerTable::


SECTION "Shim for GetPointer", ROMX[$404a], BANK[$79]
GetPointer::


SECTION "Shim for TileNumToPointer", ROMX[$40a4], BANK[$79]
TileNumToPointer::


SECTION "Shim for StringID", WRAM0[$c526]
StringID::


