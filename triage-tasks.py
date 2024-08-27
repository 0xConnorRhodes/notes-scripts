# region config
import os
from pyfzf.pyfzf import FzfPrompt
fzf = FzfPrompt()
notes_dir = os.path.expanduser("~/notes")
# endregion

# Get all files in the notes directory (not including subdirectories)
files = [f for f in os.listdir(notes_dir) if os.path.isfile(os.path.join(notes_dir, f))]
tk_files = [f for f in files if f.startswith("tk_")]

selected = fzf.prompt(tk_files, '--multi')

if selected:
    print("You selected:")
    for file in selected:
        print(f"{file}")