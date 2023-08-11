BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Dotnet
}

Describe Invoke-DotnetPack {
    It "invokes Invoke-Dotnet with command pack and arguments" {
        # Act
        $parameters = @{
            Configuration = 1
            Force = $true
            IncludeSource = $true
            IncludeSymbols = $true
            Interactive = $true
            NoBuild = $true
            NoDependencies = $true
            NoRestore = $true
            NoLogo = $true
            Output = 2
            Properties = @{
                PropertyA = "A"
                PropertyB = "B"
            }
            Runtime = 3
            Serviceable = $true
            Verbosity = 4
            VersionSuffix = 5
        }
        Invoke-DotnetPack sln @parameters

        # Assert
        Should -Invoke Invoke-Dotnet -ParameterFilter {
            $Command | Should -BeExactly "pack"
            $i = 0
            @(
                "sln"
                "--configuration", 1
                "--force"
                "--include-source"
                "--include-symbols"
                "--interactive"
                "--no-build"
                "--no-dependencies"
                "--no-restore"
                "--nologo"
                "--output", 2
                "-p:PropertyA=A"
                "-p:PropertyB=B"
                "--runtime", 3
                "--serviceable"
                "--verbosity", 4
                "--version-suffix", 5
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }
            $true
        }
    }
}