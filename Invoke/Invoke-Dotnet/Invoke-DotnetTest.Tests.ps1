BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Dotnet
}

Describe Invoke-DotnetTest {
    It "invokes Invoke-Dotnet with command test and arguments" {
        # Act
        $parameters = @{
            TestAdapterPath = 1
            Arch = 2
            Blame = $true
            BlameCrash = $true
            BlameCrashDumpType = 3
            BlameCrashCollectAlways = $true
            BlameHang = $true
            BlameHangDumpType = 4
            BlameHangTimeout = ([timespan]::FromSeconds(12))
            Configuration = 5
            Collect = 6
            Diag = 7
            Framework = 8
            Environment = @{
                EnvC = "C"
                EnvA = "A"
                EnvB = "B"
            }
            Filter = 9
            Interactive = $true
            Logger = @{
                l1 = $null
                l2 = @{
                    LogF = "F"
                    LogD = "D"
                    LogE = "E"
                }
            }
            NoBuild = $true
            NoLogo = $true
            NoRestore = $true
            Output = 10
            OS = 11
            ResultsDirectory = 12
            Runtime = 13
            Settings = 14
            ListTests = $true
            Verbosity = 15
            RunSettings = @{
                SettingI = "I"
                SettingG = "G"
                SettingH = "H"
            }
        }
        Invoke-DotnetTest sln @parameters -option arg 

        # Assert
        Should -Invoke Invoke-Dotnet -ParameterFilter {
            $Command | Should -BeExactly "test"
            $i = 0
            @(
                "sln"
                "--test-adapter-path", 1
                "--arch", 2
                "--blame"
                "--blame-crash"
                "--blame-crash-dump-type", 3
                "--blame-crash-collect-always"
                "--blame-hang"
                "--blame-hang-dump-type", 4
                "--blame-hang-timeout", "12000ms"
                "--configuration", 5
                "--collect", 6
                "--diag", 7
                "--environment", "EnvA=A"
                "--environment", "EnvB=B"
                "--environment", "EnvC=C"
                "--framework", 8
                "--filter", 9
                "--interactive"
                "--logger", "l1"
                "--logger", "l2;LogD=D;LogE=E;LogF=F"
                "--no-build"
                "--nologo"
                "--no-restore"
                "--output", 10
                "--os", 11
                "--results-directory", 12
                "--runtime", 13
                "--settings", 14
                "--list-tests"
                "--verbosity", 15
                "-option", "arg"
                "--"
                "SettingG=G"
                "SettingH=H"
                "SettingI=I"
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }
            $true
        }
    }
}