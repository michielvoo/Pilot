. (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

# .SYNOPSIS
# Builds a project and all of its dependencies.
function Invoke-DotnetBuild {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # The project or solution file to build.
        [Parameter(Mandatory, Position = 0)]
        [string] $Solution,

        # Specifies the target architecture. This is a shorthand syntax for setting the Runtime
        # Identifier (RID), where the provided value is combined with the default RID. For example,
        # on a `win-x64` machine, specifying `-Arch x86` sets the RID to `win-x86`. If you use this
        # parameter, don't use the `-Runtime` parameter.
        # Available since .NET 6 Preview 7.
        [Alias("A")]
        [Parameter()]
        [string]$Arch,

        # Defines the build configuration. The default for most projects is Debug, but you can
        # override the build configuration settings in your project.
        [Alias("C")]
        [Parameter()]
        [string]$Configuration,

        # Compiles for a specific framework. The framework must be defined in the project file.
        # Examples: `net7.0`, `net462`.
        [Alias("F")]
        [Parameter()]
        [string]$Framework,

        # Forces the command to ignore any persistent build servers. This option provides a
        # consistent way to disable all use of build caching, which forces a build from scratch.
        # A build that doesn't rely on caches is useful when the caches might be corrupted or
        # incorrect for some reason.
        # Available since .NET 7 SDK.
        [Parameter()]
        [switch]$DisableBuildServers,

        # Forces all dependencies to be resolved even if the last restore was successful.
        # Specifying this flag is the same as deleting the project.assets.json file.
        [Parameter()]
        [switch]$Force,

        # Allows the command to stop and wait for user input or action. For example, to complete
        # authentication.
        # Available since .NET Core 3.0 SDK.
        [Parameter()]
        [switch]$Interactive,

        # Ignores project-to-project (P2P) references and only builds the specified root project.
        [Parameter()]
        [switch]$NoDependencies,

        # Marks the build as unsafe for incremental build. This flag turns off incremental
        # compilation and forces a clean rebuild of the project's dependency graph.
        [Parameter()]
        [switch]$NoIncremental,

        # Doesn't execute an implicit restore during build.
        [Parameter()]
        [switch]$NoRestore,

        # Doesn't display the startup banner or the copyright message.
        [Parameter()]
        [switch]$NoLogo,

        # Publishes the application as a framework dependent application. A compatible .NET runtime
        # must be installed on the target machine to run the application.
        # Available since .NET 6 SDK.
        [Parameter()]
        [switch]$NoSelfContained,

        # Specifies the target operating system (OS). This is a shorthand syntax for setting the
        # Runtime Identifier (RID), where the provided value is combined with the default RID. For
        # example, on a `win-x64` machine, specifying `-OS linux` sets the RID to `linux-x64`. If
        # you use this parameter, don't use the `-Runtime` parameter.
        # Available since .NET 6.
        [Parameter()]
        [string]$OS,

        # Directory in which to place the built binaries. If not specified, the default path is
        # `./bin/<configuration>/<framework>/`. For projects with multiple target frameworks (via
        # the `TargetFrameworks` property), you also need to define `-Framework` when you specify
        # this option.
        [Alias("O")]
        [Parameter()]
        [string]$Output,

        # Sets one or more MSBuild properties.
        [Alias("P")]
        [Parameter()]
        [hashtable]$Properties,

        # Specifies the target runtime. For a list of Runtime Identifiers (RIDs), see the RID
        # catalog. If you use this option with .NET 6 SDK, use `-SelfContained` or
        # `-NoSelfContained` also. If not specified, the default is to build for the current OS and
        # architecture.
        [Alias("R")]
        [Parameter()]
        [string]$Runtime,

        # Publishes the .NET runtime with the application so the runtime doesn't need to be
        # installed on the target machine. The default is `$true` if a runtime identifier is
        # specified.
        # Available since .NET 6.
        [Parameter()]
        [switch]$SelfContained,

        # The URI of the NuGet package source to use during the restore operation.
        [Parameter()]
        [string]$Source,

        # Specifies whether the terminal logger should be used for the build output. The default is
        # `Auto`, which first verifies the environment before enabling terminal logging. The
        # environment check verifies that the terminal is capable of using modern output features
        # and isn't using a redirected standard output before enabling the new logger. `On` skips
        # the environment check and enables terminal logging. `Off` skips the environment check and
        # uses the default console logger.
        # This option is available starting in .NET 8.
        [Parameter()]
        [string]$TL,

        # Sets the `RuntimeIdentifier` to a platform portable `RuntimeIdentifier` based on the one
        # of your machine. This happens implicitly with properties that require a `RuntimeIdentifier`,
        # such as `SelfContained`, `PublishAot`, `PublishSelfContained`, `PublishSingleFile`, and
        # `PublishReadyToRun`. If the property is set to false, that implicit resolution will no
        # longer occur.
        [Alias("UCR")]
        [Parameter()]
        [switch]$UseCurrentRuntime,

        # Sets the verbosity level of the command. Allowed values are `Q[uiet]`, `M[inimal]`,
        # `N[ormal]`, `D[etailed]`, and `Diag[nostic]`. The default is `Minimal`. By default,
        # MSBuild displays warnings and errors at all verbosity levels. To exclude warnings, use
        # `-Properties @{ WarningLevel = 0 }`.
        [Parameter()]
        [string]$Verbosity,

        # Sets the value of the `$(VersionSuffix)` property to use when building the project. This
        # only works if the `$(Version)` property isn't set. Then, `$(Version)` is set to the
        # `$(VersionPrefix)` combined with the `$(VersionSuffix)`, separated by a dash.
        [Parameter()]
        [string]$VersionSuffix
    )

    $Arguments = @($Solution)

    if ($Arch) {
        $Arguments += "--arch",$Arch
    }

    if ($Configuration) {
        $Arguments += "--configuration",$Configuration
    }

    if ($Framework) {
        $Arguments += "--framework",$Framework
    }

    if ($DisableBuildServers) {
        $Arguments += "--disable-build-servers"
    }

    if ($Force) {
        $Arguments += "--force"
    }

    if ($Interactive) {
        $Arguments += "--interactive"
    }

    if ($NoDependencies) {
        $Arguments += "--no-dependencies"
    }

    if ($NoIncremental) {
        $Arguments += "--no-incremental"
    }

    if ($NoRestore) {
        $Arguments += "--no-restore"
    }

    if ($NoLogo) {
        $Arguments += "--nologo"
    }

    if ($NoSelfContained) {
        $Arguments += "--no-self-contained"
    }

    if ($OS) {
        $Arguments += "--os",$OS
    }

    if ($Output) {
        $Arguments += "--output",$Output
    }

    if ($Properties) {
        foreach ($property in $Properties.GetEnumerator()) {
            $Arguments += "--property:$($property.Name)=$($property.Value)"
        }
    }

    if ($Runtime) {
        $Arguments += "--runtime",$Runtime
    }

    if ($SelfContained) {
        $Arguments += "--self-contained"
    }

    if ($Source) {
        $Arguments += "--source",$Source
    }

    if ($TL) {
        $Arguments += "--tl",$TL
    }

    if ($UseCurrentRuntime) {
        $Arguments += "--use-current-runtime"
    }

    if ($Verbosity) {
        $Arguments += "--verbosity",$Verbosity
    }

    if ($VersionSuffix) {
        $Arguments += "--version-suffix",$VersionSuffix
    }

    Invoke-Dotnet "build" @Arguments
}