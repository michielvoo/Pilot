. (Join-Path $PSScriptRoot "Invoke-Git.ps1")

# .SYNOPSIS
# Give an object a human readable name based on an available ref.
# .DESCRIPTION
# The command finds the most recent tag that is reachable from a commit. If the tag points to the
# commit, then only the tag is shown. Otherwise, it suffixes the tag name with the number of
# additional commits on top of the tagged object and the abbreviated object name of the most recent
# commit. The result is a "human-readable" object name which can also be used to identify the
# commit to other git commands.
# By default (without `-All` or `-Tags`) `Invoke-GitDescribe` only shows annotated tags.
function Invoke-GitDescribe {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # Commit-ish object names to describe. Defaults to `HEAD` if omitted.
        [Parameter(Mandatory, Position = 0)]
        [ParameterSetName("Commitish")]
        [string]$Commitish,

        # If the given object refers to a blob, it will be described as <commit-ish>:<path>, such
        # that the blob can be found at <path> in the <commit-ish>, which itself describes the
        # first commit in which this blob occurs in a reverse revision walk from `HEAD`.
        [Parameter(Mandatory, Position = 0)]
        [ParameterSetName("Blob")]
        [string]$Blob,

        # Describe the state of the working tree. When the working tree matches `HEAD`, the output
        # is the same as `Invoke-GitDescribe HEAD`. If the working tree has local modification
        # `--dirty` is appended to it. If a repository is corrupt and Git cannot determine if there
        # is a local modification, Git will error out, unless `-Broken` is given, which appends the
        # suffix `--broken` instead.
        [Alias("Broken")]
        [Parameter(Mandatory, Position = 0)]
        [ParameterSetName("Dirty")]
        [switch]$Dirty,

        # Instead of using only the annotated tags, use any ref found in `refs/` namespace. This
        # option enables matching any known branch, remote-tracking branch, or lightweight tag.
        [Parameter()]
        [ParameterSetName("Commitish")]
        [ParameterSetName("Dirty")]
        [switch]$All,

        # Instead of using only the annotated tags, use any tag found in `refs/tags` namespace.
        # This option enables matching a lightweight (non-annotated) tag.
        [Parameter()]
        [ParameterSetName("Commitish")]
        [ParameterSetName("Dirty")]
        [switch]$Tags,

        # Instead of finding the tag that predates the commit, find the tag that comes after the
        # commit, and thus contains it. Automatically implies `-Tags`.
        [Parameter()]
        [ParameterSetName("Commitish")]
        [ParameterSetName("Dirty")]
        [switch]$Contains,

        # Instead of using the default number of hexadecimal digits (which will vary according to
        # the number of objects in the repository with a default of 7) of the abbreviated object
        # name, use <n> digits, or as many digits as needed to form a unique object name. An <n>
        # of 0 will suppress long format, only showing the closest tag.
        [Parameter()]
        [ParameterSetName("Commitish")]
        [ParameterSetName("Dirty")]
        [int]$Abbrev,

        # Instead of considering only the 10 most recent tags as candidates to describe the input
        # commit-ish consider up to <n> candidates. Increasing <n> above 10 will take slightly
        # longer but may produce a more accurate result. An <n> of 0 will cause only exact matches
        # to be output.
        [Parameter()]
        [int]$Candidates,

        # Only output exact matches (a tag directly references the supplied commit). This is a
        # synonym for `-Candidates 0`.
        [Parameter()]
        [switch]$ExactMatch,

        # Verbosely display information about the searching strategy being employed to standard
        # error. The tag name will still be printed to standard out.
        [Parameter()]
        [switch]$XDebug,

        # Always output the long format (the tag, the number of commits and the abbreviated commit
        # name) even when it matches a tag. This is useful when you want to see parts of the commit
        # object name in `Invoke-GitDescribe` output, even when the commit in question happens to
        # be a tagged version. Instead of just emitting the tag name, it will describe such a
        # commit as v1.2-0-gdeadbee (0th commit since tag v1.2 that points at object deadbee).
        [Parameter()]
        [switch]$Long,

        # Only consider tags matching the given `glob(7)` pattern, excluding the "refs/tags/"
        # prefix. If used with `-All`, it also considers local branches and remote-tracking
        # references matching the pattern, excluding respectively "refs/heads/" and "refs/remotes/"
        # prefix; references of other types are never considered. If given multiple times, a list
        # of patterns will be accumulated, and tags matching any of the patterns will be
        # considered. Use `-NoMatch` to clear and reset the list of patterns.
        [Parameter()]
        [string]$Match,

        # Do not consider tags matching the given `glob(7)` pattern, excluding the "refs/tags/"
        # prefix. If used with `-All`, it also does not consider local branches and remote-tracking
        # references matching the pattern, excluding respectively "refs/heads/" and "refs/remotes/"
        # prefix; references of other types are never considered. If given multiple times, a list
        # of patterns will be accumulated and tags matching any of the patterns will be excluded.
        # When combined with `-Match` a tag will be considered when it matches at least one
        # -Match` pattern and does not match any of the `-Exclude` patterns. Use `--no-exclude` to
        # clear and reset the list of patterns.
        [Parameter()]
        [string]$Exclude,

        # Show uniquely abbreviated commit object as fallback.
        [Parameter()]
        [switch]$Always,

        # Follow only the first parent commit upon seeing a merge commit. This is useful when you
        # wish to not match tags on branches merged in the history of the target commit.
        [Parameter()]
        [switch]$FirstParent
    )

    Invoke-Git "describe" @Arguments
}