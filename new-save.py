#region config
import os
import socket
import subprocess
from pyfzf.pyfzf import FzfPrompt
fzf = FzfPrompt()

notes_dir = os.path.expanduser('~/notes')
save_dir = os.path.join(notes_dir, 's')

hostname = socket.gethostname()
termux_test = os.getenv('TERMUX_APP_PID')

if hostname == 'devct':
    platform = 'linux'
elif int(termux_test) > 0:
    platform = 'android'
#endregion

save_name = input('Name: ')
save_file_name = save_name + '.md'

if not save_name:
    print('no name specified')
    exit(0)

save_file_path = os.path.join(save_dir, save_file_name)

if platform == 'linux':
    with open(save_file_path, 'w') as file:
        pass
    subprocess.run(f'nvim +startinsert "{save_file_path}"', shell=True)
elif platform == 'android':
    save_link = subprocess.run(f'termux-clipboard-get', shell=True, capture_output=True, text=True).stdout

    with open(save_file_path, 'w') as file:
        file.write(save_link + '\n\n')

    subprocess.run(f'termux-open "{save_file_path}"', shell=True)
