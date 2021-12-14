<#
.NOTES
  "pwsh.exe" is run if required version is greater or equal to 6, otherwise
  "powershell.exe" is invoked by default
#>

#Requires -version 3
Param()

# your code goes here
Write-Output "Hello from PowerShell $($host.Version.ToString())!"
