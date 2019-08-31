###########################################################

Import-Module ActiveDirectory



#Import CSV

$path     = Split-Path -parent $MyInvocation.MyCommand.Definition

$newpath  = $path + "\Application.csv"

$csv      = @()

$csv      = Import-Csv -Path $newpath



#Get Domain Base

$searchbase = Get-ADDomain | ForEach {  $_.DistinguishedName }

write-host "== Using $searchbase Domain"

#Standard Group Layout




#Loop through all Application Names items in CSV

ForEach ($item In $csv) {

 #Check if the Cloud/AWS OU exists

 $check = [ADSI]::Exists("LDAP://$($item.Path)")

 

 If ($check -eq $True) {

   Try {

     #Check if the OU already exists

     $exists = Get-ADOrganizationalUnit -Identity "OU=$($item.Application),$($item.Path)"

     Write-Host "== Organisational Unit OU=$($item.Application),$($item.Path) already exists! OU creation skipped!"

   }

   Catch {

     #Create the ou if it doesn't exist

     $create = New-ADOrganizationalUnit -Name $item.Application -Path $($item.Path)

     Write-Host "=========================================================================="

     Write-Host "== New OU $($item.Application) created!"

     Write-Host "== LDAP: OU=$($item.Application),$($item.Path)"

     Write-Host "=========================================================================="

    }
   }

 Else {

   Write-Host "== ERROR: Something went wrong, AD path can't be found. OU creation skipped!"

 }

}



#Loop through all Application Name items in CSV for group creation
 
ForEach ($item In $csv) { 

$StandardGroups = @("AWSFS_65598114_$($item.Portfolio)_$($item.Application)_READONLY",
               "AWSFS_65478214_$($item.Portfolio)_$($item.Application)_ADMIN",
               "AWSFS_378410647_$($item.Portfolio)_$($item.Application)_READONLY",
               "AWSFS_88410647_$($item.Portfolio)_$($item.Application)_ADMIN",
               "AWSFS_817577935_$($item.Portfolio)_$($item.Application)_DEVOPS",
               "AWSFS_817577935_$($item.Portfolio)_$($item.Application)_ADMIN",
               "NONPROD_$($item.Portfolio)_$($item.Application)_ACCESS",
               "NONPROD_$($item.Portfolio)_$($item.Application)_DEVOPS",
               "NONPROD_$($item.Portfolio)_$($item.Application)_SUDOERS",                    
               "PROD_$($item.Portfolio)_$($item.Application)_ACCESS",
               "PROD_$($item.Portfolio)_$($item.Application)_DEVOPS",
               "PROD_$($item.Portfolio)_$($item.Application)_SUDOERS")
 #Check if the Application OU exists
 $check = [ADSI]::Exists("LDAP://OU=$($item.Application),$($item.Path)")
 If ($check -eq $True) {
    ForEach ($GroupName in $StandardGroups) {
       Try {
             #Check if the Group already exists
             $exists = Get-ADGroup $GroupName
             Write-Host "== Group $GroupName already exists! Group creation skipped!"
           }
       Catch {
             #Create the group if it doesn't exist
             ForEach ($GroupName in $StandardGroups) {
             $create = New-ADGroup -Name $GroupName -GroupScope Global -Path "OU=$($item.Application),$($item.Path)" 
             Write-Host "==========================================================================="
             Write-Host "== New Group $GroupName created!"
             Write-Host "== LDAP: CN=$GroupName,OU=$($item.Application),$($item.Path)"
             Write-Host "==========================================================================="
           }
        }
      }
    }
}
