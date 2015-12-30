Function Get-GithubPullRequests {
    <#
            .SYNOPSIS
            Gets Pull Requests for a repository
            .DESCRIPTION
            This function will list all Pull Requests for a given Repository. For now only the last 30 Pull Requests will be returned.
            Parsing all PRs is quite time consuming via the API and is only possible via pagination. Not sure yet whether this will be implemented.
            .PARAMETER githubuser
            Mandatory.
            .PARAMETER githubrepository
            Mandatory.
            .PARAMETER state
            Optional. Defaults to open. Accepts open and closed.
            .PARAMETER MFA1TP
            Optional. If your Github user is enabled for Multi-Factor Authentication (MFA or 2FA) you need to provide an MFA1TP in order to authenticate.
            .EXAMPLE
            Get-GithubPullRequest -githubuser davidobrien1985 -githubrepository demos
            .EXAMPLE
            Get-GithubPullRequest -githubuser davidobrien1985 -githubrepository demos -state closed
            .EXAMPLE
            Get-GithubPullRequest -githubuser davidobrien1985 -githubrepository demos -state open -MFA1TP 123456
    #>
    [CmdletBinding()]
param (
        [parameter(mandatory=$true)]
        [string]$githubuser,
        [parameter(mandatory=$true)]
        [string]$githubrepository,
        [parameter(mandatory=$false)]
        [ValidateSet('open','closed')]
        [string]$state='open',
        [parameter(mandatory=$false,HelpMessage='One Time Password for Multi-Factor Authentication Enabled accounts')]
        [string]$MFA1TP
)

    Begin {}
    Process {
        if (-not ($GithubPersonalOAuthToken) -or ($BasicCreds)) {
            throw 'Please run Connect-Github first to get an authentication token for Github'
        }

        $RequestBody = @{'state' = "$state"}

        if ($MFA1TP) {
            try {
                $json = Invoke-WebRequest -Body $RequestBody -Uri https://api.github.com/repos/$githubuser/$githubrepository/pulls -Method Get -Headers @{"Authorization"="Basic $BasicCreds"; "X-Github-OTP" = $MFA1TP} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        elseif($GithubPersonalOAuthToken) {
            try {
                $json = Invoke-WebRequest -Body $RequestBody -Uri https://api.github.com/repos/$githubuser/$githubrepository/pulls -Method Get -Headers @{"Authorization"="token $GithubPersonalOAuthToken"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }        
        } else {
            try {
                $json = Invoke-WebRequest -Body $RequestBody -Uri https://api.github.com/repos/$githubuser/$githubrepository/pulls -Method Get -Headers @{"Authorization"="Basic $BasicCreds"} -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_
            }
        }
        
        $con_json = ConvertFrom-Json -InputObject $json.Content
              
        [System.Collections.ArrayList]$PRs = @()

        foreach ($obj in $con_json) {
            $PR = New-Object -TypeName PSObject
            Add-Member -InputObject $PR -MemberType NoteProperty -Name 'PR Title' -Value $obj.title
            Add-Member -InputObject $PR -MemberType NoteProperty -Name 'PR Id' -Value $obj.id
            Add-Member -InputObject $PR -MemberType NoteProperty -Name 'PR URL' -Value $obj.url
            Add-Member -InputObject $PR -MemberType NoteProperty -Name 'created by' -Value $obj.user.login
            Add-Member -InputObject $PR -MemberType NoteProperty -Name 'PR State' -Value $obj.state
            Add-Member -InputObject $PR -MemberType NoteProperty -Name 'IsLocked' -Value $obj.locked
            Add-Member -InputObject $PR -MemberType NoteProperty -Name 'Created at' -Value $obj.created_at
            Add-Member -InputObject $PR -MemberType NoteProperty -Name 'Updated at' -Value $obj.updated_at
            $PRs += $PR
        }
        $PRs 
    }
    End {
        Remove-Variable -Name json -Force
        Remove-Variable -Name con_json -Force
        Remove-Variable -Name PR -Force
        Remove-Variable -Name PRs -Force
        Remove-Variable -Name con_json -Force
    }

}

<#
Function Get-GithubSinglePullRequest {
param (

)



}

#>

<#
Function New-GithubPullRequest {
param (

)

}
#>

<#
Function Update-GithubPullRequest {
param (

)

}
#>

<#
Function Start-GithubPRMerge {
param (

)

}
#>
