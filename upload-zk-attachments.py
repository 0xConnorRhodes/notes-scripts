#!/usr/bin/env python

import os
import glob
import subprocess

notes_dir = os.path.expanduser('~/notes')

attachment_exts = [
    'png',
    'jpg'
]

attachment_files = []
for ext in attachment_exts:
    files = glob.glob(os.path.join(notes_dir, f"*.{ext}"))
    attachment_files.extend(files)

print(attachment_files)