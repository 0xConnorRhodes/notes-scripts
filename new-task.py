import os
import socket
import subprocess
from pyfzf.pyfzf import FzfPrompt
fzf = FzfPrompt()

notes_dir = os.path.expanduser('~/notes')

hostname = socket.gethostname()
termux_test = os.getenv('TERMUX_APP_PID')

if hostname == 'devct':
    platform = 'linux'
elif int(termux_test) > 0:
    platform = 'android'

