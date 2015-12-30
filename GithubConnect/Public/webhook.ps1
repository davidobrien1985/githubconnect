Function Get-GithubWebhook {
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
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$githubuser,
        [Parameter(Mandatory=$false)]
        [string]$githubrepository,
        [Parameter(Mandatory=$false,HelpMessage='One Time Password for Multi-Factor Authentication Enabled accounts')]
        [string]$MFA1TP
    )

    Begin {}
    Process {
        if (-not ($GithubPersonalOAuthToken) -or ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        if ($MFA1TP) {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/repos/$githubuser/$githubrepository/hooks -Method Get -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $MFA1TP} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        elseif ($GithubPersonalOAuthToken) {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/repos/$githubuser/$githubrepository/hooks -Method Get -Headers @{"Authorization"="token $GithubPersonalOAuthToken"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        } else {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/repos/$githubuser/$githubrepository/hooks -Method Get -Headers @{"Authorization"="Basic $BasicCreds"} -ErrorAction Stop
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

Function New-GithubWebhook {
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
        [Parameter(Mandatory=$true)]
        [string]$githubuser,
        [Parameter(Mandatory=$true)]
        [string]$githubrepository,
        [Parameter(Mandatory=$true)]
        [string]$webhookurl,
        [Parameter(Mandatory=$false)]
        [string]$webhooktype='web',
        [Parameter(Mandatory=$false,HelpMessage='One Time Password for Multi-Factor Authentication Enabled accounts')]
        [string]$MFA1TP
    )
    
    Begin {}
    Process {
        if (-not ($GithubPersonalOAuthToken) -or ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }
    
        $json = @"
{
    "name": "$webhooktype",
    "active": true,
    "events": ["push"],
    "config": {
    "url": "$webhookurl",
    "content_type": "json"
    }
}
"@

        if ($MFA1TP) {
            try {
                Invoke-WebRequest -Body $json -Uri https://api.github.com/repos/$githubuser/$githubrepository/hooks -Method Post -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $MFA1TP} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        elseif ($GithubPersonalOAuthToken) {
            try {
                Invoke-WebRequest -Body $json -Uri https://api.github.com/repos/$githubuser/$githubrepository/hooks -Method Post -Headers @{"Authorization"="token $GithubPersonalOAuthToken"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        } else {
            try {
                Invoke-WebRequest -Body $json -Uri https://api.github.com/repos/$githubuser/$githubrepository/hooks -Method Post -Headers @{"Authorization"="Basic $BasicCreds"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
    }
    End {
        Remove-Variable -Name json -Force
    }
}
