#!/bin/sh
# notes sync with git

cd ~/notes

git add .

git commit -m 'u'

git pull

git push

python3 $HOME/code/notes-scripts/upload-zk-attachments.py