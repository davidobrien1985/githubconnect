Function Get-GithubBranches {
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
        [parameter(mandatory=$true)]
        [string]$githubuser,
        [parameter(mandatory=$true)]
        [string]$githubrepository
    )

    Begin {}
    Process {
        if (-not ($GithubPersonalOAuthToken) -or ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        try {
            $json = Invoke-WebRequest -Uri https://api.github.com/repos/$githubuser/$githubrepository/branches -Method Get -ErrorAction Stop
        }
        catch {
            Write-Error -Message $_
        }
        [System.Collections.ArrayList]$branches = @()

        $con_json = ConvertFrom-Json -InputObject $json.Content
        foreach ($obj in $con_json) {
            $branch = New-Object -TypeName PSObject
            Add-Member -InputObject $branch -MemberType NoteProperty -Name 'Name' -Value $obj.name
            Add-Member -InputObject $branch -MemberType NoteProperty -Name 'Last Commit URL' -Value $obj.commit.url
            Add-Member -InputObject $branch -MemberType NoteProperty -Name 'SHA of last Commit' -Value $obj.commit.sha
            $branches += $branch
        }
        $branches
    }
    End {
        Remove-Variable -Name json -Force
        Remove-Variable -Name con_json -Force
        Remove-Variable -Name branch -Force
        Remove-Variable -Name branches -Force    
    }
}

Function Get-GithubBranch {
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
        [parameter(mandatory=$true)]
        [string]$githubuser,
        [parameter(mandatory=$true)]
        [string]$githubrepository,
        [parameter(mandatory=$false)]
        [string]$githubbranch='master'
    )

    Begin {}
    Process {
        if (-not ($GithubPersonalOAuthToken) -or ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        try {
            $json = Invoke-WebRequest -Uri https://api.github.com/repos/$githubuser/$githubrepository/branches/$githubbranch -Method Get -ErrorAction Stop
        }
        catch {
            Write-Error -Message $_
        }

        $con_json = ConvertFrom-Json -InputObject $json.Content
    
        $branch = New-Object -TypeName PSObject
        Add-Member -InputObject $branch -MemberType NoteProperty -Name 'Branch Name' -Value $con_json.name
        Add-Member -InputObject $branch -MemberType NoteProperty -Name 'Last Commit Author' -Value $con_json.commit.author.login
        Add-Member -InputObject $branch -MemberType NoteProperty -Name 'Last Commit Message' -Value $con_json.commit.commit.message

        $branch
    }
    End {
        Remove-Variable -Name json -Force
        Remove-Variable -Name con_json -Force
        Remove-Variable -Name branch -Force    
    }
}
