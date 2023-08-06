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
        [Alias("DS")]
        [Parameter()]
        [switch]$DetailedSummary,

        # Causes MSBuild to construct and build a project graph. Constructing a graph involves
        # identifying project references to form dependencies. Building that graph involves
        # attempting to build project references prior to the projects that reference them,
        # differing from traditional MSBuild scheduling.
        # Requires MSBuild 16 or later.
        [Alias("Graph")]
        [Parameter()]
        [switch]$GraphBuild,

        # Ignore the specified extensions when determining which project file to build.
        [Alias("Ignore")]
        [Parameter()]
        [string[]]$IgnoreProjectExtensions,

        # List of input cache files that MSBuild will read build results from. If
        # `-IsolateProjects` is set to `False`, this sets it to `True`.
        [Alias("IRC")]
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
        [Alias("Isolate")]
        [Parameter()]
        [string]$IsolateProjects,

        # Causes MSBuild to run at low process priority.
        [Alias("Low")]
        [Parameter()]
        [switch]$LowPriority,

        # Specifies the maximum number of concurrent processes to use when building. If you don't
        # include this switch, the default value is 1.
        # TODO: If you include this switch without specifying a value, MSBuild will use up to the
        # number of processors in the computer.
        [Alias("M")]
        [Parameter()]
        [int]$MaxCpuCount,

        # Don't include any MSBuild.rsp or Directory.Build.rsp files automatically.
        [Alias("NoAutoRsp")]
        [Parameter()]
        [switch]$NoAutoResponse,

        # Enable or disable the re-use of MSBuild nodes. You can specify the following values:
        # $true. Nodes remain after the build finishes so that subsequent builds can use them (default).
        # $false. Nodes don't remain after the build completes.
        # A node corresponds to a project that's executing. If you include the `-MaxCpuCount`
        # switch, multiple nodes can execute concurrently.
        [Alias("NR")]
        [Parameter()]
        [switch]$NodeReuse,

        # Don't display the startup banner or the copyright message.
        [Parameter()]
        [switch]$NoLogo,

        # Create a single, aggregated project file by inlining all the files that would be imported
        # during a build, with their boundaries marked. You can use this switch to more easily
        # determine which files are being imported, from where the files are being imported, and
        # which files contribute to the build. When you use this switch, the project isn't built.
        # If you specify a filepath, the aggregated project file is output to the file. Otherwise,
        # the output appears in the console window.
        [Alias("PP")]
        [Parameter()]
        [string]$Preprocess,

        # Output cache file where MSBuild will write the contents of its build result caches at the
        # end of the build. If `-IsolateProjects` is not set, this sets it.
        [Alias("ORC")]
        [Parameter()]
        [string]$OutputResultsCache,

        # Profiles MSBuild evaluation and writes the result to the specified file. If the extension
        # of the specified file is '.md', the result is generated in Markdown format. Otherwise, a
        # tab-separated file is produced.
        [Parameter()]
        [string]$ProfileEvaluation,

        # Set or override the specified project-level properties.
        [Alias("P")]
        [Parameter()]
        [hashtable]$Properties,

        # Runs the `Restore` target prior to building the actual targets.
        [Alias("R")]
        [Parameter()]
        [switch]$Restore,

        # Set or override these project-level properties only during restore and do not use
        # properties specified with the `-Properties` parameter.
        [Alias("RP")]
        [Parameter()]
        [hashtable]$RestoreProperties,

        # Build the specified targets in the project. If you specify any targets by using this
        # parameter, they are run instead of any targets in the `DefaultTargets` attribute in the
        # project file.
        [Alias("T")]
        [Parameter()]
        [string[]]$Target,

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

    if ($LowPriority) {
        $Arguments += "-lowPriority:True"
    }

    if ($MaxCpuCount) {
        $Arguments += "-maxCpuCount:$MaxCpuCount"
    }

    if ($NoAutoResponse) {
        $Arguments += "-noAutoResponse"
    }

    if ($NodeReuse) {
        $Arguments += "-nodeReuse:True"
    }

    if ($NoLogo) {
        $Arguments += "-nologo"
    }

    if ($Preprocess) {
        $Arguments += "-preprocess:$Preprocess"
    }

    if ($OutputResultsCache) {
        $Arguments += "-outputResultsCache:$OutputResultsCache"
    }

    if ($ProfileEvaluation) {
        $Arguments += "-profileEvaluation:$ProfileEvaluation"
    }

    if ($Properties) {
        foreach ($property in ($Properties.GetEnumerator() | Sort-Object Name)) {
            $Arguments += "-property:$($property.Name)=$($property.Value)"
        }
    }

    if ($Restore) {
        $Arguments += "-restore"
    }

    if ($RestoreProperties) {
        foreach ($restoreProperty in ($RestoreProperties.GetEnumerator() | Sort-Object Name)) {
            $Arguments += "-restoreProperty:$($restoreProperty.Name)=$($restoreProperty.Value)"
        }
    }

    if ($Target) {
        $Arguments += "-target:$([string]::Join(",", $Target))"
    }

    Invoke-Dotnet "msbuild" @Arguments @MSBuildArguments
}