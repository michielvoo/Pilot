. (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

# https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-restore

# .SYNOPSIS
# Restores the dependencies and tools of a project.
# .DESCRIPTION
# A .NET project typically references external libraries in NuGet packages that provide additional
# functionality. These external dependencies are referenced in the project file (.csproj or
# .vbproj). When you run the `Invoke-DotnetRestore` command, the .NET CLI uses NuGet to look for
# these dependencies and download them if necessary. It also ensures that all the dependencies
# required by the project are compatible with each other and that there are no conflicts between
# them. Once the command is completed, all the dependencies required by the project are available
# in a local cache and can be used by the .NET CLI to build and run the application.
function Invoke-DotnetRestore {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # Optional path to the project file to restore.
        [Parameter(Position = 0)]
        [string] $Root,

        # The NuGet configuration file (nuget.config) to use. If specified, only the settings from
        # this file will be used. If not specified, the hierarchy of configuration files from the
        # current directory will be used.
        [Parameter()]
        [string]$ConfigFile,

        # Forces the command to ignore any persistent build servers. This option provides a
        # consistent way to disable all use of build caching, which forces a build from scratch. A
        # build that doesn't rely on caches is useful when the caches might be corrupted or
        # incorrect for some reason.
        # Available since .NET 7 SDK.
        [Parameter()]
        [switch]$DisableBuildServers,

        # Disables restoring multiple projects in parallel.
        [Parameter()]
        [switch]$DisableParallel,

        # Forces all dependencies to be resolved even if the last restore was successful.
        # Specifying this flag is the same as deleting the project.assets.json file.
        [Parameter()]
        [switch]$Force,

        # Forces restore to reevaluate all dependencies even if a lock file already exists.
        [Parameter()]
        [switch]$ForceEvaluate,

        # Only warn about failed sources if there are packages meeting the version requirement.
        [Parameter()]
        [switch]$IgnoreFailedSources,

        # Allows the command to stop and wait for user input or action. For example, to complete
        # authentication.
        [Parameter()]
        [switch]$Interactive,

        # Output location where project lock file is written. By default, this is PROJECT_ROOT\packages.lock.json.
        [Parameter()]
        [string]$LockFilePath,

        # Don't allow updating project lock file.
        [Parameter()]
        [switch]$LockedMode,

        # Specifies to not cache HTTP requests.
        [Parameter()]
        [switch]$NoCache,

        # When restoring a project with project-to-project (P2P) references, restores the root
        # project and not the references.
        [Parameter()]
        [switch]$NoDependencies,

        # Specifies the directory for restored packages.
        [Parameter()]
        [string]$Packages,

        # Specifies a runtime for the package restore. This is used to restore packages for
        # runtimes not explicitly listed in the `<RuntimeIdentifiers>` tag in the .csproj file. For
        #  a list of Runtime Identifiers (RIDs), see the RID catalog.
        [Alias("R")]
        [Parameter()]
        [string]$Runtime,

        # Specifies the URI of the NuGet package source to use during the restore operation. This
        # setting overrides all of the sources specified in the nuget.config files. Multiple
        # sources can be provided by specifying this option multiple times.
        [Alias("S")]
        [Parameter()]
        [string]$Source,

        # Sets the `RuntimeIdentifier` to a platform portable `RuntimeIdentifier` based on the one
        # of your machine. This happens implicitly with properties that require a
        # `RuntimeIdentifier`, such as `SelfContained`, `PublishAot`, `PublishSelfContained`,
        # `PublishSingleFile`, and `PublishReadyToRun`. If the property is set to `$false`, that
        # implicit resolution will no longer occur.
        [Alias("UCR")]
        [Parameter()]
        [bool]$UseCurrentRuntime,

        # Enables project lock file to be generated and used with restore.
        [Parameter()]
        [switch]$UseLockFile,

        # Sets the verbosity level of the command. Allowed values are `Q[uiet]`, `M[inimal]`,
        # `N[ormal]`, `D[etailed]`, and `Diag[nostic]`. The default is `Minimal`.
        [Alias("V")]
        [Parameter()]
        [string]$Verbosity
    )

    if ($Root) {
        $Arguments = @($Root)
    }

    if ($ConfigFile) {
        $Arguments += "--configfile",$ConfigFile
    }

    if ($DisableBuildServers) {
        $Arguments += "--disable-build-servers"
    }

    if ($DisableParallel) {
        $Arguments += "--disable-parallel"
    }

    if ($Force) {
        $Arguments += "--force"
    }

    if ($ForceEvaluate) {
        $Arguments += "--force-evaluate"
    }

    if ($IgnoreFailedSources) {
        $Arguments += "--ignore-failed-sources"
    }

    if ($Interactive) {
        $Arguments += "--interactive"
    }

    if ($LockFilePath) {
        $Arguments += "--lock-file-path",$LockFilePath
    }

    if ($LockedMode) {
        $Arguments += "--locked-mode"
    }

    if ($NoCache) {
        $Arguments += "--no-cache"
    }

    if ($NoDependencies) {
        $Arguments += "--no-dependencies"
    }

    if ($Packages) {
        $Arguments += "--packages",$Packages
    }

    if ($Runtime) {
        $Arguments += "--runtime",$Runtime
    }

    if ($Source) {
        $Arguments += "--source",$Source
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

    if ($null -ne $UseCurrentRuntime) {
        $Arguments += "--use-current-runtime"
        if ($UseCurrentRuntime) {
            $Arguments += "true"
        }
        else {
            $Arguments += "false"
        }
    }

    if ($UseLockFile) {
        $Arguments += "--use-lock-file"
    }

    if ($Verbosity) {
        $Arguments += "--verbosity",$Verbosity
    }

    Invoke-Dotnet "restore" @Arguments
}