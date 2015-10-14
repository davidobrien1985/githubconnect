Function Get-GithubTeams {
    param (
        [Parameter(mandatory=$true)]
        [string]$OrganisationName,
        [parameter(mandatory=$false)]
        [string]$OneTimePassword
    )
    
    Begin {}
    Process {
        if (-not ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        if ($OneTimePassword) {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/orgs/$OrganisationName/teams -Method Get -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $OneTimePassword} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        else {
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
    param (
        [Parameter(mandatory=$true)]
        [string]$TeamId,
        [parameter(mandatory=$false)]
        [string]$OneTimePassword
    )
    
    Begin {}
    Process {
        if (-not ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        if ($OneTimePassword) {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/teams/$TeamId -Method Get -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $OneTimePassword} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        else {
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
    param (
        [Parameter(mandatory=$true)]
        [string]$TeamId,
        [Parameter(mandatory=$true)]
        [string]$githubusername,
        [parameter(mandatory=$false)]
        [string]$OneTimePassword
    )
    
    Begin {}
    Process {
        if (-not ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        if ($OneTimePassword) {
            try {
                $json = Invoke-WebRequest -Uri https://api.github.com/teams/$TeamId/memberships/$githubusername -Method Get -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $OneTimePassword} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        else {
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
        [string]$OneTimePassword
    )
}
#>
