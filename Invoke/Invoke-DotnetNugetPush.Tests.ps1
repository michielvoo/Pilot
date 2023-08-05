BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
    . (Join-Path $PSScriptRoot "Invoke-DotnetNuget.ps1")

    Mock Invoke-DotnetNuget {}
}

Describe Invoke-DotnetNugetPush {
    It "invokes dotnet nuget push with arguments" {
        # Act
        Invoke-DotnetNugetPush "1" -ApiKey "2" -SkipDuplicate -Source "3"

        # Assert
        Should -Invoke Invoke-DotnetNuGet -ParameterFilter {
            $Command | Should -BeExactly "push"
            $Arguments | Should -Be @(
                "1"
                "--api-key", "2"
                "--skip-duplicate"
                "--source", "3"
            )
            $true
        }
    }
}