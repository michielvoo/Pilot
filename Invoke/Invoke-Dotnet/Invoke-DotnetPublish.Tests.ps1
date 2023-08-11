BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Dotnet
}

Describe Invoke-DotnetPublish {
    It "invokes Invoke-Dotnet with command publish and arguments" {
        # Act
        $parameters = @{
            Arch = 1
            Configuration = 2
            DisableBuildServers = $true
            Framework = 3
            Force = $true
            Interactive = $true
            Manifest = @("m1", "m2")
            NoBuild = $true
            NoDependencies = $true
            NoLogo = $true
            NoRestore = $true
            Output = 4
            OS = 5
            SelfContained = $true
            NoSelfContained = $true
            Source = 6
            Runtime = 7
            Verbosity = 8
            UseCurrentRuntime = $true
            VersionSuffix = 9
        }
        Invoke-DotnetPublish sln @parameters

        # Assert
        Should -Invoke Invoke-Dotnet -ParameterFilter {
            $Command | Should -BeExactly "publish"
            $i = 0
            @(
                "sln"
                "--arch", 1
                "--configuration", 2
                "--disable-build-servers"
                "--framework", 3
                "--force"
                "--interactive"
                "--manifest", "m1"
                "--manifest", "m2"
                "--no-build"
                "--no-dependencies"
                "--nologo"
                "--no-restore"
                "--output", 4
                "--os", 5
                "--self-contained", "true"
                "--no-self-contained"
                "--source", 6
                "--runtime", 7
                "--verbosity", 8
                "--use-current-runtime", "true"
                "--version-suffix", 9
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }
            $true
        }
    }
}