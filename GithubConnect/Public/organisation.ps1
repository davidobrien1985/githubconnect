Function Add-GithubUserToOrganisation {
    param (
        [Parameter(mandatory=$true)]
        [string]$OrganisationName,
        [Parameter(mandatory=$true)]
        [string]$githubusername,
        [ValidateSet('admin','member')]
        [Parameter(mandatory=$false)]
        [string]$role='member',
        [parameter(mandatory=$false)]
        [string]$OneTimePassword
    )

    Begin {}
    Process {
        if (-not ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        $body = @{'role'="$role"}

        if ($OneTimePassword) {
            try {
                Invoke-WebRequest -Body $body -Uri https://api.github.com/orgs/$OrganisationName/memberships/$githubusername -Method Put -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $OneTimePassword} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        else {
            try {
                Invoke-WebRequest -Body $body -Uri https://api.github.com/orgs/$OrganisationName/memberships/$githubusername -Method Put -Headers @{"Authorization"="Basic $BasicCreds"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }        
        }
    }
    End {
        Remove-Variable -Name body -Force
        Remove-Variable -Name OrganisationName -Force
        Remove-Variable -Name githubusername -Force
    }
}

Function Remove-GithubUserFromOrganisation {
    param (
        [Parameter(mandatory=$true)]
        [string]$OrganisationName,
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
                Invoke-WebRequest -Body $body -Uri https://api.github.com/orgs/$OrganisationName/memberships/$githubusername -Method Delete -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $OneTimePassword} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        else {
            try {
                Invoke-WebRequest -Body $body -Uri https://api.github.com/orgs/$OrganisationName/memberships/$githubusername -Method Delete -Headers @{"Authorization"="Basic $BasicCreds"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }        
        }
    }
    End {
        Remove-Variable -Name OrganisationName -Force
        Remove-Variable -Name githubusername -Force
    }


}
