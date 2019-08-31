###########################################################

Import-Module ActiveDirectory



#Import CSV

$path     = Split-Path -parent $MyInvocation.MyCommand.Definition

$newpath  = $path + "\Portfolios.csv"

$csv      = @()

$csv      = Import-Csv -Path $newpath



#Get Domain Base

$searchbase = Get-ADDomain | ForEach {  $_.DistinguishedName }

write-host "== Using $searchbase Domain"

#Standard Group Layout




#Loop through all Portfolio Names items in CSV

ForEach ($item In $csv) {

 #Check if the Cloud/AWS OU exists

 $check = [ADSI]::Exists("LDAP://$($item.Path)")

 

 If ($check -eq $True) {

   Try {

     #Check if the OU already exists

     $exists = Get-ADOrganizationalUnit -Identity "OU=$($item.Portfolio),$($item.Path)"

     Write-Host "== Organisational Unit OU=$($item.Portfolio),$($item.Path) alread exists! OU creation skipped!"

   }

   Catch {

     #Create the ou if it doesn't exist

     $create = New-ADOrganizationalUnit -Name $item.Portfolio -Path $($item.path)

     Write-Host "=========================================================================="

     Write-Host "== New OU $($item.Portfolio) created!"

     Write-Host "== LDAP: OU=$($item.Portfolio),$($item.Path)"

     Write-Host "=========================================================================="

    }
   }

 Else {

   Write-Host "== ERROR: Something went wrong, AD path can't be found. OU creation skipped!"

 }

}



#Loop through all Portfolio Names items in CSV for group creation
 
ForEach ($item In $csv) { 

$StandardGroups = @("SPLUNKFS_NONPROD_$($item.Portfolio)_USER",
               "SPLUNKFS_NONPROD_$($item.Portfolio)_POWER",
               "SPLUNKFS_PROD_$($item.Portfolio)_USER",
               "SPLUNKFS_PROD_$($item.Portfolio)_POWER",
               "DATADOGFS_$($item.Portfolio)_USER",
               "AWSFS_654782114_$($item.Portfolio)_READONLY",
               "AWSFS_654782114_$($item.Portfolio)_ADMIN",
               "AWSFS_3788880647_$($item.Portfolio)_READONLY",
               "AWSFS_378410647_$($item.Portfolio)_ADMIN",
               "AWSFS_817577935_$($item.Portfolio)_DEVOPS",
               "AWSFS_81777935_$($item.Portfolio)_ADMIN",
               "NONPROD_$($item.Portfolio)_ACCESS",
               "NONPROD_$($item.Portfolio)_DEVOPS",
               "NONPROD_$($item.Portfolio)_SUDOERS",                    
               "PROD_$($item.Portfolio)_ACCESS",
               "PROD_$($item.Portfolio)_DEVOPS",
               "PROD_$($item.Portfolio)_SUDOERS")
 #Check if the Portfolio OU exists
 $check = [ADSI]::Exists("LDAP://OU=$($item.Portfolio),$($item.Path)")
 If ($check -eq $True) {
    ForEach ($GroupName in $StandardGroups) {
       Try {
             #Check if the Group already exists
             $exists = Get-ADGroup $GroupName
             Write-Host "== Group $GroupName alread exists! Group creation skipped!"
           }
       Catch {
             #Create the group if it doesn't exist
             ForEach ($GroupName in $StandardGroups) {
             $create = New-ADGroup -Name $GroupName -GroupScope Global -Path "OU=$($item.Portfolio),$($item.Path)" 
             Write-Host "==========================================================================="
             Write-Host "== New Group $GroupName created!"
             Write-Host "== LDAP: CN=$GroupName,OU=$($item.Portfolio),$($item.Path)"
             Write-Host "==========================================================================="
           }
        }
      }
    }
}
