[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$startPath,
    [Parameter(Mandatory=$true)]
    [string]$repoDir
)

# Dot Sourcing, Nachteil: Powershell neu starten nach Änderungen
#. "..\classes\HashTools.ps1" 
#. "..\classes\FileWalker.ps1" 

$global:num = 0
$global:fileIndex = @{}
$global:ht = [HashTools]::new()

Class Indexer : FileWalker
{
    handle_file([string]$sourceFile) {

        $md5 = Get-FileHash $sourceFile -Algorithm MD5
        Write-host(-join($sourceFile," - ", $md5.Hash))
        $global:num = $global:num + 1

        if ($global:fileIndex.ContainsKey($md5.Hash)) {
            $prevFilename = $global:fileIndex[$md5.Hash]
            $best = $this.best_alternative($sourceFile, $prevFilename)

            if (!($best -eq $prevFilename)) {
                $global:fileIndex[$md5.Hash] = $best
                write-host(-join("Replacing duplicate ", $global:fileIndex[$md5.Hash], " in index by ", $best ))
            }
        } else {
            $global:fileIndex[$md5.Hash] = $sourceFile
        }
    }
}


# ====================================================
# Main program
# ====================================================

$fileWalker = [Indexer]::new()
$fileWalker.walk($startPath)

Write-output (-join($global:num, " Dateien indiziert"))

$global:ht.WriteHash($global:fileIndex, "$env:media_importer_data/fotoindex.csv")

Write-Output ("")
Write-Output ("Fertig")