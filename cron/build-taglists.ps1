#!/usr/bin/env pwsh

$notesDir = "$HOME/notes"

$tagList = @(
    'vaccounts'
)

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

    $accountNames = $accountNames | Sort-Object

    $listFile = Join-Path -Path $notesDir -ChildPath ".$Query.list"

    if (Test-Path $listFile) {
        Remove-Item -Force $listFile
    }

    foreach ($name in $accountNames) {
        Add-Content -Path $listFile -Value $name
    }
}

foreach ($tag in $tagList) {
    buildFileList -Query $tag
}