. 'C:\Users\d020715\OneDrive\dev\media-importer/classes/HashTools.ps1'

# create hash
$global:ht = [HashTools]::new()
$global:fileIndex = @{}

$global:fileIndex['123'] = 'abc'
$global:fileIndex['456'] = 'def'

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
#
#$OutputTable = $global:fileIndex.getEnumerator() | foreach{
#    New-Object PSObject -Property ([ordered]@{Hash=$_.Key;File=$_.Value})
#}##
#
#$OutputTable | Export-CSV out/test2.csv -NoTypeInformation


#$mytable = Import-Csv -Path out/test2.csv
#$HashTable=@{}
#foreach($r in $mytable)
#{
#    $HashTable[$r.Hash]=$r.File
#}
#::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\\\?\usb#vid_05ac&pid_12a8&mi_00#0#{6ac27878-a6fa-4155-ba85-f98f491d4f33}\SID-{10002,Internal Storage,32000000000}
#$folder = (new-object -com shell.application).NameSpace("::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\\\?\usb#vid_05ac&pid_12a8&mi_00#0#{6ac27878-a6fa-4155-ba85-f98f491d4f33}")

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
    $folder  = (new-object -com shell.application).NameSpace($dirString)
    if ($folder.Title -match "..{") {
        write-host(-join("ERROR: getDirFromHost(",$dirString,") not found."))
        return 0
    }
    return  $folder
}

# Returns folder object for the given by friendly string
Function getDirFromFriendlyName($dir) {
    # path starts with \\Desktop\IGBN33983660A\
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



$startDir = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\\\?\usb#vid_04e8&pid_6860&ms_comp_mtp&samsung_android#6&b14e629&2&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}\SID-{10001,SECZ9519043CHOHB,12547092480}\{010700C2-0111-0113-2201-050124011701}"
$startDir = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\\\?\usb#vid_04e8&pid_6860&ms_comp_mtp&samsung_android#6&b14e629&2&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}\SID-{20002,SECZ9519043CHOHB01,63829639168}\{00EA008E-00D5-00F9-F700-D700EB00AB00}\{01C80156-01AB-01C7-6501-3E015E014E01}";
$startDir = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\\\?\usb#vid_04e8&pid_6860&ms_comp_mtp&samsung_android#6&b14e629&2&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}\SID-{10001,SECZ9519043CHOHB,12547092480}\{010700C2-0111-0113-5501-39015201CA00}\{01760126-017C-0188-CC01-A201BD016201}\{01DA0155-01DD-01FC-2D02-A201BD016201}\{024301B9-023E-01FC-2D02-D1012A02C701}";
$startDir = "iii::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\\\?\usb#vid_04e8&pid_6860&ms_comp_mtp&samsung_android#6&b14e629&2&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}\SID-{10001,SECZ9519043CHOHB,12547092480}\{010700C2-0111-0113-2201-050124011701}";
write-host(-join("Startdir is ", $startDir))

$dir = getDirFromGuid($startDir)
Write-host(-join("Friendly Startdir=",$dir.title))

$fullPath = getFullPathFriendly($dir)
Write-host(-join("full path=", $fullPath))

$startDir = getDirFromFriendlyName($fullPath)
Write-host(-join("Dir from friendly=", $startDir.title))

return


$elements = $startDir -Split "\\SID-"
$deviceStr = $elements[0]
$pathStr = -join("SID-",$elements[1])
Write-host(-join("Device: ", $deviceStr, " - "))
Write-host(-join("Path: ", $pathStr))

$device  = (new-object -com shell.application).NameSpace($deviceStr)
Write-host(-join("Device=", $device.title))

$elements2 = $pathStr -Split "\\"
$start = $deviceStr
$friendly = $device.title
$elements2 | ForEach-Object { 
    $start  = -join($start, "\", $_)
    Write-host(-join("Start ",$start))
    $folder = (new-object -com shell.application).NameSpace($start)
    $friendly = -join($friendly, "\", $folder.title)
    Write-host(-join($friendly, ": ",$folder.title))
}


Write-host(-join("Element 0=", $elements2[0]))
$path=$device.Items() | where-object {$_.name -eq $elements2[0]}
     
Write-host(-join("Name=", (new-object -com shell.application).NameSpace($path)))



#$path  = (new-object -com shell.application).NameSpace($pathStr)
Write-host(-join("Path=", $path.title))

$folder  = (new-object -com shell.application).NameSpace($startDir)
Write-host(-join("startFolder is ", $folder.title))
Write-host(-join("path is ", $folder.path))


#\SID-{10001,SECZ9519043CHOHB,12547092480}\{010700C2-0111-0113-2201-050124011701}
  $items = $folder.Items()
    if ($items.Count -le 0) {
        Write-host("no items")
        return
    }

    foreach ($i in $items) {
        Write-host($i.name)
    }    

Write-Host "Press any key to continue ..."

#[System.Console]::ReadKey()
return


$global:ht.WriteHash($global:fileIndex, "out/test.csv")

$global:fileIndex = $global:ht.ReadHash("out/test.csv")

$first = $global:fileIndex['123']
if (!($first -eq 'abc')) {
    Write-host(-join("ERROR: expected abc but found ",$first))
}

$first = $global:fileIndex['456']
if (!($first -eq 'def')) {
    Write-host(-join("ERROR: expected abc but found ",$first))
}



