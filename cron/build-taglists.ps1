#!/usr/bin/env pwsh

$notesDir = "$HOME/notes"

function buildFileList {
    param ([string]$Query)

    $command = "rg -l '$Query' $NotesDir"
    $files = Invoke-Expression $command

    foreach ($file in $files) {
        # Add-Content -Path $outputFilePath
        Write-Host $file
    }
}

buildFileList -Query '#vaccounts'