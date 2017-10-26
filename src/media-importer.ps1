[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$startPath
)

# Kopiert Bilder und Filme vom Handy in eine Ordnerstruktur Jahr/Monat auf dem PC. 
# Es werden nur fehlende Dateien kopiert.
# Version 0.1

Write-Output ("=========================")
Write-Output ("    Media Importer 0.1   ")
Write-Output (" (c)2017 by Ralf Detzler ")
Write-Output ("=========================")
Write-Output ("")

#Write-Output(-join("startPath=",$startPath))
$destinationDirName = "C:\Users\d020715\Pictures\"

$global:num_new = 0
$global:num_old = 0
$global:ignoreFileIndex = @{}

# ====================================================
# Returns the path on the phone for a given file.
# /iPhone von Ralf/Internal Storage/DCIM/100APPLE/
# ====================================================
Function getPath($item) {
    
    $parentFolder = $item.Parent
    $path = "/" + $parentFolder.Title
    while ($parentFolder.Title -ne $root.Title) {
        $parentFolder = $parentFolder.ParentFolder
        $path = "/" + $parentFolder.Title + $path
    }

    return $path + "/"
}

# ====================================================
# Handles single file. 
#
# Checks, if the file exists in the destination folder
# and copies it, if not.
# ====================================================
Function handle_file($file) {

    $path = getPath($file)
    $out = $path + $file.Name
    
    $dateTaken = $file.Parent.GetDetailsOf($file, 3)
    $tokens = $dateTaken.Split(". ")
    $day = $tokens[0]
    $month = $tokens[1]
    $year = $tokens[2]
    $size = $file.Parent.GetDetailsOf($file, 2)
    $out = $out + " " + $dateTaken + " " + $size + " " + $year+ "\"+ $month + "\" + $day

    $targetDir = $destinationDirName + $year + "\" + $month + "\" 
    $target =  $targetDir + $file.Name
    
    # Check, if in ignore file
    if ($global:ignoreFileIndex -contains $target) {
        $global:num_old = $global:num_old + 1 
        return
    }

    # Create directory, if it does not exist
    if (!(Test-Path -path $targetDir)) {
        New-Item $targetDir -type directory | Out-Null
    }

    # Copy file, if it does not exist in destination folder
    $destinationFolder = (new-object -com shell.application).NameSpace(($targetDir))
    if (!(Test-Path -path $target)) {
        Write-Output("")
        Write-output ($out)
        write-output(-join("  copying ", $target))
       
        $destinationFolder.CopyHere($file, 16)
        $global:num_new = $global:num_new + 1
        return
    }

    # Check if newer
    $dateTargetFile = (Get-item $target).lastwritetime
    $sourceDate = Get-Date $dateTaken -format "yyyy-MM-dd hh:mm"
    $targetDate = Get-Date $dateTargetFile -format "yyyy-MM-dd hh:mm"
    if ($sourceDate -gt $targetDate) {
        Write-Output("")
        Write-output ($out)
        write-output(-join("  overwriting ", $target))
        Remove-Item $target

        $destinationFolder.CopyHere($file, 16)
        $global:num_new = $global:num_new + 1
        return
    }

    $global:num_old = $global:num_old + 1   
}

# ====================================================
# Handles folder on phone.
#
# Calls 'handle_file' for each file in the folder and 
# calls 'handle_folder' for each folder in the folder.
# ====================================================
Function handle_folder($folder) {

    Write-output (-join("Handling folder ",  $folder.Title))
    $items = $folder.Items()
    if ($items.Count -le 0) {
        return
    }

    foreach ($i in $items) {
        if ($i.IsFolder) {
            $folder = $i.GetFolder()
            handle_folder($folder)
        }
        else {      
            handle_file($i)
        }                
    }
}

Function pause() {
    Write-Host "Press any key to continue ..."
    [System.Console]::ReadKey()
}

Function changeDir($dir) {

    $elements = $dir.Split("\")

    # get drives
    $folder = (new-object -com shell.application).NameSpace(0x11)

    for ($i= 0; $i -lt $elements.Count; $i++) {

        $folder.Items() | ForEach-Object {
            if ($_.Name -eq $elements[$i]) {
                $folder = $_.GetFolder()
                continue
            }
        }
    }

    return $folder
}

# Returns 
Function getFullPathFriendly($item) {

  $parentFolder = $item.ParentFolder
  $path = "\" + $parentFolder.Title + "\" + $item.Title
  while ($parentFolder.Title ) {
      $parentFolder = $parentFolder.ParentFolder
      $path = "\" + $parentFolder.Title + $path
  }

  return $path + "\"
}

# Returns the folder object for a full path, given as string.
Function getDirFromGuid($dirString) {
    
    if (!($dirString -match "..{")) {
        return getDirFromFriendlyName($dirString)
    }

    $folder  = (new-object -com shell.application).NameSpace($dirString)
    if ($folder.Title -match "..{") {
        write-host(-join("ERROR: getDirFromHost(",$dirString,") not found."))
        return 0
    }
    return  $folder
}

# Returns folder object for the given by friendly string
Function getDirFromFriendlyName($dir) {

    if (!($dir.endswith("\"))) {
        $dir = $dir + "\"
    }
    
    # path starts with \\Desktop\COMPUTERNAME\
    $elements = $dir -Split "\\"
    $dirString = -join("\\",$elements[2], "\", $elements[3])

    # get drives
    $folder = (new-object -com shell.application).NameSpace(0x11)

    for ($i= 4; $i -lt $elements.Count-1; $i++) {
        $dirString = -join($dirString, "\", $elements[$i])
        $found = $false

        $folder.Items() | ForEach-Object {

            if ($found -eq $true) {continue}
            if ($_.Name -eq $elements[$i]) {
                $folder = $_.GetFolder()
                $found = $true
                continue
            }
        }
    }

    $dirString = -join($dirString, "\")
    if (!($dirString -eq $dir)) {
        write-host(-join($dir, " not found (", $dirString, ")"))
        return 0
    }

    return $folder
}




# ====================================================
# Main program
# ====================================================
#$folder = (new-object -com shell.application).NameSpace(0x11)

#$items = $folder.Items()

# Find the phone
#$phone = "none"
#$items|foreach{
#    if ($_.Name -match 'iPhone') {
#        $phone = $_
#    }
#}

#$items|foreach{
#    if ($_.Name -match 'Ralf') {
#        $phone = $_
#    }
#}

#if ($phone -eq "none") {
#    Write-Output ("No phone found")
#    
#    pause
#    return
#}


$global:ignoreFileIndex = Get-Content "$env:media_importer_data\marked-for-deletion.csv"

# Change to start folder
#$root = changeDir($startPath)
$dir = getDirFromGuid($startPath)
#Write-host(-join("Friendly Startdir=",$dir.title))

$fullPath = getFullPathFriendly($dir)
Write-host(-join("Importing from ", $fullPath, " to ",$destinationDirName))

$root = getDirFromFriendlyName($fullPath)

if (!$fullPath.EndsWith($root.Title+"\")) {
    write-output(-join("ERROR: Startpath ", $fullPath, " not found, found instead ", $root.Title))
    pause
    return
}

handle_folder($root)
Write-output (-join($global:num_new, " new Files, ", $global:num_old, " available Files"))

Write-Output ("")
Write-Output ("Fertig")
pause
