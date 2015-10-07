Function Connect-Github {
<#
.Synopsis
    Connects PowerShell to the Github API
.DESCRIPTION
    This function will connect the current PowerShell session to the Github API via Basic Authentication. 2FA is currently not yet supported.
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

Function New-GithubRepository {
<#
.Synopsis
    Create a new Github repository
.DESCRIPTION
    This function will create a new Github repository via the Github REST API.
.EXAMPLE
    New-GithubRepository -repository_name Demo -repository_description 'This is a demo repo' -repository_homepage 'http://www.david-obrien.net' -repository_private true -repository_has_issues false -repository_has_wiki false -repository_has_downloads true
#>
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

Function Get-GithubPublicRepositories {
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

Function Get-GithubOwnRepositories {
    param (

    )
    
    if (-not ($BasicCreds)) {
        throw 'Please run Connect-Github first to get an authentication token for Github'
    }

    try {
        $json = Invoke-WebRequest -Uri https://api.github.com/user/repos -Method Get -ErrorAction Stop
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

Function List-GithubBranches {
    param (
        [parameter(mandatory=$true)]
        [string]$githubuser,
        [parameter(mandatory=$true)]
        [string]$githubrepository
    )


    if (-not ($BasicCreds)) {
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

Function Get-GithubBranch {
    param (
        [parameter(mandatory=$true)]
        [string]$githubuser,
        [parameter(mandatory=$true)]
        [string]$githubrepository,
        [parameter(mandatory=$false)]
        [string]$githubbranch='master'
    )


    if (-not ($BasicCreds)) {
        throw 'Please run Connect-Github first to get an authentication token for Github'
    }

    try {
        $json = Invoke-WebRequest -Uri https://api.github.com/repos/$githubuser/$githubrepository/branches/$githubbranch -Method Get -ErrorAction Stop
    }
    catch {
        Write-Error -Message $_
    }
    
    [System.Collections.ArrayList]$branch_ = @()

    $con_json = ConvertFrom-Json -InputObject $json.Content
    
    $branch_ = New-Object -TypeName PSObject
    Add-Member -InputObject $branch_ -MemberType NoteProperty -Name 'Branch Name' -Value $con_json.name
    Add-Member -InputObject $branch_ -MemberType NoteProperty -Name 'Last Commit Author' -Value $con_json.commit.author.login
    Add-Member -InputObject $branch_ -MemberType NoteProperty -Name 'Last Commit Message' -Value $con_json.commit.commit.message

    $branch_
}

Function Get-GithubOrgRepository {
param (
    [Parameter(mandatory=$true)]
    [string]$OrganisationName
)
    if (-not ($BasicCreds)) {
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
        Add-Member -InputObject $orgrepo -MemberType NoteProperty -Name 'Repository Name' -Value $con_json.name
        Add-Member -InputObject $orgrepo -MemberType NoteProperty -Name 'Repository Owner' -Value $con_json.owner.login
        Add-Member -InputObject $orgrepo -MemberType NoteProperty -Name 'Repository Description' -Value $con_json.description
        $orgrepos += $orgrepo
    }
    $orgrepos
}

Function Get-GithubWebhook {
param
(
  [Parameter(Mandatory=$true)]
  [string]$githubuser,
  [Parameter(Mandatory=$false)]
  [string]$githubrepository,
  [Parameter(Mandatory=$false)]
  [string]$OneTimePassword
)


    if (-not ($BasicCreds)) {
        throw 'Please run Connect-Github first to get an authentication token for Github'
    }

    if ($OneTimePassword) {
        try {
            $json = Invoke-WebRequest -Uri https://api.github.com/repos/$githubuser/$githubrepository/hooks -Method Get -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $OneTimePassword} -ErrorAction Stop
        }
        catch {
            Write-Error -Message $_
        }
    }
    else {
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

Function New-GithubWebhook {
param (
  [Parameter(Mandatory=$true)]
  [string]$githubuser,
  [Parameter(Mandatory=$true)]
  [string]$githubrepository,
  [Parameter(Mandatory=$true)]
  [string]$webhookurl,
  [Parameter(Mandatory=$false)]
  [string]$webhooktype='web',
  [Parameter(Mandatory=$false)]
  [string]$OneTimePassword
)
    if (-not ($BasicCreds)) {
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

    if ($OneTimePassword) {
        try {
            Invoke-WebRequest -Body $json -Uri https://api.github.com/repos/$githubuser/$githubrepository/hooks -Method Post -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $OneTimePassword} -ErrorAction Stop
        }
        catch {
            Write-Error -Message $_
        }
    }
    else {
        try {
            Invoke-WebRequest -Body $json -Uri https://api.github.com/repos/$githubuser/$githubrepository/hooks -Method Post -Headers @{"Authorization"="Basic $BasicCreds"} -ErrorAction Stop
        }
        catch {
            Write-Error -Message $_
        }
    }
}
