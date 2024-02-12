. (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

# https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-pack

# .SYNOPSIS
# Packs the code into a NuGet package.
# .DESCRIPTION
# The dotnet pack command builds the project and creates NuGet packages. The result of this command
# is a NuGet package (that is, a .nupkg file).
function Invoke-DotnetPack {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # The project or solution to pack. It's either a path to a csproj, vbproj, or fsproj file,
        # or to a solution file or directory. If not specified, the command searches the current
        # directory for a project or solution file.
        [Parameter(Position = 0)]
        [string] $ProjectOrSolution,

        # Defines the build configuration. The default for most projects is Debug, but you can
        # override the build configuration settings in your project.
        [Alias("C")]
        [Parameter()]
        [string]$Configuration,

        # Forces all dependencies to be resolved even if the last restore was successful.
        # Specifying this flag is the same as deleting the project.assets.json file.
        [Parameter()]
        [switch]$Force,

        # Includes the debug symbols NuGet packages in addition to the regular NuGet packages in
        # the output directory. The sources files are included in the src folder within the
        # symbols package.
        [Parameter()]
        [switch]$IncludeSource,

        # Includes the debug symbols NuGet packages in addition to the regular NuGet packages in
        # the output directory.
        [Parameter()]
        [switch]$IncludeSymbols,

        # Allows the command to stop and wait for user input or action. For example, to complete
        # authentication.
        # Available since .NET Core 3.0 SDK.
        [Parameter()]
        [switch]$Interactive,

        # Doesn't build the project before packing. It also implicitly sets the `-NoRestore`
        # parameter.
        [Parameter()]
        [switch]$NoBuild,

        # Ignores project-to-project references and only restores the root project.
        [Parameter()]
        [switch]$NoDependencies,

        # Doesn't execute an implicit restore when running the command.
        [Parameter()]
        [switch]$NoRestore,

        # Doesn't display the startup banner or the copyright message.
        [Parameter()]
        [switch]$NoLogo,

        # Places the built packages in the directory specified.
        [Alias("O")]
        [Parameter()]
        [string]$Output,

        # Sets one or more MSBuild properties.
        [Alias("P")]
        [Parameter()]
        [hashtable]$Properties,

        # Specifies the target runtime to restore packages for. For a list of Runtime Identifiers
        # (RIDs), see the RID catalog.
        [Alias("R")]
        [Parameter()]
        [string]$Runtime,

        # Sets the serviceable flag in the package. For more information, see .NET Blog: .NET
        # Framework 4.5.1 Supports Microsoft Security Updates for .NET NuGet Libraries.
        [Alias("S")]
        [Parameter()]
        [switch]$Serviceable,

        # Sets the verbosity level of the command. Allowed values are `Q[uiet]`, `M[inimal]`,
        # `N[ormal]`, `D[etailed]`, and `Diag[nostic]`.
        [Alias("V")]
        [Parameter()]
        [string]$Verbosity,

        # Defines the value for the VersionSuffix MSBuild property. The effect of this property on
        # the package version depends on the values of the `Version` and `VersionPrefix`
        # properties.
        # If you want to use `-VersionSuffix`, specify `VersionPrefix` and not `Version` in the
        # project file. For example, if `VersionPrefix` is `0.1.2` and you pass `-VersionSuffix
        # rc.1` to `Invoke-DotnetPack`, the package version will be `0.1.2-rc.1`.
        # If `Version` has a value and you pass `-VersionSuffix` to `InvokeDotnetPack`, the value
        # specified for `-VersionSuffix` is ignored.
        [Parameter()]
        [string]$VersionSuffix
    )

    if ($ProjectOrSolution) {
        $Arguments = @($ProjectOrSolution)
    }

    if ($Configuration) {
        $Arguments += "--configuration",$Configuration
    }

    if ($Force) {
        $Arguments += "--force"
    }

    if ($IncludeSource) {
        $Arguments += "--include-source"
    }

    if ($IncludeSymbols) {
        $Arguments += "--include-symbols"
    }

    if ($Interactive) {
        $Arguments += "--interactive"
    }

    if ($NoBuild) {
        $Arguments += "--no-build"
    }

    if ($NoDependencies) {
        $Arguments += "--no-dependencies"
    }

    if ($NoRestore) {
        $Arguments += "--no-restore"
    }

    if ($NoLogo) {
        $Arguments += "--nologo"
    }

    if ($Output) {
        $Arguments += "--output",$Output
    }

    if ($Properties) {
        foreach ($property in ($Properties.GetEnumerator() | Sort-Object Name)) {
            $Arguments += "-p:$($property.Name)=$($property.Value)"
        }
    }

    if ($Runtime) {
        $Arguments += "--runtime",$Runtime
    }

    if ($Serviceable) {
        $Arguments += "--serviceable"
    }

    if ($Verbosity) {
        $Arguments += "--verbosity",$Verbosity
    }

    if ($VersionSuffix) {
        $Arguments += "--version-suffix",$VersionSuffix
    }

    Invoke-Dotnet "pack" @Arguments
}