. (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

# https://learn.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference

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
        [ValidateSet($null, $true, $false)]
        [object]$DetailedSummary,

        # Causes MSBuild to construct and build a project graph. Constructing a graph involves
        # identifying project references to form dependencies. Building that graph involves
        # attempting to build project references prior to the projects that reference them,
        # differing from traditional MSBuild scheduling.
        # Requires MSBuild 16 or later.
        [Alias("Graph")]
        [Parameter()]
        [ValidateSet($null, $true, $false)]
        [object]$GraphBuild,

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
        [ValidateSet($null, $true, $false)]
        [object]$Interactive,

        # Causes MSBuild to build each project in isolation. When set to `MessageUponIsolationViolation`
        # (or its short form `Message`), only the results from top-level targets are serialized if
        # the `-OutputResultsCache` switch is supplied. This is to mitigate the chances of an
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
        [ValidateSet($null, $true, $false)]
        [object]$LowPriority = $null,

        # Specifies the maximum number of concurrent processes to use when building. If you don't
        # include this parameter, the default value is 1. If you include this parameter and
        # specify `$true`, MSBuild will use up to the number of processors in the computer.
        [Alias("M")]
        [Parameter()]
        [ValidateScript({ ($_ -is [bool] -and $_ -eq $true) -or ($_ -is [int] -and $_ -gt 0) })]
        [object]$MaxCpuCount,

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
        [ValidateSet($null, $true, $false)]
        [object]$NodeReuse,

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
        [ValidateScript({ ($_ -is [bool] -and $_ -eq $true) -or $_ -is [string] })]
        [object]$Preprocess,

        # Output cache file where MSBuild will write the contents of its build result caches at the
        # end of the build. If `-IsolateProjects` is not set, this sets it.
        [Alias("ORC")]
        [Parameter()]
        [ValidateScript({ ($_ -is [bool] -and $_ -eq $true) -or $_ -is [string] })]
        [object]$OutputResultsCache,

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

        # Write the list of available targets to the specified file (or the output device, if no
        # file is specified), without actually executing the build process.
        [Alias("TS")]
        [Parameter()]
        [ValidateScript({ ($_ -is [bool] -and $_ -eq $true) -or $_ -is [string] })]
        [object]$Targets,

        # Specifies a custom toolset. A toolset consists of tasks, targets, and tools that are used
        # to build an application.
        [Alias("TV")]
        [Parameter()]
        [string]$ToolsVersion,

        # Validate the project file and, if validation succeeds, build the project. If you don't
        # specify schema, the project is validated against the default schema. If you specify a
        # schema, the project is validated against the schema that you specify.
        [Alias("Val")]
        [Parameter()]
        [ValidateScript({ ($_ -is [bool] -and $_ -eq $true) -or $_ -is [string] })]
        [object]$Validate,

        # Specifies the amount of information to display in the build log. Each logger displays
        # events based on the verbosity level that you set for that logger. you can specify the
        # following verbosity levels: `Q[uiet]`, `M[inimal]`, `N[ormal]` (default), `D[etailed]`,
        # and `Diag[nostic]`.
        [Alias("V")]
        [Parameter()]
        [string]$Verbosity,

        # Display version information only. The project isn't built.
        [Alias("Ver")]
        [Parameter()]
        [switch]$Version,

        # List of warning codes to treats as errors. To treat all warnings as errors, use the
        # parameters with `$true`. When a warning is treated as an error the target continues
        # to execute as if it was a warning but the overall build fails.
        [Parameter()]
        [ValidateScript({ ($_ -is [bool] -and $_ -eq $true) -or $_ -is [string] -or $_ -is [string[]] })]
        [object]$WarnAsError,

        # List of warning codes that should not be promoted to errors. Specifically, if the
        # `-WarnAsError` parameter is set to promote all warnings to errors, error codes specified
        # with `-WarnNotAsError` are not promoted. This has no effect if `-WarnAsError` is not set
        # to promote all warnings to errors.

        [Parameter()]
        [ValidateScript({ ($_ -is [bool] -and $_ -eq $true) -or $_ -is [string] -or $_ -is [string[]] })]
        [object]$WarnNotAsError,

        # List of warning codes to treats as low importance messages.
        [Parameter()]
        [ValidateScript({ ($_ -is [bool] -and $_ -eq $true) -or $_ -is [string] -or $_ -is [string[]] })]
        [object]$WarnAsMessage,

        # Serializes all build events to a compressed binary file. By default the file is in the
        # current directory and named msbuild.binlog.
        [Parameter()]
        [ValidateScript({ ($_ -is [bool] -and $_ -eq $true) -or $_ -is [string] })]
        [object]$BinaryLogger,

        # The binary logger by default collects the source text of project files, including all
        # imported projects and target files encountered during the build. The optional
        # `-BinaryLoggerProjectImports` parameter controls this behavior. The default setting for
        # `-BinaryLoggerProjectImports` is `Embed`.
        [Alias("BL")]
        [Parameter()]
        [ValidateSet("Embed", "None", "ZipFile")]
        [string]$BinaryLoggerProjectImports,

        # Pass the parameters that you specify to the console logger, which displays build
        # information in the console window.
        [Alias("CLP")]
        [Parameter()]
        [hashtable]$ConsoleLoggerParameters,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$MSBuildArguments
    )

    $Arguments = @($ProjectFile)

    if ($DetailedSummary -is [bool]) {
        if ($DetailedSummary) {
            $Arguments += "-detailedSummary:True"
        }
        else {
            $Arguments += "-detailedSummary:False"
        }
    }

    if ($GraphBuild -is [bool]) {
        if ($GraphBuild) {
            $Arguments += "-graphBuild:True"
        }
        else {
            $Arguments += "-graphBuild:False"
        }
    }

    if ($IgnoreProjectExtensions.Count -gt 0) {
        $Arguments += "-ignoreProjectExtensions:$([string]::Join(";", $IgnoreProjectExtensions))"
    }

    if ($InputResultsCaches.Count -gt 0) {
        # Must use semicolon separator
        $Arguments += "-inputResultsCaches:$([string]::Join(";", $InputResultsCaches))"
    }

    if ($Interactive -is [bool]) {
        if ($Interactive) {
            $Arguments += "-interactive:True"
        }
        else {
            $Arguments += "-interactive:False"
        }
    }

    if ($IsolateProjects) {
        $Arguments += "-isolateProjects:$IsolateProjects"
    }

    if ($LowPriority -is [bool]) {
        if ($LowPriority) {
            $Arguments += "-lowPriority:True"
        }
        else {
            $Arguments += "-lowPriority:False"
        }
    }

    if ($MaxCpuCount -is [bool]) {
        $Arguments += "-maxCpuCount"
    }
    elseif ($MaxCpuCount -is [int]) {
        $Arguments += "-maxCpuCount:$MaxCpuCount"
    }

    if ($NoAutoResponse) {
        $Arguments += "-noAutoResponse"
    }

    if ($NodeReuse -is [bool]) {
        if ($NodeReuse) {
            $Arguments += "-nodeReuse:True"
        }
        else {
            $Arguments += "-nodeReuse:False"
        }
    }

    if ($NoLogo) {
        $Arguments += "-nologo"
    }

    if ($Preprocess -is [bool]) {
        $Arguments += "-preprocess"
    }
    elseif ($Preprocess -is [string]) {
        $Arguments += "-preprocess:$Preprocess"
    }

    if ($OutputResultsCache -is [bool]) {
        $Arguments += "-outputResultsCache"
    }
    elseif ($OutputResultsCache -is [string]) {
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

    if ($Targets -is [bool]) {
        $Arguments += "-targets"
    }
    elseif ($Targets -is [string]) {
        $Arguments += "-targets:$Targets"
    }

    if ($ToolsVersion) {
        $Arguments += "-toolsVersion:$ToolsVersion"
    }

    if ($Validate -is [bool]) {
        $Arguments += "-validate"
    }
    elseif ($Validate -is [string]) {
        $Arguments += "-validate:$Validate"
    }

    if ($Verbosity) {
        $Arguments += "-verbosity:$Verbosity"
    }

    if ($Version) {
        $Arguments += "-version"
    }

    if ($WarnAsError -is [bool]) {
        $Arguments += "-warnAsError"
    }
    elseif ($WarnAsError -is [string]) {
        $Arguments += "-warnAsError:$WarnAsError"
    }
    elseif ($WarnAsError -is [string[]]) {
        $Arguments += "-warnAsError:$([string]::Join(";", $WarnAsError))"
    }

    if ($WarnNotAsError -is [bool]) {
        $Arguments += "-warnNotAsError"
    }
    elseif ($WarnNotAsError -is [string]) {
        $Arguments += "-warnNotAsError:$WarnNotAsError"
    }
    elseif ($WarnNotAsError -is [array]) {
        $Arguments += "-warnNotAsError:$([string]::Join(";", $WarnNotAsError))"
    }

    if ($WarnAsMessage -is [bool]) {
        $Arguments += "-warnAsMessage"
    }
    elseif ($WarnAsMessage -is [string]) {
        $Arguments += "-warnAsMessage:$WarnAsMessage"
    }
    elseif ($WarnAsMessage -is [string[]]) {
        $Arguments += "-warnAsMessage:$([string]::Join(";", $WarnAsMessage))"
    }

    if ($null -ne $BinaryLogger) {
        $argument = "-binaryLogger"
        if ($BinaryLogger -is [string]) {
            $argument += ":LogFile=$BinaryLogger"
        }

        if ($null -ne $BinaryLoggerProjectImports) {
            $argument += ";ProjectImports=$BinaryLoggerProjectImports"
        }

        $Arguments += $argument
    }

    if ($ConsoleLoggerParameters -and $ConsoleLoggerParameters.Count -gt 0) {
        $argument = "-consoleLoggerParameters:"
        foreach ($parameter in ($ConsoleLoggerParameters.GetEnumerator() | Sort-Object Name)) {
            if ($parameter.Value -is [bool] -and $parameter.Value -eq $true) {
                $argument += "$($parameter.Name);"
            }
            else {
                $argument += "$($parameter.Name)=$($parameter.Value);"
            }
        }

        $argument = $argument.TrimEnd(";")
        $Arguments += $argument
    }

    Invoke-Dotnet "msbuild" @Arguments @MSBuildArguments
}