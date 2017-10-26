Class FileWalker {

    [String] ToString()
    {
        return "FileWalker 1.0"
    }

    handle_file([string]$inputFilePath) {
        Write-host(-join("Handling ", $inputFilePath))
    }

    [string]
    best_alternative([string]$fileA, [string]$fileB) {

        if ($fileA -match 'IMG' -and !($fileB -match 'IMG')) {
            return $fileA
        }
        if ($fileB -match 'IMG' -and !($fileA -match 'IMG')) {
            return $fileB
        }
        if ($fileA -match 'DSC' -and !($fileB -match 'DSC')) {
            return $fileA
        }
        if ($fileB -match 'DSC' -and !($fileA -match 'DSC')) {
            return $fileB
        }
        if ($fileA.Length -lt $fileB.Length) {
            return $fileA
        }

        # Onedrive appends _iOS to the file names, remove this
        #$targetFile = $targetFile -replace "_iOS.", "."
        #$tartargetFileget = $targetFile -replace "_Android.", "."

        return $fileB
    }


   [void] walk([string]$folderPath) {

        #Write-host(-join("Walking ",$folderPath))
        $items = Get-ChildItem $folderPath
        if ($items.Count -le 0) {
            return
        }

        foreach ($i in $items) {
            #Write-host $i.FullName
            $isfolder = (Get-Item $i.FullName) -is [System.IO.DirectoryInfo]
            if ($isfolder -eq $True) {
                $this.walk($i.FullName)
            }
            else {      
                $this.handle_file($i.FullName)
            }                
        }
    }

}

class TestMe : FileWalker {

}