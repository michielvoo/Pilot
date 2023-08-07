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
        # The project or solution to publish.
        [Parameter(Mandatory, Position = 0)]
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

        # 
        [Parameter()]
        [switch]$DisableBuildServers,

        # 
        [Alias("F")]
        [Parameter()]
        [string]$Framework,

        # 
        [Parameter()]
        [switch]$Force,

        # 
        [Parameter()]
        [switch]$Interactive,

        # 
        [Parameter()]
        [switch]$NoDependencies,

        # 
        [Parameter()]
        [switch]$NoIncremental,

        # 
        [Parameter()]
        [switch]$NoRestore,

        # 
        [Parameter()]
        [switch]$NoLogo,

        # 
        [Parameter()]
        [switch]$NoSelfContained,

        # 
        [Alias("O")]
        [Parameter()]
        [string]$Output,

        # 
        [Parameter()]
        [string]$OS,

        # 
        [Alias("P")]
        [Parameter()]
        [hashtable]$Properties,

        # 
        [Alias("R")]
        [Parameter()]
        [string]$Runtime,

        # 
        [Parameter()]
        [bool]$SelfContained,

        # 
        [Parameter()]
        [string]$Source,

        # 
        [Parameter()]
        [string]$TL,

        # 
        [Alias("V")]
        [Parameter()]
        [string]$Verbosity,

        # 
        [Alias("UCR")]
        [Parameter()]
        [boolean]$UseCurrentRuntime,

        # 
        [Parameter()]
        [string]$VersionSuffix
    )

    $Arguments = @($ProjectOrSolution)

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

    if ($Output) {
        $Arguments += "--output",$Output
    }

    if ($OS) {
        $Arguments += "--os",$OS
    }

    if ($Properties) {
        foreach ($property in ($Properties.GetEnumerator() | Sort-Object Name)) {
            $Arguments += "--property:$($property.Name)=$($property.Value)"
        }
    }

    if ($Runtime) {
        $Arguments += "--runtime",$Runtime
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

    if ($Source) {
        $Arguments += "--source",$Source
    }

    if ($TL) {
        $Arguments += "--tl",$TL
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