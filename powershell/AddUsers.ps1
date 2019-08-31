###########################################################
Import-Module ActiveDirectory

#Import CSV
$path     = Split-Path -parent $MyInvocation.MyCommand.Definition
$newpath  = $path + "\UserList.csv"
$csv      = @()
$csv      = Import-Csv -Path $newpath

#Get Domain Base
$searchbase = Get-ADDomain | ForEach {  $_.DistinguishedName }
write-host "== Using $searchbase Domain"

#Standard Group Layout
#Loop through all items in CSV
ForEach ($item In $csv) {
  #Check if the OU exists
  $check = [ADSI]::Exists("LDAP://$($item.Path)")
  If ($check -eq $True) {
    Write-Host "== Organisational Unit Path: $($item.Path) exist!" 
    Add-ADGroupMember -Identity $item.CN -Members $item.Username
    Write-Host "== CN: $($item.CN) | User: $($item.Username) added!"
  }
  Else {
    Write-Host "== No Identity $item.Path exist."
  }
}

