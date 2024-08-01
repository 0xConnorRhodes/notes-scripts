import os
import subprocess

notes_dir = os.path.expanduser('~/notes')
os.chdir(notes_dir)

subprocess.run(['git', 'add', '.'], check=True)

# Run git commit -m 'u'
subprocess.run(['git', 'commit', '-m', 'u'], check=True)

# Run git pull
subprocess.run(['git', 'pull'], check=True)

# Run git push
subprocess.run(['git', 'push'], check=True)