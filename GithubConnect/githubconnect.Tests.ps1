$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$module_name = Split-Path -Leaf $here

Describe "Tests the module framework" {
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
        (Invoke-ScriptAnalyzer -Path . -Recurse -Severity Error).Count | Should Be 0
    }

    It "Has a manifest file ($module_name.psd1)" {
            
        "$here\$module_name.psd1" | Should Exist
    }

    It "Contains a root module path in the manifest" {
            
        "$here\$module_name.psd1" | Should Contain ".\$module_name.psm1"
    }
}

Describe "Tests the module's functions" {

$scripts = Get-ChildItem "$here\public\*.ps1" | Where-Object {$_.name -NotMatch "Tests.ps1"}
    foreach($script in $scripts)
    {
        Context "Function $($script.BaseName)" {
            It "Has show-help comment block" {

                $script.FullName | should contain '<#'
                $script.FullName | should contain '#>'
            }

            It "Has show-help comment block has a synopsis" {

                $script.FullName | should contain '\.SYNOPSIS'
            }

            It "Has show-help comment block has an example" {

                $script.FullName | should contain '\.EXAMPLE'
            }

            It "Is an advanced function" {

                $script.FullName | should contain 'function'
                $script.FullName | should contain 'cmdletbinding'
                $script.FullName | should contain 'param'
            }

            It "Is valid Powershell (Has no script errors)" {

                $contents = Get-Content -Path $script.FullName -ErrorAction Stop
                $errors = $null
                $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
                $errors.Count | Should Be 0
            }
        }
    }
}