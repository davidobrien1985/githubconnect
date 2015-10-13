Function List-GithubBranches {
    param (
        [parameter(mandatory=$true)]
        [string]$githubuser,
        [parameter(mandatory=$true)]
        [string]$githubrepository
    )

    Begin {}
    Process {
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
    End {
        Remove-Variable -Name json -Force
        Remove-Variable -Name con_json -Force
        Remove-Variable -Name branch -Force
        Remove-Variable -Name branches -Force    
    }
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

    Begin {}
    Process {
        if (-not ($BasicCreds)) {
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