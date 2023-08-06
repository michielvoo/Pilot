BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
    . (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

    Mock Invoke-Dotnet {}
}

Describe Invoke-DotnetBuild {
    It "invokes dotnet with command build and arguments" {
        # Act
        $parameters = @{
            Arch = 1
            Configuration = 2
            Framework = 3
            DisableBuildServers = $true
            Force = $true
            Interactive = $true
            NoDependencies = $true
            NoIncremental = $true
            NoRestore = $true
            NoLogo = $true
            NoSelfContained = $true
            OS = 4
            Output = 5
            Properties = @{
                PropertyA = "a"
                PropertyB = "b"
            }
            Runtime = 6
            SelfContained = $true
            Source = 7
            TL = 8
            UseCurrentRuntime = $true
            Verbosity = 9
            VersionSuffix = 10
        }
        Invoke-DotnetBuild sln @parameters

        # Assert
        Should -Invoke Invoke-Dotnet -ParameterFilter {
            $Command | Should -BeExactly "build"
            $i = 0
            @(
                "sln"
                "--arch", 1
                "--configuration", 2
                "--framework", 3
                "--disable-build-servers"
                "--force"
                "--interactive"
                "--no-dependencies"
                "--no-incremental"
                "--no-restore"
                "--nologo"
                "--no-self-contained"
                "--os", 4
                "--output", 5
                "--property:PropertyA=A"
                "--property:PropertyB=x"
                "--runtime", 6
                "--self-contained"
                "--source", 7
                "--tl", 8
                "--use-current-runtime"
                "--verbosity", 9
                "--version-suffix", 10
            ) | ForEach-Object -Begin {
                $Arguments[$i++] | Should -Be $_
            }
            $true
        }
    }
}