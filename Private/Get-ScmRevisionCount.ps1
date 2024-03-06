function Get-ScmRevisionCount {
    # Get a number stating how many commits precede HEAD
    $result = Invoke-GitRevList "HEAD" -Count
    if ($result.ExitCode -eq 0) {
        return [System.Convert]::ToInt32($result.Stdout[0])
    }

    return -1
}