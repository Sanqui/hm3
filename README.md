# hm3 - Partial disassembly of Harvest Moon 3

This repository contains a partial disassembly of the Game Boy Color game
Harvest Moon 3, developed by Victor Interactive Software in 2000.

It doesn't aim to be a complete source code recreation, rather it contains
just enough scaffolding to be useful for translation projects.

An in progress German translation can be found on the `de` branch.  It implements
a variable width font and some quality of life improvements, like a more compact
select button HUD.

## Requirements
- [rgbds](https://github.com/gbdev/rgbds)
- Make
- Python
- gnumeric (for translations: to convert xmlx to csv)

## Building
Run `make` in the project directory.

## German translation
Spreadsheets: https://drive.google.com/drive/u/0/folders/1TAwKo0dKmtkyIg4WhzVG0k2ilgexZqad

The script [tools/sync_text.py](tools/sync_text.py) converts a .zip of these spreadsheets
into CSV files which `make` can build into the game.