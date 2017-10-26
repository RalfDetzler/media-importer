[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$file
)

############################################################
# Handles MarkDeleted in Context Menu of Windows Explorer.
#
# The file is inserted in the marked-for-deletion.csv file
# and moved to the MarkDeleted folder.
#
# HKEY_CLASSES_ROOT\*\shell\MarkDeleted\command = powershell.exe -windowstyle hidden -file C:\Users\d020715\OneDrive\dev\media-importer\mark-deleted.ps1 "%1"
# see MarkDeleted.reg file
############################################################

$ignoreFileIndex = Get-Content "$env:media_importer_data\marked-for-deletion.csv"
if (!($ignoreFileIndex -contains $file)) {
    "Adding ", $file, " to index" -join ' '  | out-file "$env:media_importer_data\marked.log" -append
    $file | out-file "$env:media_importer_data\marked-for-deletion.csv" -append
} else {
    $file, " is already in index"  -join ' '  | out-file "$env:media_importer_data\marked.log" -append
}

# move file to MarkDeleted
$target = ($file -replace "\\Pictures\\", "\\Pictures\\.deleted\\")
"Target is ", $target  -join ' '  | out-file "$env:media_importer_data\marked.log" -append

if (Test-Path -path $target) {
    "Removing source ", $file -join ' '  | out-file "$env:media_importer_data\marked.log" -append
    Remove-Item $file
} else {

    # Create directory, if it does not exist
    $targetDir = [System.IO.Path]::GetDirectoryName($target)
    if (!(Test-Path -path $targetDir)) {
        New-Item $targetDir -type directory | Out-Null
    }

    "Moving ", $file, " to ", $target  -join ' '  | out-file "C:\Users\d020715\OneDrive\dev\media-importer\out\marked.log" -append
    Move-Item -Path $file -Destination $target    
}


