BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Dotnet
}

Describe Invoke-DotnetBuild {
    It "invokes Invoke-Dotnet with command build and arguments" {
        # Act
        $parameters = @{
            Arch = 1
            Configuration = 2
            DisableBuildServers = $true
            Framework = 3
            Force = $true
            Interactive = $true
            NoDependencies = $true
            NoIncremental = $true
            NoRestore = $true
            NoLogo = $true
            NoSelfContained = $true
            Output = 4
            OS = 5
            Properties = @{
                PropertyB = "B"
                PropertyA = "A"
                PropertyC = "C"
            }
            Runtime = 6
            SelfContained = $true
            Source = 7
            TL = 8
            Verbosity = 9
            UseCurrentRuntime = $true
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
                "--disable-build-servers"
                "--framework", 3
                "--force"
                "--interactive"
                "--no-dependencies"
                "--no-incremental"
                "--no-restore"
                "--nologo"
                "--no-self-contained"
                "--output", 4
                "--os", 5
                "--property:PropertyA=A"
                "--property:PropertyB=B"
                "--property:PropertyC=C"
                "--runtime", 6
                "--self-contained", "true"
                "--source", 7
                "--tl", 8
                "--verbosity", 9
                "--use-current-runtime", "true"
                "--version-suffix", 10
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }
            $true
        }
    }
}