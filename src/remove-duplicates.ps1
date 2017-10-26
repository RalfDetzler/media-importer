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
$global:num_del = 0
$global:sum = 0
$global:fileIndex = @{}
$global:ht = [HashTools]::new()

Class Indexer : FileWalker
{

    handle_file([string]$currentFile) {

        $global:num = $global:num + 1
        $md5 = Get-FileHash $currentFile -Algorithm MD5
        #Write-host(-join($currentFile," - ", $md5.Hash))

        if ($global:fileIndex.ContainsKey($md5.Hash)) {
            $prevFilename = $global:fileIndex[$md5.Hash]
            $best = $this.best_alternative($currentFile, $prevFilename)

            if ($best -eq $prevFilename) {
                # delete current file
                $global:sum = $global:sum + (Get-Item $currentFile).length 
                Remove-Item $currentFile
                Write-Host(-join("Remove ", $currentFile, " keeping ", $prevFilename))
                $global:num_del = $global:num_del + 1

            } else {
                # delete previous file
                $global:sum = $global:sum + (Get-Item $prevFilename).length 
                Remove-Item $prevFilename
                Write-Host(-join("Remove ", $prevFilename, " keeping ", $currentFile))
                $global:num_del = $global:num_del + 1

                # correct index
                $global:fileIndex[$md5.Hash] = $currentFile
            }
        } else {
            $global:fileIndex[$md5.Hash] = $currentFile    
        }
    }
}


# ====================================================
# Main program
# ====================================================

$fileWalker = [Indexer]::new()
$fileWalker.walk($startPath)

Write-output (-join($global:num, " Dateien indiziert"))

$global:ht.WriteHash($global:fileIndex, "$env:media_importer_data\fotoindex.csv")

Write-Host(-join($global:num, " files processed, ", $global:num_del, " files deleted. Freed up ", $global:sum , " Bytes"))
Write-Output ("Fertig")