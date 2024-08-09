import os
import subprocess
from datetime import datetime

notes_dir = os.path.expanduser('~/notes')
today = datetime.today()
formatted_date = int(today.strftime('%y%m%d'))

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
                if start_date_int <= formatted_date:
                    relevant_tasks.append(file)

for task in relevant_tasks:
    print_task = os.path.basename(task)
    print_task = os.path.splitext(print_task)[0]
    print(print_task)

# TODO: add print tasks in order of start date
# TODO: add printing a table of task name, start date
# TODO: add filter tasks by tag. fzf prompt, default to all, and support selecting one or multiple tasks instead