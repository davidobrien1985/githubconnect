Function Connect-Github {
    <#
            .Synopsis
            Connects PowerShell to the Github API
            .DESCRIPTION
            This function will connect the current PowerShell session to the Github API via Basic Authentication. Also supports 2 Factor Authentication via One Time Password.
            The user name and password have to be provided on the command line as Github is not following RFC standards to the full extent: https://developer.github.com/v3/auth/
            If you don't want to provide the password on the command line, don't provide it and enter it in the prompt.
            .PARAMETER GithubCredentials
            Optional. PSCredential object that holds the User's Github Credentials. If not provided, Function will prompt.
            .PARAMETER OneTimePassword
            Optional. If your Github user is enabled for Multi-Factor Authentication (MFA or 2FA) you need to provide an OneTimePassword in order to authenticate.
            .EXAMPLE
            Connect-Github
            .EXAMPLE
            Connect-Github -GithubCredentials $(Get-Credential)
            .EXAMPLE
            Connect-Github -OneTimePassword 123456
            .EXAMPLE
            $creds = Get-Credential
            Connect-Github -GithubCredentials $creds -OneTimePassword 123456
    #>
    param (
        [Parameter(Mandatory=$false)]
        [PSCredential]$GithubCredentials,
        [Parameter(Mandatory=$false)]
        [string]$OneTimePassword
    )
    
    Begin
    {
    }
    Process
    {
        if (-not $GithubCredentials) {
            $GithubCredentials = (Get-Credential -Message 'Please enter the Github User credentials')
        }

        $githubusername = $GithubCredentials.UserName
        $githubpassword = $GithubCredentials.GetNetworkCredential().Password

        $AuthString = '{0}:{1}' -f $githubusername,$githubpassword
        $AuthBytes  = [System.Text.Encoding]::Ascii.GetBytes($AuthString)
        $global:BasicCreds = [Convert]::ToBase64String($AuthBytes)

        $githuburi = 'https://api.github.com/user' 
        if ($OneTimePassword) {
            try {
                Invoke-WebRequest -Uri $GitHubUri -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $OneTimePassword} -Verbose -ErrorAction Stop
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
    End
    {
    }
}