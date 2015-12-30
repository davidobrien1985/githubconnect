Function Get-GithubTeams {
 <#
            .SYNOPSIS
            Connects PowerShell to the Github API
            .DESCRIPTION
            This function will connect the current PowerShell session to the Github API via Basic Authentication. Also supports 2 Factor Authentication via One Time Password.
            The user name and password have to be provided on the command line as Github is not following RFC standards to the full extent: https://developer.github.com/v3/auth/
            If you don't want to provide the password on the command line, don't provide it and enter it in the prompt.
            .PARAMETER GithubCredentials
            Optional. PSCredential object that holds the User's Github Credentials. If not provided, Function will prompt.
            .PARAMETER MFA1TP
            Optional. If your Github user is enabled for Multi-Factor Authentication (MFA or 2FA) you need to provide an MFA1TP in order to authenticate.
            .EXAMPLE
            Connect-Github
            .EXAMPLE
            Connect-Github -GithubCredentials $(Get-Credential)
            .EXAMPLE
            Connect-Github -MFA1TP 123456
            .EXAMPLE
            $creds = Get-Credential
            Connect-Github -GithubCredentials $creds -MFA1TP 123456
    #>
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [string]$OrganisationName,
        [parameter(mandatory=$false,HelpMessage='One Time Password for Multi-Factor Authentication Enabled accounts')]
        [string]$MFA1TP
    )
    
    Begin {}
    Process {
        if (-not ($GithubPersonalOAuthToken) -or ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        if ($MFA1TP) {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/orgs/$OrganisationName/teams -Method Get -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $MFA1TP} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        elseif ($GithubPersonalOAuthToken) {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/orgs/$OrganisationName/teams -Method Get -Headers @{"Authorization"="token $GithubPersonalOAuthToken"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }        
        } else {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/orgs/$OrganisationName/teams -Method Get -Headers @{"Authorization"="Basic $BasicCreds"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }        
        }
        $con_json = ConvertFrom-Json -InputObject $json.Content

        $con_json
    }
    End {
        Remove-Variable -Name json -Force
        Remove-Variable -Name con_json -Force

    }
}

Function Get-GithubTeamFromId {
 <#
            .SYNOPSIS
            Connects PowerShell to the Github API
            .DESCRIPTION
            This function will connect the current PowerShell session to the Github API via Basic Authentication. Also supports 2 Factor Authentication via One Time Password.
            The user name and password have to be provided on the command line as Github is not following RFC standards to the full extent: https://developer.github.com/v3/auth/
            If you don't want to provide the password on the command line, don't provide it and enter it in the prompt.
            .PARAMETER GithubCredentials
            Optional. PSCredential object that holds the User's Github Credentials. If not provided, Function will prompt.
            .PARAMETER MFA1TP
            Optional. If your Github user is enabled for Multi-Factor Authentication (MFA or 2FA) you need to provide an MFA1TP in order to authenticate.
            .EXAMPLE
            Connect-Github
            .EXAMPLE
            Connect-Github -GithubCredentials $(Get-Credential)
            .EXAMPLE
            Connect-Github -MFA1TP 123456
            .EXAMPLE
            $creds = Get-Credential
            Connect-Github -GithubCredentials $creds -MFA1TP 123456
    #>
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [string]$TeamId,
        [parameter(mandatory=$false,HelpMessage='One Time Password for Multi-Factor Authentication Enabled accounts')]
        [string]$MFA1TP
    )
    
    Begin {}
    Process {
        if (-not ($GithubPersonalOAuthToken) -or ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        if ($MFA1TP) {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/teams/$TeamId -Method Get -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $MFA1TP} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        elseif ($GithubPersonalOAuthToken) {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/teams/$TeamId -Method Get -Headers @{"Authorization"="token $GithubPersonalOAuthToken"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }        
        } else {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/teams/$TeamId -Method Get -Headers @{"Authorization"="Basic $BasicCreds"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }        
        }
        $con_json = ConvertFrom-Json -InputObject $json.Content

        $con_json
    }
    End {
        Remove-Variable -Name json -Force
        Remove-Variable -Name con_json -Force

    }
}

Function Get-GithubTeamMembership {  
<#
            .SYNOPSIS
            Connects PowerShell to the Github API
            .DESCRIPTION
            This function will connect the current PowerShell session to the Github API via Basic Authentication. Also supports 2 Factor Authentication via One Time Password.
            The user name and password have to be provided on the command line as Github is not following RFC standards to the full extent: https://developer.github.com/v3/auth/
            If you don't want to provide the password on the command line, don't provide it and enter it in the prompt.
            .PARAMETER GithubCredentials
            Optional. PSCredential object that holds the User's Github Credentials. If not provided, Function will prompt.
            .PARAMETER MFA1TP
            Optional. If your Github user is enabled for Multi-Factor Authentication (MFA or 2FA) you need to provide an MFA1TP in order to authenticate.
            .EXAMPLE
            Connect-Github
            .EXAMPLE
            Connect-Github -GithubCredentials $(Get-Credential)
            .EXAMPLE
            Connect-Github -MFA1TP 123456
            .EXAMPLE
            $creds = Get-Credential
            Connect-Github -GithubCredentials $creds -MFA1TP 123456
    #>
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [string]$TeamId,
        [Parameter(mandatory=$true)]
        [string]$githubusername,
        [parameter(mandatory=$false,HelpMessage='One Time Password for Multi-Factor Authentication Enabled accounts')]
        [string]$MFA1TP
    )
    
    Begin {}
    Process {
        if (-not ($GithubPersonalOAuthToken) -or ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        if ($MFA1TP) {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/teams/$TeamId/memberships/$githubusername -Method Get -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $MFA1TP} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        elseif ($GithubPersonalOAuthToken) {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/teams/$TeamId/memberships/$githubusername -Method Get -Headers @{"Authorization"="token $GithubPersonalOAuthToken"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }        
        } else {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/teams/$TeamId/memberships/$githubusername -Method Get -Headers @{"Authorization"="Basic $BasicCreds"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }        
        }
        $con_json = ConvertFrom-Json -InputObject $json.Content

        $con_json
    }
    End {
        Remove-Variable -Name json -Force
        Remove-Variable -Name con_json -Force

    }
}

<#
Function Add-GithubUserToTeam {
    param (
        [Parameter(mandatory=$true)]
        [string]$TeamId,
        [Parameter(mandatory=$true)]
        [string]$githubusername,
        [parameter(mandatory=$false)]
        [string]$MFA1TP
    )
}
#>
