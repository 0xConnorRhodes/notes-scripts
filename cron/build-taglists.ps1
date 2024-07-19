#!/usr/bin/env pwsh

$notesDir = "$HOME/notes"

function buildFileList {
    param ([string]$Query)

    $command = "rg -l '#$Query' $NotesDir"
    $files = Invoke-Expression $command
    
    $accountNames = @()
    foreach ($file in $files) {
        $file = $file -replace '.*/', ''
        $file = $file -replace '\.md$', ''
        $accountNames += $file
    }

    foreach ($name in $accountNames) {
        Write-Host $name
    }
}

buildFileList -Query 'vaccounts'