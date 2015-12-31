Function Get-GithubOrgRepository {
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
        [string]$OrganisationName
    )
    
    Begin {}
    Process {
        if (-not (($GithubPersonalOAuthToken) -or ($BasicCreds))) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        try {
            $json = Invoke-WebRequest -Uri https://api.github.com/orgs/$OrganisationName/repos -Method Get -ErrorAction Stop
        }
        catch {
            Write-Error -Message $_
        }

        [System.Collections.ArrayList]$orgrepos = @()

        $con_json = ConvertFrom-Json -InputObject $json.Content

        foreach ($obj in $con_json) {

            $orgrepo = New-Object -TypeName PSObject
            Add-Member -InputObject $orgrepo -MemberType NoteProperty -Name 'Repository Name' -Value $obj.name
            Add-Member -InputObject $orgrepo -MemberType NoteProperty -Name 'Repository Owner' -Value $obj.owner.login
            Add-Member -InputObject $orgrepo -MemberType NoteProperty -Name 'Repository Description' -Value $obj.description
            $orgrepos += $orgrepo
        }
        $orgrepos      
    }
    End {
        Remove-Variable -Name json -Force
        Remove-Variable -Name con_json -Force
        Remove-Variable -Name orgrepos -Force
        Remove-Variable -Name orgrepo -Force
    }
}

Function Get-GithubOwnRepositories {
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
        [Parameter(mandatory=$false,HelpMessage='One Time Password for Multi-Factor Authentication Enabled accounts')]
        [string]$MFA1TP
    )
    
    Begin {}
    Process {

        if ($GithubPersonalOAuthToken) {
        try {
                $json = Invoke-WebRequest -Uri https://api.github.com/user/repos -Method Get -Headers @{"Authorization"="token $GithubPersonalOAuthToken"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        if (-not (($GithubPersonalOAuthToken) -or ($BasicCreds))) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        if ($MFA1TP) {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/user/repos -Method Get -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $MFA1TP} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        else {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/user/repos -Method Get -Headers @{"Authorization"="Basic $BasicCreds"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        [System.Collections.ArrayList]$repos = @()

        $con_json = ConvertFrom-Json -InputObject $json.Content
        foreach ($obj in $con_json) {
            $repo = New-Object -TypeName PSObject
            Add-Member -InputObject $repo -MemberType NoteProperty -Name 'Name' -Value $obj.name
            Add-Member -InputObject $repo -MemberType NoteProperty -Name 'Description' -Value $obj.description
            $repos += $repo
        }
        $repos
    }
    End {
        Remove-Variable -Name json -Force
        Remove-Variable -Name con_json -Force
        Remove-Variable -Name repos -Force
        Remove-Variable -Name repo -Force
    }
}

Function Get-GithubPublicRepositories {
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
        [parameter(mandatory=$false)]
        [string] $githubusername
    )
    
    Begin {}
    Process {
        try {
            $json = Invoke-WebRequest -Uri https://api.github.com/users/$githubusername/repos -Method Get -ErrorAction Stop
        }
        catch {
            Write-Error -Message $_
        }
    
        [System.Collections.ArrayList]$repos = @()

        $con_json = ConvertFrom-Json -InputObject $json.Content
        foreach ($obj in $con_json) {
            $repo = New-Object -TypeName PSObject
            Add-Member -InputObject $repo -MemberType NoteProperty -Name 'Name' -Value $obj.name
            Add-Member -InputObject $repo -MemberType NoteProperty -Name 'Description' -Value $obj.description
            $repos += $repo
        }
        $repos
    }
    End {
        Remove-Variable -Name json -Force
        Remove-Variable -Name con_json -Force
        Remove-Variable -Name repos -Force
        Remove-Variable -Name repo -Force
    }
}

Function Remove-GithubRepository {
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
        [string]$githubusername,
        [Parameter(Mandatory=$true)]
        [string]$Repository_Name,
        [Parameter(Mandatory=$true,HelpMessage='One Time Password for Multi-Factor Authentication Enabled accounts')]
        [string]$MFA1TP
    )

    Begin {}
    Process {
        if (-not (($GithubPersonalOAuthToken) -or ($BasicCreds))) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        if ($MFA1TP) {
            try {
                Invoke-WebRequest -Uri https://api.github.com/repos/$githubusername/$Repository_Name -Method Delete -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $MFA1TP} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        elseif ($GithubPersonalOAuthToken) {
            try {
                Invoke-WebRequest -Uri https://api.github.com/repos/$githubusername/$Repository_Name -Method Delete -Headers @{"Authorization"="token $GithubPersonalOAuthToken"} -Verbose -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        } else {
            try {
                Invoke-WebRequest -Uri https://api.github.com/repos/$githubusername/$Repository_Name -Method Delete -Headers @{"Authorization"="Basic $BasicCreds"} -Verbose -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }

    }
    End {}
}

Function New-GithubRepository {
    <#
            .SYNOPSIS
            Create a new Github repository
            .DESCRIPTION
            This function will create a new Github repository via the Github REST API.
            .EXAMPLE
            New-GithubRepository -repository_name Demo -repository_description 'This is a demo repo' -repository_homepage 'http://www.david-obrien.net' -repository_private true -repository_has_issues false -repository_has_wiki false -repository_has_downloads true
 
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
        [Parameter(Mandatory= $true)]
        [string]$repository_name,
        [Parameter(Mandatory= $true)]
        [string]$repository_description,
        [Parameter(Mandatory= $true)]
        [string]$repository_homepage,
        [Parameter(Mandatory= $true)]
        [string]$repository_private,
        [Parameter(Mandatory= $true)]
        [string]$repository_has_issues,
        [Parameter(Mandatory= $true)]
        [string]$repository_has_wiki,
        [Parameter(Mandatory= $true)]
        [string]$repository_has_downloads,
        [Parameter(Mandatory= $false,HelpMessage='One Time Password for Multi-Factor Authentication Enabled accounts')]
        [string]$MFA1TP
    )

    Begin { 
        if (-not (($GithubPersonalOAuthToken) -or ($BasicCreds))) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }
    }
    Process {
        $newrepo = @"
{
    "name": "$repository_name",
    "description": "$repository_description",
    "homepage": "$repository_homepage",
    "private": $repository_private,
    "has_issues": $repository_has_issues,
    "has_wiki": $repository_has_wiki,
    "has_downloads": $repository_has_downloads
}
"@
        if (-not (($GithubPersonalOAuthToken) -or ($BasicCreds))) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        if ($MFA1TP) {
            try {
                Invoke-WebRequest -Body $newrepo -Uri https://api.github.com/user/repos -Method Post -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $MFA1TP} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        elseif ($GithubPersonalOAuthToken) {
            try {
                Invoke-WebRequest -Body $newrepo -Uri https://api.github.com/user/repos -Method Post -Headers @{"Authorization"="token $GithubPersonalOAuthToken"} -Verbose -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        } else {
            try {
                Invoke-WebRequest -Body $newrepo -Uri https://api.github.com/user/repos -Method Post -Headers @{"Authorization"="Basic $BasicCreds"} -Verbose -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }

    }
    End {
        Remove-Variable -Name newrepo -Force
    }
}
