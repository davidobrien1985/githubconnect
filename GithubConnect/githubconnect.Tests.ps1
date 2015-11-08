$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$module_name = Split-Path -Leaf $here

Describe "githubconnect" {
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
