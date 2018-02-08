#!/usr/bin/python3

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
        system(f"ssconvert {filename} {csvfilename}")
        system(f"rm {filename}")

