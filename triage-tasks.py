# region config
import os
import shutil
from pyfzf.pyfzf import FzfPrompt
fzf = FzfPrompt()
notes_dir = os.path.expanduser("~/notes")
tasks_dir = os.path.join(notes_dir, "_tk")
# endregion

import time
def test_output():
    print('---')
    print(f'performing action **{chosen_action}**')
    print(f'on:')
    for file in selected:
        print(f"  {file}")
    time.sleep(3)


# Get all files in the notes directory (not including subdirectories)
# TODO: as the loop continues, show tk_files - processed files
files = [f for f in os.listdir(notes_dir) if os.path.isfile(os.path.join(notes_dir, f))]
tk_files = [f for f in files if f.startswith("tk_")]
tk_files.insert(0, 'q')
processed_files = []

while len(tk_files) > 0:
    tk_files = [i for i in tk_files if i not in processed_files]

    selected = fzf.prompt(tk_files, '--multi')

    if 'q' in selected:
        break

    actions = [ 'drop', 'hold', 'done', 'skip']
    chosen_action = fzf.prompt(actions)[0]

    match chosen_action:
        case 'drop':
            test_output()
        case 'hold':
            test_output()
        case 'done':
            test_output()
        case 'skip':
            test_output()

    processed_files.extend(selected)

# TODO: add code to move task files to done and drop