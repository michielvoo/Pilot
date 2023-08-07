. (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

# https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-publish

# .SYNOPSIS
# Publishes the application and its dependencies to a folder for deployment to a hosting system.
# .DESCRIPTION
# `Invoke-DotnetPublish` compiles the application, reads through its dependencies specified in the
# project file, and publishes the resulting set of files to a directory.
function Invoke-DotnetPublish {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # The project or solution to publish. Defaults to the current directory.
        [Parameter(Position = 0)]
        [string] $ProjectOrSolution,

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

        # Forces the command to ignore any persistent build servers. This option provides a
        # consistent way to disable all use of build caching, which forces a build from scratch.
        # A build that doesn't rely on caches is useful when the caches might be corrupted or
        # incorrect for some reason.
        # Available since .NET 7 SDK.
        [Parameter()]
        [switch]$DisableBuildServers,

        # Publishes the application for the specified target framework. You must specify the target
        # framework in the project file.
        [Alias("F")]
        [Parameter()]
        [string]$Framework,

        # Forces all dependencies to be resolved even if the last restore was successful.
        # Specifying this flag is the same as deleting the project.assets.json file.
        [Parameter()]
        [switch]$Force,

        # Allows the command to stop and wait for user input or action. For example, to complete
        # authentication.
        # Available since .NET Core 3.0 SDK.
        [Parameter()]
        [switch]$Interactive,

        # Specifies one or several target manifests to use to trim the set of packages published
        # with the app. The manifest file is part of the output of the dotnet store command.
        [Parameter()]
        [string[]]$Manifest,

        # Doesn't build the project before publishing. It also implicitly sets the `-NoRestore`
        # parameter.
        [Parameter()]
        [switch]$NoBuild,

        # Ignores project-to-project references and only restores the root project.
        [Parameter()]
        [switch]$NoDependencies,

        # Doesn't display the startup banner or the copyright message.
        [Parameter()]
        [switch]$NoLogo,

        # Doesn't execute an implicit restore when running the command.
        [Parameter()]
        [switch]$NoRestore,

        # Specifies the path for the output directory. If not specified, it defaults to
        # [project_file_folder]/bin/[configuration]/[framework]/publish/ for a
        # framework-dependent executable and cross-platform binaries. It defaults to
        # [project_file_folder]/bin/[configuration]/[framework]/[runtime]/publish/ for a
        # self-contained executable.
        [Alias("O")]
        [Parameter()]
        [string]$Output,

        # Specifies the target operating system (OS). This is a shorthand syntax for setting the
        # Runtime Identifier (RID), where the provided value is combined with the default RID. For
        # example, on a `win-x64` machine, specifying `-OS linux` sets the RID to `linux-x64`. If
        # you use this option, don't use the `-Runtime` option.
        # Available since .NET 6.
        [Parameter()]
        [string]$OS,

        # Publishes the .NET runtime with your application so the runtime doesn't need to be
        # installed on the target machine. Default is `$true` if a runtime identifier is specified
        # and the project is an executable project (not a library project).
        [Alias("SC")]
        [Parameter()]
        [bool]$SelfContained,

        # Equivalent to `-SelfContained $false`.
        [Parameter()]
        [switch]$NoSelfContained,


        # The URI of the NuGet package source to use during the restore operation.
        [Parameter()]
        [string]$Source,

        # Publishes the application for a given runtime. For a list of Runtime Identifiers (RIDs),
        # see the RID catalog. If you use this option, use `-SelfContained` or `-NoSelfContained`
        # also.
        [Alias("R")]
        [Parameter()]
        [string]$Runtime,

        # Sets the verbosity level of the command. Allowed values are `Q[uiet]`, `M[inimal]`,
        # `N[ormal]`, `D[etailed]`, and `Diag[nostic]`. The default is `Minimal`.
        [Alias("V")]
        [Parameter()]
        [string]$Verbosity,

        # Sets the `RuntimeIdentifier` to a platform portable `RuntimeIdentifier` based on the one
        # of your machine. This happens implicitly with properties that require a
        #`RuntimeIdentifier`, such as `SelfContained`, `PublishAot`, `PublishSelfContained`,
        # `PublishSingleFile`, and `PublishReadyToRun`. If the property is set to `false`, that
        # implicit resolution will no longer occur.
        [Alias("UCR")]
        [Parameter()]
        [bool]$UseCurrentRuntime,

        # Defines the version suffix to replace the asterisk (`*`) in the version field of the
        # project file.
        [Parameter()]
        [string]$VersionSuffix
    )

    if ($ProjectOrSolution) {
        $Arguments = @($ProjectOrSolution)
    }

    if ($Arch) {
        $Arguments += "--arch",$Arch
    }

    if ($Configuration) {
        $Arguments += "--configuration",$Configuration
    }

    if ($DisableBuildServers) {
        $Arguments += "--disable-build-servers"
    }

    if ($Framework) {
        $Arguments += "--framework",$Framework
    }

    if ($Force) {
        $Arguments += "--force"
    }

    if ($Interactive) {
        $Arguments += "--interactive"
    }

    if ($Manifest) {
        foreach ($value in $Manifest) {
            $Arguments += "--manifest", $value
        }
    }

    if ($NoBuild) {
        $Arguments += "--no-build"
    }

    if ($NoDependencies) {
        $Arguments += "--no-dependencies"
    }

    if ($NoLogo) {
        $Arguments += "--nologo"
    }

    if ($NoRestore) {
        $Arguments += "--no-restore"
    }

    if ($Output) {
        $Arguments += "--output",$Output
    }

    if ($OS) {
        $Arguments += "--os",$OS
    }

    if ($null -ne $SelfContained) {
        $Arguments += "--self-contained"
        if ($SelfContained) {
            $Arguments += "true"
        }
        else {
            $Arguments += "false"
        }
    }

    if ($NoSelfContained) {
        $Arguments += "--no-self-contained"
    }

    if ($Source) {
        $Arguments += "--source",$Source
    }

    if ($Runtime) {
        $Arguments += "--runtime",$Runtime
    }

    if ($Verbosity) {
        $Arguments += "--verbosity",$Verbosity
    }

    if ($null -ne $UseCurrentRuntime) {
        $Arguments += "--use-current-runtime"
        if ($UseCurrentRuntime) {
            $Arguments += "true"
        }
        else {
            $Arguments += "false"
        }
    }

    if ($VersionSuffix) {
        $Arguments += "--version-suffix",$VersionSuffix
    }

    Invoke-Dotnet "publish" @Arguments
}