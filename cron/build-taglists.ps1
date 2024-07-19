#!/usr/bin/env pwsh

$notesDir = "$HOME/notes"

function buildFileList {
    param ([string]$Query)

    $command = "rg -l '$Query' $NotesDir"
    $files = Invoke-Expression $command
    # $files = buildFileList -Query '#vaccounts' -NotesFolder $notesDir

    # $listName = 

    # $outputFilePath = Join-Path -Path $NotesFolder -ChildPath '.' + 

    foreach ($file in $files) {
        # Add-Content -Path $outputFilePath
        Write-Host $file
    }
}

buildFileList -Query '#vaccounts'