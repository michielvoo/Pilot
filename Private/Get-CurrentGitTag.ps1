. ([string]::Join([IO.Path]::DirectorySeparatorChar, @($PSScriptRoot, "..", "Invoke", "Invoke-Git", "Invoke-GitDescribe.ps1")))

function Get-CurrentGitTag() {
    $parameters = @{
        Commitish = "HEAD"
        ExactMatch = $true # only tags that directly reference the commit
        Tags = $true # allow unannotated (lightweight) tags
    }
    $result = Invoke-GitDescribe @parameters

    If ($result.ExitCode -ne 0) {
        return
    }
    
    if ($result.Stdout.Count -eq 1) {
        return $result.Stdout[0]
    }
}