###########################################################
Import-Module ActiveDirectory

#Import CSV
$path     = Split-Path -parent $MyInvocation.MyCommand.Definition
$newpath  = $path + "\Groups.csv"
$csv      = @()
$csv      = Import-Csv -Path $newpath

#Get Domain Base
$searchbase = Get-ADDomain | ForEach {  $_.DistinguishedName }
write-host "== Using $searchbase Domain"

#Standard Group Layout
#Loop through all OU Group items in CSV for group creation

ForEach ($item In $csv) {
  #Check if the OU exists
  $check = [ADSI]::Exists("LDAP://$($item.Path)")
  If ($check -eq $True) {
    Write-Host "== Organisational Unit Path: $($item.Path) exist!"
      Try {
        #Check if the Group already exists
        $exists = Get-ADGroup $item.CN
        Write-Host "== Group $($item.CN) already exists! Group creation skipped!"
      }
      Catch {
        #Create the group if it doesn't exist
        $create = New-ADGroup -Name $item.CN -GroupScope Global -Path $item.Path
        Write-Host "==========================================================================="
        Write-Host "== New Group $($item.CN) created!"
        Write-Host "== LDAP = CN: $($item.CN), OU: $($item.Path)"
        Write-Host "==========================================================================="
      }
  }
  Else {
    Write-Host "== No Identity $item.Path exist."
  }
}
