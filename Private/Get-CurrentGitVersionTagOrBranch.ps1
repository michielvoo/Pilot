. (Join-Path $PSScriptRoot "Get-CurrentGitBranch.ps1")
. (Join-Path $PSScriptRoot "Get-CurrentGitTag.ps1")

function Get-CurrentGitVersionTagOrBranch() {
    $tag = Get-CurrentGitTag

    if ($tag -and $tag -cmatch "v\d+\.\d+\.\d+")
    {
        return $tag
    }
    else
    {
        $branch = Get-CurrentGitBranch
        if ($branch) {
            return $branch
        }
    }
}
