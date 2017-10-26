Class HashTools {
	
    [void] 
    WriteHash([hashtable] $hashtable, [string] $filename) {
    
        $targetDir = [System.IO.Path]::GetDirectoryName($filename)
        if (!(Test-Path -path $targetDir)) {
            #Write-host(-join("Creating directory ", $targetDir))
            New-Item $targetDir -type directory | Out-Null
        }


        $csvtable = $hashtable.getEnumerator() | foreach{
            New-Object PSObject -Property ([ordered]@{Hash=$_.Key;File=$_.Value})
        }

       $csvtable | Export-CSV $filename -NoTypeInformation
    }

    [hashtable] 
    ReadHash([string]$filename) {

        $HashTable=@{}
        if (Test-Path -path $filename) {
            $mytable = Import-Csv -Path $filename
            foreach($r in $mytable) {
                $HashTable[$r.Hash]=$r.File
            }  
        }

        return $HashTable 
    }
}