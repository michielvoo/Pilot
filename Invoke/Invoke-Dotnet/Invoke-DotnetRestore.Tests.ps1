BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Dotnet
}

Describe Invoke-DotnetRestore {
    It "invokes Invoke-Dotnet with command restore and arguments" {
        # Act
        $parameters = @{
            ConfigFile = 1
            DisableBuildServers = $true
            DisableParallel = $true
            Force = $true
            ForceEvaluate = $true
            IgnoreFailedSources = $true
            Interactive = $true
            LockFilePath = 2
            LockedMode = $true
            NoCache = $true
            NoDependencies = $true
            Packages = 3
            Runtime = 4
            Source = 5
            UseCurrentRuntime = $true
            UseLockFile = $true
            Verbosity = 6
        }
        Invoke-DotnetRestore sln @parameters

        # Assert
        Should -Invoke Invoke-Dotnet -ParameterFilter {
            $Command | Should -BeExactly "restore"
            $i = 0
            @(
                "sln"
                "--configfile", 1
                "--disable-build-servers"
                "--disable-parallel"
                "--force"
                "--force-evaluate"
                "--ignore-failed-sources"
                "--interactive"
                "--lock-file-path", 2
                "--locked-mode"
                "--no-cache"
                "--no-dependencies"
                "--packages", 3
                "--runtime", 4
                "--source", 5
                "--use-current-runtime", "true"
                "--use-lock-file"
                "--verbosity", 6
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }
            $true
        }
    }
}