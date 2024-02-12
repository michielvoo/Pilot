. (Join-Path $PSScriptRoot "Invoke-Git.ps1")

# https://git-scm.com/docs/git-branch

# .SYNOPSIS
# List branches.
function Invoke-GitBranchList {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # Print the name of the current branch. In detached HEAD state, nothing is printed.
        [Parameter()]
        [switch]$ShowCurrent,

        # Used as a shell wildcard to restrict the output to matching branches. If multiple
        # patterns are given, a branch is shown if it matches any of the patterns.
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Patterns
    )

    $Arguments = @()

    if ($ShowCurrent) {
        $Arguments += "--show-current"
    }

    # ...

    Invoke-Git "branch" "--list" @Arguments @Patterns
}
