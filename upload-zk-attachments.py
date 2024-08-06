#!/usr/bin/env python3

#region config
import os
import subprocess
import sys
import re
import socket

hostname = socket.gethostname()
termux_test = os.getenv('TERMUX_APP_PID')

if hostname == 'devct':
    platform = 'linux'
elif int(termux_test) > 0:
    platform = 'android'

if platform == 'linux':
    WhatIf = False
else:
    WhatIf = True

# WhatIf = False
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
remove_chars = [ '(', ')']
#endregion

#region helper functions
def generate_filename_data(file_path, replace_chars_list, remove_chars_list):
    file_basename = os.path.basename(file_path)
    parent_folder = os.path.dirname(file_path)

    file_name_no_ext, extension = file_basename.rsplit('.', 1)

    new_filename = file_name_no_ext.lower()

    for char in remove_chars_list:
        new_filename = new_filename.replace(char, '')

    for char in replace_chars_list:
        new_filename = new_filename.replace(char, '-')
    new_filename += f".{extension}"

    return file_basename, new_filename, extension, file_name_no_ext, parent_folder

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

def get_local_link_format(file, file_basename, escape_chars, running_platform):
    for char in escape_chars:
        file_basename = file_basename.replace(char, f'\\{char}')
    if running_platform == 'linux':
        pattern = r'\!\[\[.*?' + file_basename + r'\]\]'
    elif running_platform == 'android':
        print('running on android. WIP')
    else:
        print('hostname not accounted for in script')
        exit(1)
    with open(file, 'r') as f:
        filedata = f.read()
        matches = re.findall(pattern, filedata)
        matches = list(set(matches))
        if len(matches) > 1:
            print(f'Error: multiple competing links for {file_basename} present in {parent_file}')
            sys.exit(1)
        matches = matches[0]
        return matches

def check_file_dup(folder, file_name, extension, file_list):
    basename_numbered_as_duplicate = bool(re.search(r' \d$', file_name))
    if basename_numbered_as_duplicate:
        last_space_index = file_name.rfind(' ')
        original_file = file_name[:last_space_index]
        original_filename = f"{original_file}.{extension}"
        original_file_path = os.path.join(folder, original_filename)
        if original_file_path in file_list:
            print(f'Duplicate File: {file_name}')
            return True, original_filename
        else:
            return False, False
    else:
        return False, False

def replace_attachment_link(note_file, existing_link, new_link, whatif):
    """
    takes a list of files, the format of existing links, and the new link format (to the file on the server)
    replaces existing link with new link in listed files
    """
    with open(note_file, 'r') as file:
        filedata = file.read()

    filedata = filedata.replace(existing_link, new_link)

    if whatif:
        print(f'Test Mode:\nWould replace {existing_link} with {new_link} in {note_file}')
        print(f'{filedata=}')
    else:
        with open(note_file, 'w') as file:
            file.write(filedata)
        print(f"Modified: {note_file}")
#endregion

attachments_present = False
attachment_files = find_attachment_files(notes_dir, attachment_exts)

if len(attachment_files) > 0:
    attachments_present = True

for file in attachment_files:
    attachment_basename, new_filename, extension, file_name_no_ext, parent_folder = generate_filename_data(file, replace_chars, remove_chars)
    
    file_dup, original_attachment_filename = check_file_dup(parent_folder, file_name_no_ext, extension, attachment_files)
    if file_dup:
        new_file = os.path.join(parent_folder, original_attachment_filename)
        _, new_filename, _, _, _= generate_filename_data(new_file, replace_chars, remove_chars)
        os.remove(file)

    files_with_link = get_files_with_link(attachment_basename, notes_dir)

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

    if not file_dup:
        rsync_file(
            local_file=file,
            remote_path=server_path,
            remote_filename=new_filename,
            link_to_remote_file=embed_link,
            whatif=WhatIf
        )

    for parent_file in files_with_link:
        local_link = get_local_link_format(parent_file, attachment_basename, remove_chars, platform)
        replace_attachment_link(parent_file, local_link, embed_link, whatif=WhatIf)

if not attachments_present:
    print(f'No attachments to upload')
