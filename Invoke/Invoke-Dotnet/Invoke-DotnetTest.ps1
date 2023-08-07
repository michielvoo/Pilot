. (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

# https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-test

# .SYNOPSIS
# .NET test driver used to execute unit tests.
# .DESCRIPTION
# The dotnet test command is used to execute unit tests in a given solution. The dotnet test
# command builds the solution and runs a test host application for each test project in the
# solution. The test host executes tests in the given project using a test framework, for
# example: MSTest, NUnit, or xUnit, and reports the success or failure of each test. If all tests
# are successful, the test runner returns 0 as an exit code; otherwise if any test fails, it
# returns 1.
function Invoke-DotnetTest {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        # Path to the test project, solution, a directory that contains a project or a solution, a
        # test project .dll file, or a test project .exe file. If not specified, the effect is the
        # same as specifying the current directory.
        [Parameter(Position = 0)]
        [string] $ProjectSolutionDirectoryDllOrExe,

        #
        [Alias("A")]
        [Parameter()]
        [string]$Arch,

        #
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
        [bool]$UseCurrentRuntime,

        # 
        [Parameter()]
        [string]$VersionSuffix
    )

    if ($ProjectSolutionDirectoryDllOrExe) {
        $Arguments = @($ProjectSolutionDirectoryDllOrExe)
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

    Invoke-Dotnet "test" @Arguments
}