BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
    . (Join-Path $PSScriptRoot "Invoke-DotnetNuget.ps1")

    Mock Invoke-DotnetNuget {}
}

Describe Invoke-DotnetNugetPush {
    It "invokes dotnet nuget push with arguments" {
        # Act
        $parameters = @{
            ApiKey = 2
            DisableBuffering = $true
            ForceEnglishOutput = $true
            Interactive = $true
            NoServiceEndpoint = $true
            NoSymbols = $true
            SkipDuplicate = $true
            Source = 3
            SymbolApiKey = 4
            SymbolSource = 5
            Timeout = 6
        }
        Invoke-DotnetNugetPush 1 @parameters

        # Assert
        Should -Invoke Invoke-DotnetNuGet -ParameterFilter {
            $Command | Should -BeExactly "push"
            $Arguments | Should -Be @(
                1
                "--api-key", 2
                "--disable-buffering"
                "--force-english-output"
                "--interactive"
                "--no-service-endpoint"
                "--no-symbols"
                "--skip-duplicate"
                "--source", 3
                "--symbol-api-key", 4
                "--symbol-source", 5
                "--timeout", 6
            )
            $true
        }
    }
}