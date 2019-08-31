###########################################################
Import-Module ActiveDirectory
#Import CSV
$path     = Split-Path -parent $MyInvocation.MyCommand.Definition
$newpath  = $path + "\Users.csv"
$csv      = @()
$csv      = Import-Csv -Path $newpath
#Get Domain Base
$searchbase = Get-ADDomain | ForEach {  $_.DistinguishedName }
write-host "== Using $searchbase Domain"

$name = "AWSFS_Connectors@sq.com.sg"
$pass = Read-Host -AsSecureString "Password:"
$creds = New-Object -typeName System.Management.Automation.PSCredential -ArgumentList $name, $pass

#Loop through all Usernames items in CSV, add their public key and add them to the bastion access group.
ForEach ($item In $csv) {
 #Check if the User exists
 $check = [ADSI]::Exists("LDAP://$($item.Username)")
 If ($check -eq $True) {
      Set-ADUser -Identity $Item.Username -replace @{AltSecurityIdentities=$item.sshpublickey} -Credential $creds
      Add-ADGroupMember -Identity "CN=NONPRODSERVICE_BASTION_ACCESS,OU=AWS,OU=Cloud,DC=abc,DC=com" -Members $Item.Username -Credential $creds
  }
 else {
  write-host "== No Identity $item.Username exists."
 }
 }

#$p="" | ConvertTo-SecureString
#Unlock-ADAccount -Identity "AWSFS_Connectors" -Credential $creds
