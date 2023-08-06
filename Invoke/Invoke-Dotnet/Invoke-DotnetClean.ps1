. (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

# https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-clean

# .SYNOPSIS
# Cleans the output of a project.
# .DESCRIPTION
# The `Invoke-DotnetClean` cmdlet cleans the output of the previous build. It's implemented as an
# MSBuild target, so the project is evaluated when the command is run. Only the outputs created
# during the build are cleaned. Both intermediate (obj) and final output (bin) folders are cleaned.
function Invoke-DotnetClean {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # The MSBuild project or solution to clean. If a project or solution file is not specified,
        # MSBuild searches the current working directory for a file that has a file extension that
        # ends in proj or sln, and uses that file.
        [Parameter(Position = 0)]
        [string] $ProjectOrSolution,

        # Defines the build configuration. The default for most projects is `Debug`, but you can
        # override the build configuration settings in your project. This option is only required
        # when cleaning if you specified it during build time.
        [Alias("C")]
        [Parameter()]
        [string]$Configuration,

        # The framework that was specified at build time. The framework must be defined in the
        # project file. If you specified the framework at build time, you must specify the
        # framework when cleaning.
        [Alias("F")]
        [Parameter()]
        [string]$Framework,

        # Allows the command to stop and wait for user input or action. For example, to complete
        # authentication.
        # Available since .NET Core 3.0 SDK.
        [Parameter()]
        [switch]$Interactive,

        # Doesn't display the startup banner or the copyright message.
        [Parameter()]
        [switch]$NoLogo,

        # The directory that contains the build artifacts to clean. Specify the `-Framework`
        # parameter with the `-Output` parameter if you specified the framework when the project
        # was built.
        [Alias("O")]
        [Parameter()]
        [string]$Output,

        # Cleans the output folder of the specified runtime. This is used when a self-contained
        # deployment was created.
        [Alias("R")]
        [Parameter()]
        [string]$Runtime,

        # Sets the verbosity level of the command. Allowed values are `Q[uiet]`, `M[inimal]`,
        # `N[ormal]`, `D[etailed]`, and `Diag[nostic]`. The default is `Normal`.
        [Alias("V")]
        [Parameter()]
        [string]$Verbosity
    )

    if ($ProjectOrSolution) {
        $Arguments = @($ProjectOrSolution)
    }

    if ($Configuration) {
        $Arguments += "--configuration",$Configuration
    }

    if ($Framework) {
        $Arguments += "--framework",$Framework
    }

    if ($Interactive) {
        $Arguments += "--interactive"
    }

    if ($NoLogo) {
        $Arguments += "--nologo"
    }

    if ($Output) {
        $Arguments += "--output",$Output
    }

    if ($Runtime) {
        $Arguments += "--runtime",$Runtime
    }

    if ($Verbosity) {
        $Arguments += "--verbosity",$Verbosity
    }

    Invoke-Dotnet "clean" @Arguments
}