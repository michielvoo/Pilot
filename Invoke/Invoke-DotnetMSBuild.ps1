. (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

# .SYNOPSIS
# Builds a project and all of its dependencies. Note: A solution or project file may need to be
# specified if there are multiple.
# .DESCRIPTION
# The `Invoke-DotnetMSBuild` cmdlet allows access to a fully functional MSBuild. The command has
# the exact same capabilities as the existing MSBuild command-line client for SDK-style projects
# only. The options are all the same. For more information about the available options, see the
# MSBuild command-line reference. The `Invoke-DotnetBuild` cmdlet is equivalent to `Invoke-DotnetMSBuild
# -restore`. When you don't want to build the project and you have a specific target you want to
# run, use `Invoke-DotnetBuild` or `Invoke-DotnetMSBuild` and specify the target.
function Invoke-DotnetMSBuild {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # Builds the targets in the project file that you specify. You can also specify a Visual
        # Studio solution file for this parameter.
        [Parameter(Mandatory, Position = 0)]
        [string]$ProjectFile,

        # Show detailed information at the end of the build log about the configurations that were
        # built and how they were scheduled to nodes.
        [Parameter()]
        [switch]$DetailedSummary,

        # Causes MSBuild to construct and build a project graph. Constructing a graph involves
        # identifying project references to form dependencies. Building that graph involves
        # attempting to build project references prior to the projects that reference them,
        # differing from traditional MSBuild scheduling.
        # Requires MSBuild 16 or later.
        [Parameter()]
        [switch]$GraphBuild,

        # Ignore the specified extensions when determining which project file to build.
        [Parameter()]
        [string[]]$IgnoreProjectExtensions,

        # List of input cache files that MSBuild will read build results from. If
        # `-IsolateProjects` is set to `False`, this sets it to `True`.
        [Parameter()]
        [string[]]$InputResultsCaches,

        # Indicates that actions in the build are allowed to interact with the user. Do not use
        # this argument in an automated scenario where interactivity is not expected. Use the
        # parameter to override a value that comes from a response file.
        [Parameter()]
        [switch]$Interactive,

        # Causes MSBuild to build each project in isolation. When set to `MessageUponIsolationViolation`
        # (or its short form `Message`), only the results from top-level targets are serialized if
        # the -OutputResultsCache` switch is supplied. This is to mitigate the chances of an
        # isolation-violating target on a dependency project using incorrect state due to its
        # dependency on a cached target whose side effects would not be taken into account. (For
        # example, the definition of a property.) This is a more restrictive mode of MSBuild as it
        # requires that the project graph be statically discoverable at evaluation time, but can
        # improve scheduling and reduce memory overhead when building a large set of projects.
        [Parameter()]
        [string]$IsolateProjects,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$MSBuildArguments
    )

    $Arguments = @($ProjectFile)

    if ($DetailedSummary) {
        $Arguments += "-detailedSummary:True"
    }

    if ($GraphBuild) {
        $Arguments += "-graphBuild:True"
    }

    if ($IgnoreProjectExtensions.Count -gt 0) {
        $Arguments += "-ignoreProjectExtensions:$([string]::Join(",", $IgnoreProjectExtensions))"
    }

    if ($InputResultsCaches.Count -gt 0) {
        $Arguments += "-inputResultsCaches:$([string]::Join(",", $InputResultsCaches))"
    }

    if ($Interactive) {
        $Arguments += "-interactive:True"
    }

    if ($IsolateProjects) {
        $Arguments += "-isolateProjects:$IsolateProjects"
    }

    Invoke-Dotnet "msbuild" @Arguments @MSBuildArguments
}