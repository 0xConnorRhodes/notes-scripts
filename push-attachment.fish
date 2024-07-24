#!/usr/bin/env fish

set natsbucket '![](https://sfs.connorrhodes.com/nats'

for file in $argv
    echo "Name for $file:"
    set extension (string match -r '\.[^.]*$' -- $file)
    read newname
    set newname (string trim -r "$newname") # trim trailing spaces
    set newname (string lower $newname) # lowercase
    set newname (echo $newname | sed 's/  / /g') # consolidate repeat spaces
    set newname (echo $newname | sed 's/ /-/g') # replace spaces with -
    set newname "$newname$extension"
    rsync "$file" "s:/zstore/static_files/nats/$newname"
    echo "$natsbucket/$newname?$NATSKEY)" 
end