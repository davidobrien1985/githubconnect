$Scriptroot = Split-Path $script:MyInvocation.MyCommand.Path

Get-ChildItem $Scriptroot *.ps1 -Recurse | ForEach-Object { Import-Module $_.FullName }
