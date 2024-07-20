#!/bin/sh
# notes sync with git

set -e

cd ~/notes

git add .

git commit -m 'u'

git pull

git push
