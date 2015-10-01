<#
#region create webhook on github

$json = @"
{
  "name": "web",
  "active": true,
  "events": ["push"],
  "config": {
    "url": "https://s1events.azure-automation.net/webhooks?token=MfAW7mSFABOTVPy2jSpxQj7HjAAIOT0veMrUKKZL6T0%3d",
    "content_type": "json"
  }
}
"@

Invoke-WebRequest -Body $json -Uri https://api.github.com/repos/davidobrien1985/demos/hooks -Method Post -Headers @{"Authorization"="Basic $BasicCreds"} -Verbose

#endregion create webhook on github


Invoke-WebRequest -Uri https://api.github.com/users/davidobrien1985/repos -Method Get -Verbose
#>
Function Connect-Github {
param (
    [Parameter(Mandatory=$true)]
    [string]$githubusername,
    [string]$Password,
    [string]$OneTimePassword
)

<#
.Synopsis
   Connects PowerShell to the Github API
.DESCRIPTION
   This function will connect the current PowerShell session to the Github API via Basic Authentication. 2FA is currently not yet supported.
.EXAMPLE
   Connect-Github -githubusername user1 -Password P@ssw0rd
#>

# The user name and password have to be provided on the command line as Github is not following RFC standards to the full extent: https://developer.github.com/v3/auth/
#

    $AuthString = "{0}:{1}" -f $githubusername,$Password
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

Function New-GithubRepository {
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
    [string]$repository_has_downloads
)

    if (-not ($BasicCreds)) {
        throw 'Please run Connect-Github first to get an authentication token for Github'
    }

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

    try {
        Invoke-WebRequest -Body $newrepo -Uri https://api.github.com/user/repos -Method Post -Headers @{"Authorization"="Basic $BasicCreds"} -Verbose -ErrorAction Stop
    }
    catch {
        Write-Error $_
    }

}

Function Remove-GithubRepository {
param (
    [Parameter(Mandatory=$true)]
    [string]$githubusername,
    [Parameter(Mandatory=$true)]
    [string]$Repository_Name
)

    if (-not ($BasicCreds)) {
        throw 'Please run Connect-Github first to get an authentication token for Github'
    }

    try {
        Invoke-WebRequest -Uri https://api.github.com/repos/$githubusername/$Repository_Name -Method Delete -Headers @{"Authorization"="Basic $BasicCreds"} -Verbose -ErrorAction Stop
    }
    catch {
        Write-Error -Message $_
    }

}

Function Get-GithubRepository {
param (
    [parameter(mandatory=$true)]
    [string] $githubusername
)

    if (-not ($BasicCreds)) {
        throw 'Please run Connect-Github first to get an authentication token for Github'
    }

    try {
        Invoke-WebRequest -Uri https://api.github.com/repos/$githubusername -Method Get -Headers @{"Authorization"="Basic $BasicCreds"} -Verbose -ErrorAction Stop
    }
    catch {
        Write-Error -Message $_
    }


}