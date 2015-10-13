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

    Begin {}
    Process {
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
    End {
        Remove-Variable -Name json -Force
        Remove-Variable -Name con_json -Force    
    }
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
    
    Begin {}
    Process {
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
    End {
        Remove-Variable -Name json -Force
    }
}