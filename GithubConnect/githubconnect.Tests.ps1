$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$module_name = Split-Path -Leaf $here

Describe "Tests the module framework for $module_name" {
    It "Has a root module file ($module_name.psm1)" {        
            
        "$here\$module_name.psm1" | Should Exist
    }

    It "Is valid PowerShell" {

        $contents = Get-Content -Path "$here\$module_name.psm1" -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }

    It 'passes the PSScriptAnalyzer without Errors' {
        (Invoke-ScriptAnalyzer -Path $here -Recurse -Severity Error).Count | Should Be 0
    }

     It 'passes the PSScriptAnalyzer with less than 10 Warnings' {
        (Invoke-ScriptAnalyzer -Path $here -Recurse -Severity Warning).Count | Should BeLessThan 10 
    }

    It "Has a manifest file ($module_name.psd1)" {
            
        "$here\$module_name.psd1" | Should Exist
    }

    It "Contains a root module path in the manifest" {
            
        "$here\$module_name.psd1" | Should Contain "$module_name.psm1"
    }

    It "Contains all needed properties in the Manifest for PSGallery Uploads" {
    
        "$here\$module_name.psd1" | Should Contain "Author = *"
    }
}
$scripts = Get-ChildItem "$here\*.ps1" -recurse | Where-Object {$_.name -NotMatch "Tests.ps1"}
    
foreach($script in $scripts)    {
Describe "Tests the module $($script.BaseName) to be be correctly formatted" {

    Import-Module $script.FullName
          It "Is valid Powershell (Has no script errors)" {

                $contents = Get-Content -Path $script.FullName -ErrorAction Stop
                $errors = $null
                $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
                $errors.Count | Should Be 0
            }
            It 'passes the PSScriptAnalyzer without Errors' {
        (Invoke-ScriptAnalyzer -Path $here -Recurse -Severity Error).Count | Should Be 0
    }

     It 'passes the PSScriptAnalyzer with less than 10 Warnings' {
        (Invoke-ScriptAnalyzer -Path $here -Recurse -Severity Warning).Count | Should BeLessThan 10 
    }
        }
    }

Describe "Tests the Functions to ensure that they are correctly formatted" {
$functions = Get-Command -FullyQualifiedModule $module_name 
    foreach($modulefunction in $functions)
    {

        Context "Function $($modulefunction.Name)" {
            It "Has show-help comment block" {

                $modulefunction.Definition.Contains('<#') | should be 'True'
                $modulefunction.Definition.Contains('#>') | should be 'True'
            }

            It "Has show-help comment block has a.SYNOPSIS" {

                $modulefunction.Definition.Contains('.SYNOPSIS') | should be 'True'
            }

            It "Has show-help comment block has an example" {

                $modulefunction.Definition.Contains('.EXAMPLE') | should be 'True'
            }

            It "Is an advanced function" {

                $modulefunction.CmdletBinding | should be 'True'
                $modulefunction.Definition.Contains('param') | should be 'True'
            }

        }
    }
}
