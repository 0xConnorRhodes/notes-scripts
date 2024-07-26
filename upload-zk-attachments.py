#!/usr/bin/env python3

#region config
import os
import glob
import subprocess
import sys

notes_dir = os.path.expanduser('~/notes')
nats_bucket = 'https://sfs.connorrhodes.com/nats'
server_path = 's:/zstore/static_files/nats'

with open(os.path.expanduser('~/code/notes-scripts/templates/.sfs-nats-token'), 'r') as file:
    access_token = file.read().strip()

attachment_exts = [
    #'png',
    'jpg'
]

replace_chars = [' ', ' ', '.']
#endregion

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

    new_filename = local_filename.lower()
    for char in replace_chars:
        new_filename = new_filename.replace(char, '-')

    new_filename += f".{extension}"

    upload_path = f"{server_path}/{new_filename}"

    rsync_test_cmd = f'rsync -q --dry-run "{upload_path}" > /dev/null 2>&1'

    rsync_test = subprocess.run(rsync_test_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    if rsync_test.returncode == 0:
        print(f'file {new_filename} already exists on server')
        print(f"Check that {local_file} is safe to delete")
        # TODO: generate and print link here as well, perhaps factor into function?
        sys.exit(1)

    rsync_upload_cmd = f'rsync --remove-sent-files "{file}" "{upload_path}"'
    rsync_upload_result = subprocess.run(rsync_upload_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    if rsync_upload_result.returncode == 1:
        print('Error uploading file, exiting')
        print(rsync_upload_result.returncode)
        sys.exit(1)
    else:
        print(f"Uploaded {new_filename}")

    embed_link = f"![]({nats_bucket}/{new_filename}?{access_token})"

    for note_file in parent_files:
        with open(note_file, 'r') as file:
            filedata = file.read()
            
        filedata = filedata.replace(local_file_link, embed_link)

        with open(note_file, 'w') as file:
            file.write(filedata)

        print(f"Modified: {note_file}")
