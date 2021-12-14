<# @aWinmdFile - physical path to the .winmd file to be read #>
<# @aMethod        - method to call from this script #>
param([string] $aWinmdFile, [string] $aMethod)

[string] $kReaderAssemblyPath = "../../../third-party/microsoft.cci/Microsoft.Cci.Helper.dll";

function GetActivatableClasses ([string]$aWinmdFile)
{
  return [Microsoft.Cci.Helper.PeReaderHelper]::LoadWinmdActivatableClassesAsXml($aWinmdFile);
}

try
{
  <# Load microsoft library for reading winmd files #>
  $asm = [System.Reflection.Assembly]::LoadFrom((Split-Path $script:MyInvocation.MyCommand.Path) + $kReaderAssemblyPath);
  $objectXmlFormat = &$aMethod $aWinmdFile;
  Write-Host $objectXmlFormat;
}
catch
{
  Write-Host $Error[0].Exception.Message;
  exit 11111;
}

