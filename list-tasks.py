import os

notes_dir = os.path.expanduser('~/notes')

command = f'rg -l "start_date: " {notes_dir}/tk_*'

# TODO: run command to find all tasks with start date
# TODO: for each of those files, extract the start date, and associate it with the task
# TODO: calculate today's date in YYMMDD format
# TODO: show all tasks with start date >= today's date