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
        # Commits to start from.
        [Parameter(Mandatory, Position = 0)]
        [string[]]$Commits,

        # Commit limiting

        # Limit the number of commits to output.
        [Parameter()]
        [int]$MaxCount,

        # Skip number commits before starting to show the commit output.
        [Parameter()]
        [int]$Skip,

        # Show commits more recent than a specific date.
        [Alias("After")]
        [Parameter()]
        [datetime]$Since,

        # Show all commits more recent than a specific date. This visits all commits in the range,
        # rather than stopping at the first commit which is older than a specific date.
        [Parameter()]
        [datetime]$SinceAsFilter,

        # Show commits older than a specific date.
        [Alias("Before")]
        [Parameter()]
        [datetime]$Until,

        # ...

        # History Simplification

        # Bisection Helpers

        # Commit Ordering

        # Object Traversal

        # Commit Formatting

        # ...

        # Print a number stating how many commits would have been listed, and suppress all other
        # output.
        [Parameter()]
        [switch]$Count
    )

    $Arguments = $Commits

    # Commit limiting

    if ($null -ne $MaxCount) {
        $Arguments += "--max-count=$MaxCount"
    }

    if ($null -ne $Skip) {
        $Arguments += "--skip=$Skip"
    }

    if ($null -ne $Since) {
        $Arguments += "--since=$($Since.ToString("o"))"
    }

    if ($null -ne $SinceAsFilter) {
        $Arguments += "--since-as-filter=$($SinceAsFilter.ToString("o"))"
    }

    if ($null -ne $Until) {
        $Arguments += "--until=$($Until.ToString("o"))"
    }

    # ...

    # History Simplification

    # Bisection Helpers

    # Commit Ordering

    # Object Traversal

    # Commit Formatting

    # ...

    if ($Count) {
        $Arguments += "--count"
    }

    Invoke-Git "rev-list" @Arguments
}
