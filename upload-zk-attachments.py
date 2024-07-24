#!/usr/bin/env python3

import os
import glob
import subprocess

notes_dir = os.path.expanduser('~/notes')
nats_bucket = 'https://sfs.connorrhodes.com/nats'

with open(os.path.expanduser('~/code/notes-scripts/templates/.sfs-nats-token'), 'r') as file:
    access_token = file.read().strip()

attachment_exts = [
    #'png',
    'jpg'
]

replace_chars = [' ', ' ', '.']

attachment_files = []
for ext in attachment_exts:
    files = glob.glob(os.path.join(notes_dir, f"*.{ext}"))
    attachment_files.extend(files)

for file in attachment_files:
    local_file = os.path.basename(file)
    local_filename, extension = local_file.rsplit('.', 1)
    local_file_link = f"![[{local_file}]]"
    rg_command = f"rg -l -F '{local_file_link}' {notes_dir}"
    result = subprocess.run(rg_command, shell=True, capture_output=True, text=True)
    parent_files = result.stdout.splitlines()
    parent_files = list(set(parent_files)) # remove duplicates

    new_filename = local_filename
    for char in replace_chars:
        new_filename = new_filename.replace(char, '-')

    new_filename += f".{extension}"

    embed_link = f"![]({nats_bucket}/{new_filename}?{access_token})"

    for note_file in parent_files:
        with open(note_file, 'r') as file:
            filedata = file.read()
            
        filedata = filedata.replace(local_file_link, embed_link)

        with open(note_file, 'w') as file:
            file.write(filedata)

        print(f"Modified: {note_file}")
