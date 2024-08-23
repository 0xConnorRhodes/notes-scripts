#region config
import os
import socket
import subprocess
from jinja2 import Environment, FileSystemLoader
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

with open(save_file_path, 'w') as file:
    pass

if platform == 'linux':
    subprocess.run(f'nvim +startinsert "{save_file_path}"', shell=True)
elif platform == 'android':
    subprocess.run(f'termux-open "{save_file_path}"', shell=True)