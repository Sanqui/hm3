.PHONY: all compare clean text

.SUFFIXES:
.SUFFIXES: .asm .o .gbc .png
.SECONDEXPANSION:

ROMS := hm3.gbc
BASEROM := baserom.gbc
OBJS := main.o wram.o build/shim.o

# Link objects together to build a rom.
all: $(ROMS)

tools:
	$(MAKE) -C tools/

define DEP
$1: $2 $$(shell tools/scan_includes $2)
	rgbasm -E -o $$@ $$<
endef

ifeq (,$(filter clean tools,$(MAKECMDGOALS)))
$(info $(shell $(MAKE) -C tools))

$(foreach obj, $(OBJS), $(eval $(call DEP,$(obj),$(obj:.o=.asm))))

endif

build/shim.asm: shim.sym
	python3 tools/make_shim.py $^ > $@

build/charmap.asm: charmap.tbl
	python3 tools/tbl_to_charmap.py $^ > $@

build/text/dummy.asm: build/charmap.asm $(wildcard text/*.csv) scripts/text.py
	python3 scripts/text.py asm_from_csv
	python3 scripts/text.py pointer_tables

$(ROMS): $(OBJS)
	rgblink -n $(ROMS:.gbc=.sym) -m $(ROMS:.gbc=.map) -O $(BASEROM) -o $@ $^
	rgbfix -v -C -i BWAE -k E9 -l 0x33 -m 0x1B -p 0 -r 3 -t "H-MOON3 CGBBWAE" $@

compare: $(ROMS) $(BASEROM)
	cmp $^

# Remove files generated by the build process.
clean:
	rm -rf $(ROMS) $(OBJS) $(ROMS:.gbc=.sym) build/*
	find . \( -iname '*.1bpp' -o -iname '*.2bpp' -o -iname '*.pcm' \) -exec rm {} +

%.2bpp: %.png
	rgbgfx -o $@ $<

%.1bpp: %.png
	rgbgfx -d1 -o $@ $<

%.tilemap: %.png
	rgbgfx -t $@ $<
%.gbcpal: %.png
	rgbgfx -p $@ $<
