#!/usr/bin/env fish

cd ~/notes
set note (fd -e md --exclude _tk --exclude df --exclude b . | fzf)

nvim $note
