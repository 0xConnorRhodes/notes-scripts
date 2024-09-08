import os
import subprocess
import runpy

def check_and_clone():
    notes_path = os.path.expanduser('~/notes')
    
    # Check if the folder exists
    if not os.path.exists(notes_path):
        print(f"Folder {notes_path} does not exist. Cloning repository...")
        
        # Clone the repository into the specified folder
        clone_command = ['git', 'clone', 'git@github.com:0xConnorRhodes/notes-snapshot.git', notes_path]
        
        try:
            subprocess.run(clone_command, check=True)
            print("Repository cloned successfully.")
        except subprocess.CalledProcessError as e:
            print(f"An error occurred while cloning the repository: {e}")
    else:
        print(f"Folder {notes_path} already exists. Syncing changes...")
        runpy.run_path(path_name=os.path.expanduser("~/code/notes-scripts/notes-sync-lx.py"))


if __name__ == "__main__":
    check_and_clone()
