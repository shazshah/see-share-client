#------------------------------------------------------------------------------------------------------------------------------
#Programe Name: SeeShareClient (SSC)
#
#Author:        Shaz
#
#Purpose:       Connect to machine shares without having to constantly put in username and password.
#               The script itself must be run as Normal User.
#
#Date Created:  08/12/2015
#
#Version:       1.3.0
#
#Edits:         SS 16/12/2015: Updated version from 1.0.0 to 1.1.0. Added securefile check. If it does not exist
#                              user is prompted to create it.
#               SS 17/12/2015: Updated version from 1.1.0 to 1.2.0. (1) Refactored code to be more functional. 
#                              (2) User is now prompted for their SU account which
#                              is stored and referenced - means you don't need to hard code the su account.
#               SS 17/12/2015: Updated version from 1.2.0 to 1.3.0. Added a password switch which can be used when a password 
#                              has expired and needs changing.
#-------------------------------------------------------------------------------------------------------------------------------


#----FUNCTIONS-----

Function testMachinePings
    {
        If (!(Test-Connection -Cn $serviceTag -BufferSize 16 -Count 1 -ea 0 -quiet))
            {
                Write-Host "Machine is not pinging (or the machine name is wrong)."
                Exit
            }
    }

Function getAdminAccount
    {
        #store the path for the su account name
        $suAccountFile = [environment]::getfolderpath("mydocuments")+"\seeshareclient\suconfig.txt"
        If (!(Test-Path $suAccountFile)) #check if there is an su account
            {
                #prompt user to input their su account name
                $suUsername = read-host "What's your Admin Account name?"

                #create the seeshareclient directory
                $folderpath = [environment]::getfolderpath("mydocuments")+"\seeshareclient"
                New-Item  $folderpath -type directory

                #Store the su useraccount in a text file
                New-Item $suAccountFile -type file -value $suUsername
            }

        #read and return the contents of the text file so i can use it for authentication in openTheShare function
        $suUsername = Get-Content -Path $suAccountFile
        return $suUsername
    }

Function getAdminPassword
    {
        #store the path for su password
        $securefile = [environment]::GetFolderPath("mydocuments")+"\seeshareclient\ssc_config.txt"
        If(!(Test-Path $securefile)) #check if the secure file with SU pw exists first
            {
                 Write-Host 'You need to setup a secure file with your SU password: '
                 Read-Host -assecurestring | convertfrom-securestring | out-file $securefile
                 Write-Host "Password saved in Encrypted form here ($securefile)."
            }
        return $securefile
    }

Function openTheShare
    {     
        #check the machine is online
        testMachinePings

        #Check the SU account is saved and known
        getAdminAccount

        #Check the SU password has been encrypted and saved
        getAdminPassword

        #---Begin opening the share-----
        
        #Store SU Username in a variable for use in $cred
        $suUsername = getAdminAccount
        
        #change format of the share to correct syntax
        $serviceTag = "\\"+$serviceTag+"\"+'c$'

        #get secure su password and prepare to decrypt to securestring
        $suPassword = getAdminPassword
        $password = cat $suPassword | convertto-securestring 

        #Store password and username
        $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $suUsername, $password

        #Create a temp network drive and connect to remote machine
        #you must run this script as Normal User for this reason: New-PSDrive only works with the user executing the command
        New-PSDrive -Name "P" -PSProvider FileSystem -Root $serviceTag -Credential $cred

        #open the temp drive in Windows Explorer
        invoke-item "P:"

        #Drop the Powershell connection to the machine because it is now open in Windows Explorer
        Remove-PSDrive "P"
    }

#----Main----

#check if command line parameter for forcing password is present
foreach($arg in $args)
{
    $forcePassword = $arg
}

If($forcePassword -eq 'password')
{
    getAdminPassword
}

Else #command line parameter is not present so continue as normal
{
#get the service tag
$serviceTag = Read-Host 'Enter MACHINE NAME '

#open the share
openTheShare
}
