#region config
import os
import socket
from pyfzf.pyfzf import FzfPrompt
fzf = FzfPrompt()

notes_dir = os.path.expanduser('~/notes')

hostname = socket.gethostname()
termux_test = os.getenv('TERMUX_APP_PID')

if hostname == 'devct':
    platform = 'linux'
elif int(termux_test) > 0:
    platform = 'android'
#endregion

#region functions
def split_task_sections(task_string):
    """
    split the input string into component parts
    """
    task_string = task_string.strip()
    task_name = task_string
    return task_name
#endregion

task_input = input('task: ')

if not task_input:
    print('no task')
    exit(0)

task_name = split_task_sections(task_input) # TODO: add, new, vars as you update split_task_sections()

filename = f"tk_{task_name}.md"
file = open(os.path.join(notes_dir, filename), 'w')
file.close()

# TODO: open task in nvim with `Gi` if devct else termux-open the note after creation