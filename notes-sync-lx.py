import os
import subprocess
import runpy

notes_dir = os.path.expanduser('~/notes')
os.chdir(notes_dir)

subprocess.run(['git', 'add', '.'], check=True)

try:
    result = subprocess.run(['git', 'commit', '-m', 'u'], 
                            check=True,
                            capture_output=True,
                            text=True)
except subprocess.CalledProcessError as e:
    if 'git rebase --continue' in e.stdout:
        subprocess.run("git rebase --continue", shell=True, check=True)

    # if there is an error, but stdout didn't say to continue rebase, 
    # then there's a different error that requires investigation
    elif e.stderr:
        print("ERROR: git threw error that git rebase --continue did not fix. Investigate")

# Run git pull (ignore errors)
subprocess.run(['git', 'pull'], check=False)

# Run git push
subprocess.run(['git', 'push'], check=True)

runpy.run_path(path_name=os.path.expanduser("~/code/notes-scripts/upload-zk-attachments.py"))