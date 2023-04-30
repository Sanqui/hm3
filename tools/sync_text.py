#!/usr/bin/python3

# Requires: gnumeric (for ssconvert)
# Steps:
# 1. Download ZIP of https://drive.google.com/drive/u/0/folders/1TAwKo0dKmtkyIg4WhzVG0k2ilgexZqad in this directory
# 2. Run python tools/sync_text.py <filename.zip>

from os import system
from sys import argv
from glob import glob
from tqdm import tqdm

zipfilename = argv[1]

system(f"rm -rf text")
system(f'unzip "{zipfilename}"')
system(f'mv "Harvest Moon 3 DE" text')

files = list(glob("text/**", recursive=True))

for filename in tqdm(files):
    if filename.endswith(".xlsx"):
        csvfilename = filename[:-5]
        if not csvfilename.endswith(".csv"):
            csvfilename += ".csv"
        system(f"ssconvert {filename} {csvfilename}")
        system(f"rm {filename}")

