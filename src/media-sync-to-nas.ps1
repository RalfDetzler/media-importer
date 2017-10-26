[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$startPath,
    [Parameter(Mandatory=$true)]
    [string]$destinationDirName,
    [Parameter(Mandatory=$true)]
    [string]$repoDir
)

Write-Output ("=========================")
Write-Output ("     Medien Sync   0.1   ")
Write-Output (" (c)2017 by Ralf Detzler ")
Write-Output ("=========================")
Write-Output ("")

Write-Output(-join("startPath=", $startPath))

$global:fileIndex = @{}
$global:numFiles = 0
$global:numIndexCorrection = 0
$global:newFiles = 0

$global:ht = [HashTools]::new()

Class Synchronizer : FileWalker
{
    [string]$destinationDirName

    Synchronizer([string]$destinationDirName) {
        $this.destinationDirName = $destinationDirName
    }

    handle_file([string]$sourceFile) {

        $global:numFiles = $global:numFiles + 1
       
        #Write-host("")
        #Write-host ("-----------------")
        
        # Calc target file name
        $dateTaken = (Get-item $sourceFile).lastwritetime
        $day = $dateTaken.tostring("dd") 
        $month = $dateTaken.tostring("MM")
        $year = $dateTaken.Year
        $size = (Get-Item $sourceFile).length 
        $targetDir = $this.destinationDirName + $year + "\" + $month + "\" 
        $targetFile =  $targetDir + [System.IO.Path]::GetFileName($sourceFile)
        
        $md5 = Get-FileHash $sourceFile -Algorithm MD5
        $targetFileExists = Test-Path -path $targetFile
        $targetMd5Exists = $global:fileIndex.ContainsKey($md5.Hash)



        #Write-host(-join("Source File: ", $sourceFile, " ", $md5.Hash))
        Write-host(-join("Target File: ", $targetFile, " file exists ", $targetFileExists, " md5 exists ", $targetMd5Exists, " ", $md5.Hash))

        #$out = $sourceFile.Path + " " + $dateTaken + " " + $size + " " + $year+ "\"+ $month + "\" + $day
        #Write-host $out

        if ($targetMd5Exists) {
            $prevFilename = $global:fileIndex[$md5.Hash]
            $best = $this.best_alternative($targetFile, $prevFilename)

            # best alternative already exists, nothing to do
            if (Test-Path -path $best ) {
                return
            }

            # best alternative is already target file, nothing to do
            if ($best -eq $prevFilename) {
                return
            }

            # handling new best file

            # update index with best alternative
            #Write-host(-join("updating index with new best ", $best))
            $global:fileIndex[$md5.Hash] = $best
            $global:numIndexCorrection = $global:numIndexCorrection + 1
            
            # rename file to 
            Write-host(-join("============= Moving ", $prevFilename, " to ", $best))
            Move-Item -Path $prevFilename -Destination $best
            
            return
        }

        # now is clear, target md5 does not exist
        if ($targetFileExists) {
            # update index
            
            $md5_target = Get-FileHash $targetFile -Algorithm MD5
            if ($md5.Hash -eq $md5_target) {
                #Write-host(-join("updating index with target ", $targetFile))
                $global:fileIndex[$md5.Hash] = $targetFile
                $global:numIndexCorrection = $global:numIndexCorrection + 1
                return
            }

            # targetfile has different MD5, create copy
            $targetFile = -join($targetFile, "-copy")
            $md5.Hash = $md5_target.Hash
        }

        # Here, target file does not exist in index and in file system

        # Create directory, if it does not exist
        if (!(Test-Path -path $targetDir)) {
            #Write-host(-join("Creating directory ", $targetDir))
            New-Item $targetDir -type directory | Out-Null
        }

        #Write-host(-join("updating index with ", $targetFile))
        $global:fileIndex[$md5.hash] = $targetFile
        
        Write-host(-join("===================  copying ", $sourceFile, " to ", $targetFile))
        $destinationFolder = (new-object -com shell.application).NameSpace(($targetDir))
        $destinationFolder.CopyHere($sourceFile,16)
        $global:newFiles = $global:newFiles
    }
}

# ====================================================
# Main program
# ====================================================

$global:fileIndex = $global:ht.ReadHash("$env:media_importer_data\fotoindex.csv")

$synchronizer = [Synchronizer]::new($destinationDirName)
$synchronizer.walk($startPath)

$global:ht.WriteHash($global:fileIndex, "$env:media_importer_data\fotoindex.csv")

Write-Host(-join($global:numFiles, " Dateien bearbeitet, ", $global:newFiles, " neue Files, ", $global:numIndexCorrection, " Indexkorrekturen"))
Write-Output ("Fertig")