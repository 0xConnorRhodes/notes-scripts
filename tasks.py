import os
import subprocess
from pyfzf.pyfzf import FzfPrompt

fzf = FzfPrompt()

scripts_dir = os.path.expanduser('~/code/notes-scripts')

options = {
    "new task": f"python3 {scripts_dir}/new-task.py",
    "list tasks": f"python3 {scripts_dir}/list-tasks.py",
    "done task": f"lua5.4 {scripts_dir}/modify-task.lua done",
    "drop task": f"lua5.4 {scripts_dir}/modify-task.lua drop",
    "hold task": f"lua5.4 {scripts_dir}/modify-task.lua hold",
    # "review tasks": f"lua {scripts_dir}/review-tasks.lua",
    "undone tasks": f"lua5.4 {scripts_dir}/modify-task.lua undone",
    "undrop tasks": f"lua5.4 {scripts_dir}/modify-task.lua undrop",
    "unhold tasks": f"lua5.4 {scripts_dir}/modify-task.lua unhold"
}

choice = fzf.prompt(options.keys())[0]

subprocess.run(options[choice], shell=True)