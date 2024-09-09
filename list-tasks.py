#region Config
import os
import subprocess
from datetime import datetime

from pyfzf.pyfzf import FzfPrompt
fzf = FzfPrompt()

notes_dir = os.path.expanduser('~/notes')
#endregion

#region Functions
def get_start_date_tasks():
    command = f'rg -d 1 -l "start_date: " {notes_dir}/tk_*'

    files_with_due_date_str = subprocess.run(command, shell=True, capture_output=True, text=True)
    files_with_due_date_lst = files_with_due_date_str.stdout.splitlines()

    relevant_tasks = []
    for file in files_with_due_date_lst:
        with open(file, 'r') as f:
            for line in f:
                if 'start_date: ' in line:
                    start_date_str = (line.split('start_date: ')[1]
                                      .strip()
                                      .replace('"', '')
                                      .replace("'", ""))

                    start_date_int = int(start_date_str)
                    if start_date_int <= today_fmt:
                        relevant_tasks.append(file)

        files_with_due_date_str = subprocess.run(command, shell=True, capture_output=True, text=True)
        files_with_due_date_lst = files_with_due_date_str.stdout.splitlines()

    return relevant_tasks

def get_due_tasks():
    command = f'rg -d 1 -l "due_date: " {notes_dir}/tk_*'

    files_with_due_date_str = subprocess.run(command, shell=True, capture_output=True, text=True)
    files_with_due_date_lst = files_with_due_date_str.stdout.splitlines()

    relevant_tasks = []
    for file in files_with_due_date_lst:
        with open(file, 'r') as f:
            for line in f:
                if 'due_date: ' in line:
                    start_date_str = (line.split('due_date: ')[1]
                                      .strip()
                                      .replace('"', '')
                                      .replace("'", ""))

                    start_date_int = int(start_date_str)
                    if start_date_int == today_fmt:
                        relevant_tasks.append(file)

        files_with_due_date_str = subprocess.run(command, shell=True, capture_output=True, text=True)
        files_with_due_date_lst = files_with_due_date_str.stdout.splitlines()

    return relevant_tasks

def get_past_due_tasks():
    command = f'rg -d 1 -l "due_date: " {notes_dir}/tk_*'

    files_with_due_date_str = subprocess.run(command, shell=True, capture_output=True, text=True)
    files_with_due_date_lst = files_with_due_date_str.stdout.splitlines()

    relevant_tasks = []
    for file in files_with_due_date_lst:
        with open(file, 'r') as f:
            for line in f:
                if 'due_date: ' in line:
                    start_date_str = (line.split('due_date: ')[1]
                                      .strip()
                                      .replace('"', '')
                                      .replace("'", ""))

                    start_date_int = int(start_date_str)
                    if start_date_int < today_fmt:
                        relevant_tasks.append(file)

        files_with_due_date_str = subprocess.run(command, shell=True, capture_output=True, text=True)
        files_with_due_date_lst = files_with_due_date_str.stdout.splitlines()

    return relevant_tasks

def get_next_due_tasks():
    command = f'rg -d 1 -l "due_date: " {notes_dir}/tk_*'

    files_with_due_date_str = subprocess.run(command, shell=True, capture_output=True, text=True)
    files_with_due_date_lst = files_with_due_date_str.stdout.splitlines()

    relevant_tasks = []
    for file in files_with_due_date_lst:
        with open(file, 'r') as f:
            start_date_present = False
            due_date_present = False
            for line in f:
                if 'start_date: ' in line:
                    start_date_str = (line.split('start_date: ')[1]
                                      .strip()
                                      .replace('"', '')
                                      .replace("'", ""))

                    start_date_int = int(start_date_str)
                    start_date_present = True

                if 'due_date: ' in line:
                    due_date_str = (line.split('due_date: ')[1]
                                      .strip()
                                      .replace('"', '')
                                      .replace("'", ""))

                    due_date_int = int(due_date_str)

            if start_date_present:
                if start_date_int > today_fmt:
                    continue
            elif due_date_int > today_fmt and due_date_int <= today_fmt+3:
                    relevant_tasks.append(file)

                    # if due_date_int > today_fmt and due_date_int <= today_fmt+3:
                    #     relevant_tasks.append(file)

        files_with_due_date_str = subprocess.run(command, shell=True, capture_output=True, text=True)
        files_with_due_date_lst = files_with_due_date_str.stdout.splitlines()

    return relevant_tasks
#endregion

today = datetime.today()
today_fmt = int(today.strftime('%y%m%d'))

past_due_tasks = get_past_due_tasks()
due_date_tasks = get_due_tasks()
next_due_tasks = get_next_due_tasks()

start_date_tasks = [ 
    t for t in get_start_date_tasks() 
    if t not in past_due_tasks 
    and t not in due_date_tasks 
    and t not in next_due_tasks
]

output = []

# def add_output(task_type, task_type_list):
#     output.append(task_type)
#     for task in task_type_list:
#         print_task = os.path.basename(task)
#         print_task = os.path.splitext(print_task)[0]
#         print_task = print_task.replace('tk_', '- ')
#         output.append(print_task)

def add_output(task_type, task_type_list):
    output.append(task_type)
    for task in task_type_list:
        print_task = os.path.basename(task)
        print_task = os.path.splitext(print_task)[0]
        print_task = print_task.replace('tk_', '_')
        output.append(print_task)

if past_due_tasks:
    add_output('Past Due Tasks:', past_due_tasks)
if due_date_tasks:
    add_output('Due Tasks:', due_date_tasks)
if start_date_tasks:
    add_output('Start Tasks:', start_date_tasks)
if next_due_tasks:
    add_output('Due Soon:', next_due_tasks)

fzf_prev_cmd = "--preview='bat ~/notes/tk{}.md --color=always --style=plain -l markdown'"

output.reverse()
output.append('q')

while True:
    choice = fzf.prompt(output, f"--multi {fzf_prev_cmd}")
    if 'q' in choice: exit()

    if len(choice) == 1:
        file = f"{notes_dir}/tk{choice[0]}.md"
        subprocess.run(f'nvim "{file}"', shell=True)

# TODO: add print tasks in order of start date
# TODO: add printing a table of task name, start date
# TODO: add filter tasks by tag. fzf prompt, default to all, and support selecting one or multiple tasks instead