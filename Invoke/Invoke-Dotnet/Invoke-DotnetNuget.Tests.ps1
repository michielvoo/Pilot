BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
    . (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

    Mock Invoke-Dotnet {}
}

Describe Invoke-DotnetNuget {
    It "invokes dotnet with the nuget command and any arguments" {
        # Act
        Invoke-DotnetNuget command --option arg 

        # Assert
        Should -Invoke Invoke-Dotnet -ParameterFilter {
            $Command | Should -BeExactly "nuget"
            $i = 0
            @(
                "command",
                "--option",
                "arg"
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }

            $true
        }
    }
}