. (Join-Path $PSScriptRoot "Invoke-Git.ps1")

# https://git-scm.com/docs/git-rev-list

# .SYNOPSIS
# Lists commit objects in reverse chronological order.
# .DESCRIPTION
# List commits that are reachable by following the `parent` links from the given commit(s), but
# exclude commits that are reachable from the one(s) given with a ^ in front of them. The output
# is given in reverse chronological order by default.
function Invoke-GitRevList {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # 
        [Parameter(Mandatory, Position = 0)]
        [string[]]$Commits
    )

    $Arguments = $Commits

    Invoke-Git "rev-list" @Arguments
}
