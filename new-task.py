#region config
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
#endregion

#region functions
def split_task_sections(task_string):
    """
    split the input string into component parts
    """
    task_info_dict = {
        "task_name": None,
        "start_date": False,
        "due_date": False,
        "tag_list": []
    }

    task_string = task_string.strip()

    indices = {
        "task_name": 0,
        "start_date": task_string.find(' s '),
        "due_date": task_string.find(' d '),
        "tag_list": task_string.find(' t ')
    }

    present_indices = {key: value for key, value in indices.items() if value != -1}
    sorted_indices = sorted(present_indices.items(), key=lambda item: item[1])

    si_length = len(sorted_indices)
    for i in range(si_length):
        attribute_name = sorted_indices[i][0]
        start_index = sorted_indices[i][1]
        if i == si_length-1:
            end_index = len(task_string)
        else:
            end_index = sorted_indices[i+1][1]

        task_info_dict[attribute_name] = task_string[start_index:end_index]
    
    if task_info_dict['start_date']:
        task_info_dict['start_date'] = task_info_dict['start_date'].replace(' s ', '')
    if task_info_dict['due_date']:
        task_info_dict['due_date'] = task_info_dict['due_date'].replace(' d ', '')
    if task_info_dict['tag_list']:
        task_info_dict['tag_list'] = task_info_dict['tag_list'].replace(' t ', '').split()
    
    return task_info_dict
#endregion

task_input = input('task: ')

if not task_input:
    print('no task')
    exit(0)

task_info = split_task_sections(task_input) # TODO: add, new, vars as you update split_task_sections()

print(task_info)

exit(0)

filename = f"tk_{task_name}.md"
task_file_path = os.path.join(notes_dir, filename)

file = open(task_file_path, 'w')
file.close()

if platform == 'linux':
    subprocess.run(f'nvim -c "startinsert" "{task_file_path}"', shell=True)
elif platform == 'android':
    subprocess.run(f'termux-open "{task_file_path}"', shell=True)