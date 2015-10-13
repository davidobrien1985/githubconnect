$Scriptroot = Split-Path $script:MyInvocation.MyCommand.Path

Get-ChildItem $Scriptroot *.ps1 -Recurse | % { Import-Module $_.FullName }
