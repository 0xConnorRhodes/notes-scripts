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
def generate_filename(file_path, chars_list):
    file_basename = os.path.basename(file_path)

    file_name, extension = file_basename.rsplit('.', 1)

    new_filename = file_name.lower()
    for char in chars_list:
        new_filename = new_filename.replace(char, '-')
    new_filename += f".{extension}"

    return file_basename, new_filename, extension

def find_attachment_files(folder, ext_list):
    attachment_files = []
    for root, dirs, files in os.walk(folder):
        for file in files:
            if any(file.endswith(ext) for ext in ext_list):
                attachment_files.append(os.path.join(root, file))
    return attachment_files

def rsync_file(local_file, remote_path, remote_filename, link_to_remote_file, whatif):
    upload_path = f"{remote_path}/{remote_filename}"
    rsync_test_cmd = f'rsync -q --dry-run "{upload_path}" > /dev/null 2>&1'
    rsync_test = subprocess.run(rsync_test_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if rsync_test.returncode == 0:
        print(f'file {remote_filename} already exists on server')
        print(f"Check that '{local_file}' is safe to delete")
        print(f"\nLink:\n{link_to_remote_file}")
        sys.exit(1)

    rsync_upload_cmd = f'rsync --remove-sent-files "{local_file}" "{upload_path}"'

    if whatif:
        print(f'Test mode:\n{rsync_upload_cmd}\n')
        pass
    else:
        rsync_upload_result = subprocess.run(rsync_upload_cmd, 
                                             shell=True, 
                                             stdout=subprocess.PIPE, 
                                             stderr=subprocess.PIPE
                                )
        if rsync_upload_result.returncode == 1:
            print('Error uploading file, exiting')
            print(rsync_upload_result.returncode)
            sys.exit(1)
        else:
            print(f"Uploaded {remote_filename}")

def get_files_with_link(file_name, folder):
    rg_command = f"rg -l -F '{file_name}' {folder}"
    result = subprocess.run(rg_command, shell=True, capture_output=True, text=True)
    files_with_link = result.stdout.splitlines()
    return files_with_link

def get_local_link_format(file, file_basename):
    with open(file, 'r') as f:
        filedata = f.read()
        pattern = r'\!\[\[.*?' + file_basename + r'\]\]'
        matches = re.findall(pattern, filedata)
        list(set(matches))
        if len(matches) > 1:
            print(f'Error: multiple competing links for {file_basename} present in {parent_file}')
            sys.exit(1)
        return str(matches)

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
attachment_files = find_attachment_files(notes_dir, attachment_exts)

if len(attachment_files) > 0:
    attachments_present = True

i = 0
for file in attachment_files:
    file_basename, new_filename, extension = generate_filename(file, replace_chars)
    files_with_link = get_files_with_link(file_basename, notes_dir)
    if attachment_filetypes[extension] == 'embed':
        embed_link = f"![]({nats_bucket}/{new_filename}?{access_token})"
    elif attachment_filetypes[extension] == 'link':
        embed_link = f"[{new_filename}]({nats_bucket}/{new_filename}?{access_token})"

    if not files_with_link:
        print(f"attachment: {file} is unused")
        choice = input('Remove file? (y/n): ').lower()
        if choice == 'y':
            os.remove(file)
        continue
    
    rsync_file(
        local_file=file_basename,
        remote_path=server_path,
        remote_filename=new_filename,
        link_to_remote_file=embed_link,
        whatif = True
    )

    for parent_file in files_with_link:
        # TODO: local_link = get_local_link_format(file)
        # TODO: replace_attachment_links()
        pass

    i += 1
    if i > 0: break

if not attachments_present:
    print(f'No attachments to upload')