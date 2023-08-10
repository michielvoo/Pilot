. (Join-Path $PSScriptRoot "Invoke-Git.ps1")

# https://git-scm.com/docs/git-rev-parse

# .SYNOPSIS
# Pick out and massage parameters.
# .DESCRIPTION
# Many Git porcelainish commands take mixture of parameters meant for the underlying `git rev-list`
# native command they use internally and flags and parameters for the other native commands they
# use downstream of `git rev-list`. This cmdlet is used to distinguish between them.
function Invoke-GitRevParse {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # Use `Invoke-GitRevParse` in shell quoting mode. In contrast to the `-SQ parameter, this
        # mode does only quoting. Nothing else is done to command input.
        [Parameter(Position = 0, ParameterSetName = "SqQuote")]
        [switch]$SqQuote,

        # Filtering

        # Do not output flags and parameters not meant for `git rev-list` command.
        [Parameter()]
        [switch]$RevsOnly,

        # Do not output flags and parameters meant for git rev-list command.
        [Parameter()]
        [switch]$NoRevs,

        # Do not output non-flag parameters.
        [Parameter()]
        [switch]$Flags,

        # Do not output flag parameters.
        [Parameter()]
        [switch]$NoFlags,

        # Output

        # If there is no parameter given by the user, use `-Default` argument instead.
        [Parameter()]
        [string]$Default,

        # Behave as if `Invoke-GitRevParse` was invoked from this subdirectory of the working tree.
        # Any relative filenames are resolved as if they are prefixed by `-Prefix` and will be
        # printed in that form.
        [Parameter()]
        [string]$Prefix,

        # Verify that exactly one parameter is provided, and that it can be turned into a raw
        # 20-byte SHA-1 that can be used to access the object database. If so, emit it to the
        # standard output; otherwise, error out.
        [Parameter()]
        [switch]$Verify,

        # Only meaningful in `-Verify` mode. Do not output an error message if the first argument
        # is not a valid object name; instead exit with non-zero status silently. SHA-1s for valid
        # object names are printed to `stdout` on success.
        [Alias("Q")]
        [Parameter()]
        [switch]$Quiet,

        # Usually the output is made one line per flag and parameter. This option makes output a
        # single line, properly quoted for consumption by shell. Useful when you expect your
        # parameter to contain whitespaces and newlines (e.g. when using pickaxe `-S` with
        # `git diff-*`). In contrast to the `-SqQuote` parameter, the command input is still
        # interpreted as usual.
        [Parameter()]
        [switch]$SQ,

        # Same as `-Verify` but shortens the object name to a unique prefix with at least length
        # characters. The minimum length is 4, the default is the effective value of the
        # `core.abbrev` configuration variable.
        [Parameter()]
        [int]$Short,

        # When showing object names, prefix them with ^ and strip ^ prefix from the object names
        # that already have one.
        [Parameter()]
        [switch]$Not,

        # A non-ambiguous short name of the object's name. The option `core.warnAmbiguousRefs` is
        # used to select the strict abbreviation mode.
        [Parameter()]
        [ValidateScript({ ($_ -is [bool] -and $_ -eq $true) -or $_ -ieq "Loose" -or $_ -ieq "Strict" })]
        [object]$AbbrevRev,

        # Usually the object names are output in SHA-1 form (with possible ^ prefix); this option
        # makes them output in a form as close to the original input as possible.
        [Parameter()]
        [switch]$Symbolic,

        # This is similar to `-Symbolic`, but it omits input that are not refs (i.e. branch or tag
        # names; or more explicitly disambiguating "heads/master" form, when you want to name the
        # "master" branch when there is an unfortunately named tag "master"), and show them as full
        # refnames (e.g. "refs/heads/master").
        [Parameter()]
        [switch]$SymbolicFullName,

        # Args

        # Revisions to parse
        [Parameter()]
        [string[]]$Revisions,

        # File paths to parse
        [Parameter()]
        [string[]]$Paths
    )

    $Arguments = @()

    if ($SqQuote) {
        $Arguments += "--sq-quote"
    }

    # Options for Filtering

    if ($RevsOnly) {
        $Arguments += "--revs-only"
    }

    if ($NoRevs) {
        $Arguments += "--no-revs"
    }

    if ($Flags) {
        $Arguments += "--flags"
    }

    if ($NoFlags) {
        $Arguments += "--no-flags"
    }

    # Options for Output

    if ($Default) {
        $Arguments += "--default",$Default
    }

    if ($Prefix) {
        $Arguments += "--prefix",$Prefix
    }

    if ($Verify) {
        $Arguments += "--verify"
    }

    if ($Quiet) {
        $Arguments += "--quiet"
    }

    if ($SQ) {
        $Arguments += "--sq"
    }

    if ($Short) {
        $Arguments += "--short=$Short"
    }

    if ($Not) {
        $Arguments += "--not"
    }

    if ($null -ne $AbbrevRev) {
        if ($AbbrevRev -is [bool]) {
            $Arguments += "--abbrev-rev"
        }
        else {
            $Arguments += "--abbrev-rev=$($AbbrevRev.ToLower())"
        }
    }

    if ($Symbolic) {
        $Arguments += "--symbolic"
    }

    if ($SymbolicFullName) {
        $Arguments += "--symbolic-full-name"
    }

    Invoke-Git "rev-parse" @Arguments @Revisions "--" @Paths
}
