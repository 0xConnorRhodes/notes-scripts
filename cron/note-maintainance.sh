#!/run/current-system/sw/bin/bash

PYEXEC=/home/connor/code/notes-scripts/.pyenv/bin/python3

echo "**Updating Notes**"
$PYEXEC /home/connor/code/notes-scripts/cron/update-notes.py

echo ''
echo "**Create Daily Note**"
$PYEXEC /home/connor/code/notes-scripts/cron/create_daily_note.py

echo ''
echo "**Sync Notes**"
$PYEXEC /home/connor/code/notes-scripts/notes-sync-lx.py

echo ''
echo "**Create Daily Food Log**"
ruby /home/connor/code/food-log/create_md_logfile.rb
