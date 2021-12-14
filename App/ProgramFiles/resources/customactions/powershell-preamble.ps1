param(
  [alias("propFile")]      [Parameter(Mandatory=$true)] [string] $msiPropOutFilePath
 ,[alias("propSep")]       [Parameter(Mandatory=$true)] [string] $msiPropKVSeparator
 ,[alias("scriptFile")]    [Parameter(Mandatory=$true)] [string] $userScriptFilePath
 ,[alias("scriptArgsFile")][Parameter(Mandatory=$false)][string] $userScriptArgsFilePath
 ,[Parameter(Mandatory=$true)]                          [string] $testPrefix
 ,[switch]                                                       $isTest
 )

Function AI_GetMsiProperty( [Parameter(Mandatory=$true)]  [string] $name
                          , [Parameter(Mandatory=$false)] $testValue = $null
                          )
{
  if ($isTest -and ($testValue -ne $null))
  {
    "$testPrefix$name$msiPropKVSeparator$testValue" | Out-File -append -encoding unicode -filepath $msiPropOutFilePath
    return $testValue
  }
  [array] $content = Get-Content $msiPropOutFilePath
  [array]::Reverse($content)
  ForEach ($line in $content)
  {
    $lineTokens = $line -split $msiPropKVSeparator
    if ($lineTokens.Count -gt 1 -and $lineTokens[0] -eq $name)
    {
      return $lineTokens[1]
    }
  }
  return ''
}

Function AI_SetMsiProperty( [Parameter(Mandatory=$true)] $name
                          , [Parameter(Mandatory=$false)] $value
                          )
{
  if ($value -eq $null)
  {
    Write-Output "POTENTIAL_BUG: MSI property $name set to an uninitialized/null variable. Initialize empty variables using empty quotes."
  }
  "$name$msiPropKVSeparator$value" | Out-File -append -encoding unicode -filepath $msiPropOutFilePath
}

try
{
  [string] $userScriptArgs = Get-Content $userScriptArgsFilePath
  
  $userScriptFilePath = $userScriptFilePath.Replace(' ', '` ')
  $userScriptFilePath = $userScriptFilePath.Replace('$', '`$')
  $userScriptFilePath = $userScriptFilePath.Replace('&', '`&')
  # Simple quotes are problematic, especially when more in a succession
  # e.g. in a username. We need to enclose each bundle of them in a simple quoted string
  # with each contained simple quote being escaped by doubling. N initial quotes => (N+1)*2 final quotes
  $userScriptFilePath = $userScriptFilePath.Replace("''''", "??????????")
  $userScriptFilePath = $userScriptFilePath.Replace("'''",  "????????")
  $userScriptFilePath = $userScriptFilePath.Replace("''",   "??????")
  $userScriptFilePath = $userScriptFilePath.Replace("'",    "????")
  $userScriptFilePath = $userScriptFilePath.Replace('?',    "'")
  
  Invoke-Expression "$userScriptFilePath $userScriptArgs"

  if ($LastExitCode -ne $null)
  {
    exit $LastExitCode;
  }
}
catch
{
   Write-Output "ERROR: $($_.Exception.Message)"
   Exit 0x23E #ERROR_UNHANDLED_EXCEPTION
}
