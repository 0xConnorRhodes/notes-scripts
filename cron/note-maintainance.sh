#!/run/current-system/sw/bin/bash

echo "**Updating Notes**"
python3 /home/connor/code/notes-scripts/cron/update-notes.py

echo ''
echo "**Create Daily Note**"
/home/connor/code/notes-scripts/.pyenv/bin/python3 create_daily_note.py

echo ''
echo "**Sync Notes**"
python3 /home/connor/code/notes-scripts/notes-sync-lx.py
