$Scriptroot = Split-Path $script:MyInvocation.MyCommand.Path

Get-ChildItem $Scriptroot\Public *.ps1 -Recurse | ForEach-Object { Import-Module $_.FullName }
. $Scriptroot\*.Tests.ps1 #This is only in still as this was how I found the Module running - Advise that we remove this line on v1 release
