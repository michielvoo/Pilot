. (Join-Path $PSScriptRoot "Invoke-Git.ps1")

# https://git-scm.com/docs/git-show

# .SYNOPSIS
# Show various types of objects.
# .DESCRIPTION
# Shows one or more objects (blobs, trees, tags and commits). For commits it shows the log message
# and textual diff. It also presents the merge commit in a special format as produced by
# `git diff-tree --cc`. For tags, it shows the tag message and the referenced objects. For trees,
# it shows the names (equivalent to `git ls-tree` with `--name-only`). For plain blobs, it shows
# the plain contents.
function Invoke-GitShow {
    [CmdletBinding(DefaultParameterSetName = "RefSpecs")]
    [OutputType([hashtable])]
    param (
        # Pretty-print the contents of the commit logs in a given format. Defaults to `medium`.
        [Parameter()]
        [ValidateScript({ ($_ -is [bool] -and $_ -eq $true) -or $_ -is [string] })]
        [object]$Pretty,

        # Instead of showing the full 40-byte hexadecimal commit object name, show a prefix that
        # names the object uniquely.
        [Parameter()]
        [switch]$AbbrevCommit,

        # ...

        # The names of objects to show (defaults to `HEAD`).
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Objects
    )

    $Arguments = @()

    if ($null -ne $Pretty) {
        if ($Pretty -eq $true) {
            $Arguments += "--pretty"
        }
        else {
            $Arguments += "--pretty=$Pretty"
        }
    }

    if ($AbbrevCommit) {
        $Arguments += "--abbrev-commit"
    }

    # ...

    Invoke-Git "show" @Arguments @objects
}
