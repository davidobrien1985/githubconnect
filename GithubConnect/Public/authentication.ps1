Function Connect-Github {
    <#
            .SYNOPSIS
            Connects PowerShell to the Github API
            .DESCRIPTION
            This function will connect the current PowerShell session to the Github API via Basic Authentication or Via Personal Oauth Tokens. Also supports 2 Factor Authentication via One Time Password.
            The user name and password have to be provided on the command line as Github is not following RFC standards to the full extent: https://developer.github.com/v3/auth/
            If you don't want to provide the password on the command line, don't provide it and enter it in the prompt.
            .PARAMETER GithubCredentials
            Optional. PSCredential object that holds the User's Github Credentials. If not provided, Function will prompt.
            .PARAMETER PersonalOAuthToken
            Optional. String Object for a personal OAuth Token - this is a better practice than passing credentials
            .PARAMETER MFA1TP
            Optional. If your Github user is enabled for Multi-Factor Authentication (MFA or 2FA) you need to provide an MFA1TP (1 Time Password) in order to authenticate.
            .EXAMPLE
            Connect-Github
            .EXAMPLE
            Connect-Github -GithubCredentials $(Get-Credential)
            .EXAMPLE
            Connect-Github -MFA1TP 123456
            .EXAMPLE
            Connect-Github -PersonalOAuthToken $env:GitHubPersonalOAuthToken
            .EXAMPLE
            $creds = Get-Credential
            Connect-Github -GithubCredentials $creds -MFA1TP 123456
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [PSCredential]$GithubCredentials,
        [Parameter(Mandatory=$false,HelpMessage='One Time Password for Multi-Factor Authentication Enabled accounts')]
        [string]$MFA1TP,
        [Parameter(Mandatory=$false)]
        [String]$PersonalOAuthToken
    )
    
    Begin
    {
    }
    Process
    {

        $githuburi = 'https://api.github.com/user' 
        if($PersonalOAuthToken) {
        try {
                Invoke-RestMethod -Uri $GitHubUri -Headers @{"Authorization"="token $PersonalOAuthToken"} -Method Get -Verbose -ErrorAction Stop
                $global:GithubPersonalOAuthToken = $PersonalOAuthToken
            }
            catch {
                Write-Error -Message $_
                  }
        }
        else {
            if(-not $GithubCredentials) { 
                $GithubCredentials = (Get-Credential -Message 'Please enter the Github User credentials') 
                }

        $githubusername = $GithubCredentials.UserName
        $githubpassword = $GithubCredentials.GetNetworkCredential().Password

        $AuthString = '{0}:{1}' -f $githubusername,$githubpassword
        $AuthBytes  = [System.Text.Encoding]::Ascii.GetBytes($AuthString)
        $global:BasicCreds = [Convert]::ToBase64String($AuthBytes)

        if ($MFA1TP) {
            try {
                Invoke-WebRequest -Uri $GitHubUri -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $MFA1TP} -Verbose -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        else {
            try {
                Invoke-WebRequest -Uri $GitHubUri -Headers @{"Authorization"="Basic $BasicCreds"} -Verbose -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }        
        }
        }
    }

    End
    {
    }
}

Function Disconnect-Github {
 <#
            .SYNOPSIS
            Disconnects PowerShell from the Github API
            .DESCRIPTION
            This function will disconnect the current PowerShell session from the Github API via Basic Authentication. Also supports 2 Factor Authentication via One Time Password.
            The user name and password have to be provided on the command line as Github is not following RFC standards to the full extent: https://developer.github.com/v3/auth/
            If you don't want to provide the password on the command line, don't provide it and enter it in the prompt.
            .EXAMPLE
            Disconnect-Github
    #>
    [cmdletbinding()]
    param()

    if (Test-Path Variable:\GithubPersonalOAuthToken) { Remove-Item Variable:\GithubPersonalOAuthToken -Force}
    if (Test-Path Variable:\BasicCreds) { Remove-Item Variable:\BasicCreds -Force}
}
