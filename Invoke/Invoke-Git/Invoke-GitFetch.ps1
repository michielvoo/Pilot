. (Join-Path $PSScriptRoot "Invoke-Git.ps1")

# https://git-scm.com/docs/git-fetch

# .SYNOPSIS
# Download objects and refs from another repository.
# .DESCRIPTION
# Fetch branches and/or tags (collectively, "refs") from one or more other repositories, along with
# the objects necessary to complete their histories. Remote-tracking branches are updated.
function Invoke-GitFetch {
    [CmdletBinding(DefaultParameterSetName = "RefSpecs")]
    [OutputType([hashtable])]
    param (
        # The "remote" repository that is the source of a fetch or pull operation. This parameter
        # can be either a URL or the name of a remote.
        [Parameter(ParameterSetName = "RefSpecs")]
        [string]$Repository,

        # Specifies which refs to fetch and which local refs to update. When no `-Refspecs` appears
        # on the command line, the refs to fetch are read from `remote.<repository>.fetch`
        # variables instead
        [Parameter(ParameterSetName = "RefSpecs")]
        [string[]]$RefSpecs,

        # A name referring to a list of repositories as the value of `remotes.<group>` in the
        # configuration file.
        [Parameter(ParameterSetName = "Group")]
        [string]$Group,

        # Allow `-Repositories` and `-Groups` parameters to be specified. No `-Refspecs` may be
        # specified.
        [Parameter(Mandatory, ParameterSetName = "Multiple")]
        [switch]$Multiple,

        # The "remote" repository that is the source of a fetch or pull operation. This parameter
        # can be either a URL or the name of a remote.
        [Parameter(ParameterSetName = "Multiple")]
        [string[]]$Repositories,

        # A name referring to a list of repositories as the value of `remotes.<group>` in the
        # configuration file.
        [Parameter(ParameterSetName = "Multiple")]
        [string[]]$Groups,

        # Fetch all remotes.
        [Parameter(Mandatory, ParameterSetName = "All")]
        [switch]$All,

        # Append ref names and object names of fetched refs to the existing contents of
        # `.git/FETCH_HEAD`. Without this option old data in `.git/FETCH_HEAD` will be overwritten.
        [Alias("A")]
        [Parameter()]
        [switch]$Append,

        # Use an atomic transaction to update local refs. Either all refs are updated, or on error,
        # no refs are updated.
        [Parameter()]
        [switch]$Atomic,

        # Limit fetching to the specified number of commits from the tip of each remote branch
        # history. If fetching to a shallow repository created by `Invoke-GitClone with the `-Depth`
        # parameter, deepen or shorten the history to the specified number of commits. Tags for the
        # deepened commits are not fetched.
        [Parameter()]
        [int]$Depth,

        # Similar to `-Depth`, except it specifies the number of commits from the current shallow
        # boundary instead of from the tip of each remote branch history.
        [Parameter()]
        [int]$Deepen,

        # ...

        # Pass `-Quiet` to git-fetch-pack and silence any other internally used git commands.
        # Progress is not reported to the standard error stream.
        [Alias("Q")]
        [Parameter()]
        [switch]$Quiet
    )

    $Arguments = @()

    # Parameter set Multiple

    if ($Multiple) {
        $Arguments += "--multiple"
    }

    # Parameter set All

    if ($All) {
        $Arguments += "--all"
    }

    # Shared parameters

    if ($Append) {
        $Arguments += "--append"
    }

    if ($Atomic) {
        $Arguments += "--atomic"
    }

    if ($Depth) {
        $Arguments += "--depth=$Depth"
    }

    if ($Deepen) {
        $Arguments += "--deepen=$Deepen"
    }

    # ...

    if ($Quiet) {
        $Arguments += "--quiet"
    }

    # Parameter set RefSpecs

    if ($Repository) {
        $Arguments += $Repository
    }

    foreach ($arg in $Refspecs) {
        $Arguments += $arg
    }

    # Parameter set Group

    if ($Group) {
        $Arguments += $Group
    }

    # Parameter set Multiple

    foreach ($arg in $Repositories) {
        $Arguments += $arg
    }

    foreach ($arg in $Groups) {
        $Arguments += $arg
    }

    Invoke-Git "fetch" @Arguments
}
