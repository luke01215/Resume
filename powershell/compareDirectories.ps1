param (
     [string]$sourceDirectory
    ,[string]$destinationDirectory
)

$source = Get-ChildItem -Recurse -Path $sourceDirectory
$destination = Get-ChildItem -Recurse -Path "z:\temp"
#$compare = Compare-Object -ReferenceObject $source -DifferenceObject $destination

Write-Output $compare
#Path = "FileSystem::\\remote-server\foothing
cd c
Copy-Item -Path "\\eggs6\e\temp\1-1.csv" -Destination "C:\temp\1-1.csv" -Force