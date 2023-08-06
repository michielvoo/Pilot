BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-DotnetNuget
}

Describe Invoke-DotnetNugetPush {
    It "invokes dotnet nuget with command push and arguments" {
        # Act
        $parameters = @{
            ApiKey = 1
            DisableBuffering = $true
            ForceEnglishOutput = $true
            Interactive = $true
            NoServiceEndpoint = $true
            NoSymbols = $true
            SkipDuplicate = $true
            Source = 2
            SymbolApiKey = 3
            SymbolSource = 4
            Timeout = 5
        }
        Invoke-DotnetNugetPush pkg @parameters

        # Assert
        Should -Invoke Invoke-DotnetNuGet -ParameterFilter {
            $Command | Should -BeExactly "push"
            $i = 0
            @(
                "pkg"
                "--api-key", 1
                "--disable-buffering"
                "--force-english-output"
                "--interactive"
                "--no-service-endpoint"
                "--no-symbols"
                "--skip-duplicate"
                "--source", 2
                "--symbol-api-key", 3
                "--symbol-source", 4
                "--timeout", 5
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }
            
            $true
        }
    }
}