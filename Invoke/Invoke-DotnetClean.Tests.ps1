BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
    . (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

    Mock Invoke-Dotnet {}
}

Describe Invoke-DotnetClean {
    It "invokes dotnet with command clean and arguments" {
        # Act
        $parameters = @{
            Configuration = 1
            Framework = 2
            Interactive = $true
            NoLogo = $true
            Output = 3
            Runtime = 4
            Verbosity = 5
        }
        Invoke-DotnetClean sln @parameters

        # Assert
        Should -Invoke Invoke-Dotnet -ParameterFilter {
            $Command | Should -BeExactly "build"
            $i = 0
            @(
                "sln"
                "--configuration", 1
                "--framework", 2
                "--interactive"
                "--nologo"
                "--output", 3
                "--runtime", 4
                "--verbosity", 5
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }

            $true
        }
    }
}