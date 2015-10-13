Function Get-GithubOrgRepository {
    param (
        [Parameter(mandatory=$true)]
        [string]$OrganisationName
    )
    
    Begin {}
    Process {
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
    param (
        [Parameter(mandatory=$false)]
        [string]$OneTimePassword
    )
    
    Begin {}
    Process {
        if (-not ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        if ($OneTimePassword) {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/user/repos -Method Get -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $OneTimePassword} -ErrorAction Stop
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
    param (
        [Parameter(Mandatory=$true)]
        [string]$githubusername,
        [Parameter(Mandatory=$true)]
        [string]$Repository_Name,
        [Parameter(Mandatory=$true)]
        [string]$OneTimePassword
    )

    Begin {}
    Process {
        if (-not ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        if ($OneTimePassword) {
            try {
                Invoke-WebRequest -Uri https://api.github.com/repos/$githubusername/$Repository_Name -Method Delete -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $OneTimePassword} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        else {
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
        [string]$repository_has_downloads,
        [Parameter(Mandatory= $false)]
        [string]$OneTimePassword
    )

    Begin { 
        if (-not ($BasicCreds)) {
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
        if (-not ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        if ($OneTimePassword) {
            try {
                Invoke-WebRequest -Body $newrepo -Uri https://api.github.com/user/repos -Method Post -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $OneTimePassword} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        else {
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