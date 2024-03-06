function Get-ScmRevisionCount {
    # Get a number stating how many commits precede HEAD
    $result = Invoke-GitRevList "HEAD" -Count
    if ($result.ExitCode -eq 0) {
        return $result.Stdout / 1
    }

    return -1
}