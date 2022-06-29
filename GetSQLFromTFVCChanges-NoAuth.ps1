## This script will find and download files from a TFVC changeset 
## that end with a paricular extension (defaults to .sql) 

# This version doesn't specify any authentication.  I don't have an environment to verify but I'm hoping this 
# will work with default Windows Authentication.

# TODO:
#  1-Change the default value of orgUrl

param (
   [Parameter(mandatory=$true)]
   [int]
   $changeSetId,

   $orgUrl="https://azdo/DefaultCollection",

   $apiVersion = "api-version=6.0",

   $fileExtension = ".sql"
)

# Get the details of the changeset
$changesUrl = "$orgUrl/_apis/tfvc/changesets/$changeSetId/changes?$apiVersion"
$changes = Invoke-RestMethod -Uri $changesUrl -Method Get -ContentType "application/json"

# For each change, download the file if it ends with .sql and isn't a delete
$changes.value | ForEach-Object {
   if (!($_changeType -eq "delete")) {
      $fullPath = $_.item.path
      $fileName = Split-Path $fullPath -leaf
      if ($fileName.endsWith($fileExtension, $true, $host.CurrentCulture)) {
         Write-Host "Downloading $fileName"
         Invoke-RestMethod -Uri $_.item.url -Method Get -OutFile $fileName
      }   
   }
}