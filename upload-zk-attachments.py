#!/usr/bin/env python3

#region config
import os
import glob
import subprocess
import sys
import re

notes_dir = os.path.expanduser('~/notes')
nats_bucket = 'https://sfs.connorrhodes.com/nats'
server_path = 's:/zstore/static_files/nats'

with open(os.path.expanduser('~/code/notes-scripts/templates/.sfs-nats-token'), 'r') as file:
    access_token = file.read().strip()

# embed = use an embed format link to uploaded object, link = use a standard format link to uploaded object
attachment_filetypes = {
    'png': 'embed',
    'jpg': 'embed',
    'pdf': 'link'
}
attachment_exts = list(attachment_filetypes)

zattachments_dir = os.path.join(notes_dir, 'zattachments')
attachment_dirs = [notes_dir, zattachments_dir]

replace_chars = [' ', ' ', '.']
#endregion

#region helper functions
def generate_new_filename(filename):
    new_filename = filename.lower()
    for char in replace_chars:
        new_filename = new_filename.replace(char, '-')
    new_filename += f".{extension}"
    return new_filename

def find_attachment_files(folder):
    attachment_files = []
    for ext in attachment_exts:
        files = glob.glob(os.path.join(folder, f"*.{ext}"))
        attachment_files.extend(files)
    return attachment_files

def replace_attachment_links(files_list, existing_link, new_link):
    """
    takes a list of files, the format of existing links, and the new link format (to the file on the server)
    replaces existing link with new link in listed files
    """
    for note_file in files_list:
        with open(note_file, 'r') as file:
            filedata = file.read()

        filedata = filedata.replace(existing_link, new_link)

        with open(note_file, 'w') as file:
            file.write(filedata)

        print(f"Modified: {note_file}")
#endregion

attachments_present = False

for dir in attachment_dirs:
    attachment_files = find_attachment_files(dir)
    if len(attachment_files) > 0:
        attachments_present = True

    for file in attachment_files:
        local_file = os.path.basename(file)
        local_filename, extension = local_file.rsplit('.', 1)
        if 'zattachments' in file:
            local_file_link = f"![[zattachments/{local_file}]]"
        else:
            local_file_link = f"![[{local_file}]]"
        rg_command = f"rg -l -F '{local_file_link}' {notes_dir}"
        result = subprocess.run(rg_command, shell=True, capture_output=True, text=True)
        parent_files = result.stdout.splitlines()

        if not parent_files:
            print(f"attachment: {file} is unused")
            choice = input('Remove file? (y/n): ').lower()
            if choice == 'y':
                os.remove(file)
            continue
        parent_files = list(set(parent_files)) # remove duplicates

        new_filename = generate_new_filename(local_filename)
        upload_path = f"{server_path}/{new_filename}"

        if attachment_filetypes[extension] == 'embed':
            embed_link = f"![]({nats_bucket}/{new_filename}?{access_token})"
        elif attachment_filetypes[extension] == 'link':
            embed_link = f"[{new_filename}]({nats_bucket}/{new_filename}?{access_token})"

        basename_numbered_as_duplicate = bool(re.search(r' \d$', local_filename))
        if basename_numbered_as_duplicate:
            last_space_index = local_filename.rfind(' ')
            original_file = local_filename[:last_space_index]
            original_filename = f"{original_file}.{extension}"
            attachment_filenames = [os.path.basename(path) for path in attachment_files]

            if original_filename in attachment_filenames:
                print(f"{local_file} is a duplicate attachment. Removing.")

                os.remove(file)

                new_filename = generate_new_filename(original_file)

                embed_link = f"![]({nats_bucket}/{new_filename}?{access_token})"

        rsync_test_cmd = f'rsync -q --dry-run "{upload_path}" > /dev/null 2>&1'
        rsync_test = subprocess.run(rsync_test_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if rsync_test.returncode == 0:
            print(f'file {new_filename} already exists on server')
            print(f"Check that '{local_file}' is safe to delete")
            print(f"\nLink:\n{embed_link}")
            sys.exit(1)

        rsync_upload_cmd = f'rsync --remove-sent-files "{file}" "{upload_path}"'
        rsync_upload_result = subprocess.run(rsync_upload_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if rsync_upload_result.returncode == 1:
            print('Error uploading file, exiting')
            print(rsync_upload_result.returncode)
            sys.exit(1)
        else:
            print(f"Uploaded {new_filename}")

        replace_attachment_links(parent_files, local_file_link, embed_link)

if not attachments_present:
    print(f'No attachments to upload')