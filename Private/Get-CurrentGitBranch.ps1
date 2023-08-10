. ([string]::Join([IO.Path]::DirectorySeparatorChar, @($PSScriptRoot, "..", "Invoke", "Invoke-Git", "Invoke-GitBranchList.ps1")))

function Get-CurrentGitBranch() {
    $parameters = @{
        ShowCurrent = $true # only print the current branch or nothing if in detached head state
    }
    $result = Invoke-GitBranchList @parameters

    if ($result.ExitCode -ne 0) {
        return
    }

    if ($result.Stdout.Count -eq 1) {
        return $result.Stdout[0]
    }
}