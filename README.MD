Overview
========
Connect to remote shares without repeatedly entering admin credentials. This is handy if you often have to connect to remote Windows machines and check logs, files etc.

Usage
=====
Run the powershell script as NORMAL user e.g. open CMD > "powershell see-share-client.ps1" without quotes..

On first launch there is a configuration stage which saves your admin account name and the password (in encrypted form) on the local machine in C:\Users\%userprofile%\Documents\seeshareclient.

After that you are prompted for the machine name/service tag, press enter and as long as your username and password were correct it should connect to the machines share (by default this is \\machine\c$).

If your password changes frequently, you can run the script with a switch which will force you to enter your new password. The switch is simply "password" e.g. open CMD > "powershell see-share-client.ps1 password" (without quotes).