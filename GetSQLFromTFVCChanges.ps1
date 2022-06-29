## This script will find and download files from a TFVC changeset 
## that end with a paricular extension (defaults to .sql) 

# TODO:
#  1-Change the default value of orgUrl
#  2-Create a PAT token with Code > Read permissions
#    It's like a password so you probably don't want to save it as a default value here
#    See https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops-2020&tabs=Windows#create-a-pat

param (
   [Parameter(mandatory=$true)]
   [int]
   $changeSetId,

   $orgUrl="https://azdo/DefaultCollection",

   [Parameter(mandatory=$true)]
   [SecureString]
   $pat,

   $apiVersion = "api-version=6.0",

   $fileExtension = ".sql"
)
  

# Create auth header with PAT
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pat)      
$plainTextPat = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($plainTextPat)"))
$header = @{authorization = "Basic $token"}

# Get the details of the changeset
$changesUrl = "$orgUrl/_apis/tfvc/changesets/$changeSetId/changes?$apiVersion"
$changes = Invoke-RestMethod -Uri $changesUrl -Method Get -ContentType "application/json" -Headers $header

# For each change, download the file if it ends with .sql and isn't a delete
$changes.value | ForEach-Object {
   if (!($_changeType -eq "delete")) {
      $fullPath = $_.item.path
      $fileName = Split-Path $fullPath -leaf
      if ($fileName.endsWith($fileExtension, $true, $host.CurrentCulture)) {
         Write-Host "Downloading $fileName"
         Invoke-RestMethod -Uri $_.item.url -Method Get -Headers $header -OutFile $fileName
      }   
   }
}