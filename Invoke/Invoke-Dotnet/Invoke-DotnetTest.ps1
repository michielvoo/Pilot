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

        # Path to a directory to be searched for additional test adapters. Only .dll files with
        # suffix .TestAdapter.dll are inspected. If not specified, the directory of the test .dll
        # is searched.
        [Parameter()]
        [string]$TestAdapterPath,

        # Specifies the target architecture. This is a shorthand syntax for setting the Runtime
        # Identifier (RID), where the provided value is combined with the default RID. For example,
        # on a `win-x64` machine, specifying `-Arch x86` sets the RID to `win-x86`. If you use this
        # option, don't use the `-Runtime` option.
        # Available since .NET 6 Preview 7.
        [Parameter()]
        [string]$Arch,

        # Runs the tests in blame mode. This option is helpful in isolating problematic tests that
        # cause the test host to crash. When a crash is detected, it creates a sequence file in
        # TestResults/<Guid>/<Guid>_Sequence.xml that captures the order of tests that were run
        # before the crash. This option does not create a memory dump and is not helpful when the
        # test is hanging.
        [Parameter()]
        [switch]$Blame,

        # Runs the tests in blame mode and collects a crash dump when the test host exits
        # unexpectedly. This option depends on the version of .NET used, the type of error, and the
        # operating system.
        # Available since .NET 5.0 SDK.
        [Parameter()]
        [switch]$BlameCrash,

        # The type of crash dump to be collected. Supported dump types are `Full` (default), and
        # `Mini`. Implies `-BlameCrash`.
        # Available since .NET 5.0 SDK.
        [Parameter()]
        [string]$BlameCrashDumpType,

        # Collects a crash dump on expected as well as unexpected test host exit.
        # Available since .NET 5.0 SDK.
        [Parameter()]
        [switch]$BlameCrashCollectAlways,

        # Run the tests in blame mode and collects a hang dump when a test exceeds the given timeout.
        # Available since .NET 5.0 SDK.
        [Parameter()]
        [switch]$BlameHang,

        # The type of crash dump to be collected. It should be `Full`, `Mini`, or `None`. When
        # `None` is specified, test host is terminated on timeout, but no dump is collected.
        # Implies `-BlameHang`.
        # Available since .NET 5.0 SDK.
        [Parameter()]
        [string]$BlameHangDumpType,

        # Per-test timeout, after which a hang dump is triggered and the test host process and all
        # of its child processes are dumped and terminated. Implies `-Blame` and `-BlameHang`.
        # Available since .NET 5.0 SDK.
        [Parameter()]
        [timespan]$BlameHangTimeout,

        # Defines the build configuration. The default for most projects is Debug, but you can
        # override the build configuration settings in your project.
        [Alias("C")]
        [Parameter()]
        [string]$Configuration,

        # Enables data collector for the test run. For example you can collect code coverage by
        # using the `-Collect "Code Coverage"` option.
        [Parameter()]
        [string]$Collect,

        # Enables diagnostic mode for the test platform and writes diagnostic messages to the
        # specified file and to files next to it. The process that is logging the messages
        # determines which files are created, such as *.host_<date>.txt for test host log, and
        # *.datacollector_<date>.txt for data collector log.
        [Alias("D")]
        [Parameter()]
        [string]$Diag,

        # Sets the value of environment variables. Creates the variable if it does not exist,
        # overrides if it does exist. Use of this option will force the tests to be run in an
        # isolated process. The option can be specified multiple times to provide multiple
        # variables.
        [Alias("E")]
        [Parameter()]
        [hashtable]$Environment,

        # The target framework moniker (TFM) of the target framework to run tests for. The target
        # framework must also be specified in the project file.
        [Alias("F")]
        [Parameter()]
        [string]$Framework,

        # Filters tests in the current project using the given expression. Only tests that match
        # the filter expression are run.
        [Parameter()]
        [string]$Filter,

        # Allows the command to stop and wait for user input or action. For example, to complete
        # authentication.
        # Available since .NET Core 3.0 SDK.
        [Parameter()]
        [switch]$Interactive,

        # Specifies loggers for test results and optionally switches for each logger.
        [Parameter()]
        [hashtable]$Loggers,

        # Doesn't build the test project before running it. It also implicitly sets the
        # `-NoRestore` parameter.
        [Parameter()]
        [switch]$NoBuild,

        # Run tests without displaying the Microsoft TestPlatform banner.
        # Available since .NET Core 3.0 SDK.
        [Parameter()]
        [switch]$NoLogo,

        # Doesn't execute an implicit restore when running the command.
        [Parameter()]
        [switch]$NoRestore,

        # Directory in which to find the binaries to run. If not specified, the default path is
        # ./bin/<configuration>/<framework>/. For projects with multiple target frameworks (via the
        # `TargetFrameworks` property), you also need to define `-Framework` when you specify this
        # option. `Invoke-DotnetTest` always runs tests from the output directory.
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

        # The directory where the test results are going to be placed. If the specified directory
        # doesn't exist, it's created. The default is TestResults in the directory that contains
        # the project file.
        [Parameter()]
        [string]$ResultsDirectory,

        # The target runtime to test for.
        [Parameter()]
        [string]$Runtime,

        # The `.runsettings` file to use for running the tests. The `TargetPlatform` element
        # (x86|x64) has no effect for `Invoke-DotnetTest`. To run tests that target x86, install
        # the x86 version of .NET Core. The bitness of the dotnet.exe that is on the path is what
        # will be used for running tests.
        [Alias("S")]
        [Parameter()]
        [string]$Settings,

        # List the discovered tests instead of running the tests.
        [Alias("T")]
        [Parameter()]
        [switch]$ListTests,

        # Sets the verbosity level of the command. Allowed values are `Q[uiet]`, `M[inimal]`,
        # `N[ormal]`, `D[etailed]`, and `Diag[nostic]`. The default is `Minimal`.
        [Alias("V")]
        [Parameter()]
        [string]$Verbosity,

        # Inline `RunSettings` arguments.
        [Parameter()]
        [hashtable]$RunSettings,

        # Specifies extra arguments to pass to the adapter.
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$XArgs
    )

    if ($ProjectSolutionDirectoryDllOrExe) {
        $Arguments = @($ProjectSolutionDirectoryDllOrExe)
    }

    if ($TestAdapterPath) {
        $Arguments += "--test-adapter-path",$TestAdapterPath
    }

    if ($Arch) {
        $Arguments += "--arch",$Arch
    }

    if ($Blame) {
        $Arguments += "--blame"
    }

    if ($BlameCrash) {
        $Arguments += "--blame-crash"
    }

    if ($BlameCrashDumpType) {
        $Arguments += "--blame-crash-dump-type",$BlameCrashDumpType
    }

    if ($BlameCrashCollectAlways) {
        $Arguments += "--blame-crash-collect-always"
    }

    if ($BlameHang) {
        $Arguments += "--blame-hang"
    }

    if ($BlameHangDumpType) {
        $Arguments += "--blame-hang-dump-type",$BlameHangDumpType
    }

    if ($BlameHangTimeout) {
        $Arguments += "--blame-hang-timeout","$($BlameHangTimeout.TotalMilliseconds)ms"
    }

    if ($Configuration) {
        $Arguments += "--configuration",$Configuration
    }

    if ($Collect) {
        $Arguments += "--collect",$Collect
    }

    if ($Diag) {
        $Arguments += "--diag",$Diag
    }

    if ($Environment) {
        foreach ($variable in ($Environment.GetEnumerator() | Sort-Object Name)) {
            $Arguments += "--environment","$($variable.Name)=$($variable.Value)"
        }
    }

    if ($Framework) {
        $Arguments += "--framework",$Framework
    }

    if ($Filter) {
        $Arguments += "--filter",$Filter
    }

    if ($Interactive) {
        $Arguments += "--interactive"
    }

    if ($Loggers) {
        foreach ($logger in ($Loggers.GetEnumerator() | Sort-Object Name)) {
            $argument = $logger.Name

            if ($logger.Value -is [hashtable]) {
                foreach ($arg in ($logger.Value.GetEnumerator() | Sort-Object Name)) {
                    $argument += ";$($arg.Name)=$($arg.Value)"
                }
            }

            $Arguments += "--logger",$argument

        }
    }

    if ($NoBuild) {
        $Arguments += "--no-build"
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

    if ($ResultsDirectory) {
        $Arguments += "--results-directory",$ResultsDirectory
    }

    if ($Runtime) {
        $Arguments += "--runtime",$Runtime
    }

    if ($Settings) {
        $Arguments += "--settings",$Settings
    }

    if ($ListTests) {
        $Arguments += "--list-tests"
    }

    if ($Verbosity) {
        $Arguments += "--verbosity",$Verbosity
    }

    foreach ($arg in $XArgs) {
        $Arguments += $arg
    }

    if ($RunSettings) {
        $Arguments += "--"

        foreach ($runSetting in ($RunSettings.GetEnumerator() | Sort-Object Name)) {
            $Arguments += "$($runSetting.Name)=$($runSetting.Value)"
        }
    }

    Invoke-Dotnet "test" @Arguments
}