Function Connect-Github {
param (
    [Parameter(Mandatory=$false)]
    [string]$githubusername,
    [Parameter(Mandatory=$false)]
    [string]$githubpassword,
    [Parameter(Mandatory=$false)]
    [string]$OneTimePassword
)

<#
.Synopsis
   Connects PowerShell to the Github API
.DESCRIPTION
   This function will connect the current PowerShell session to the Github API via Basic Authentication. 2FA is currently not yet supported.
   The user name and password have to be provided on the command line as Github is not following RFC standards to the full extent: https://developer.github.com/v3/auth/
   If you don't want to provide the password on the command line, don't provide it and enter it in the prompt.
.EXAMPLE
   Connect-Github
.EXAMPLE
   Connect-Github -githubusername user1 -Password P@ssw0rd
.EXAMPLE
   Connect-Github -githubusername user1 -Password P@ssw0rd -OneTimePassword 123456
#>

if (-not $githubusername) {
    $githubusername = (Get-Credential -Message 'Please only enter the Github User Name').UserName
}

if (-not $githubpassword) {
    $githubpassword = (Get-Credential -Message "Please only enter the user's password" -UserName 'not needed').GetNetworkCredential().Password
}

    $AuthString = "{0}:{1}" -f $githubusername,$githubpassword
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

Function Get-GithubPublicRepository {
param (
    [parameter(mandatory=$false)]
    [string] $githubusername
)
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