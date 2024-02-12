BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Dotnet
}

Describe Invoke-DotnetTool {
    It "invokes dotnet with the tool command and any arguments" {
        # Act
        Invoke-DotnetTool command --option arg 

        # Assert
        Should -Invoke Invoke-Dotnet -ParameterFilter {
            $Command | Should -BeExactly "tool"
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