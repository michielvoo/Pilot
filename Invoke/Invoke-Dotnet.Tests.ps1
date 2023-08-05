BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
    . (Join-Path $PSScriptRoot "Invoke-NativeCommand.ps1")

    Mock Invoke-NativeCommand {}
}

Describe Invoke-Dotnet {
    It "invokes dotnet with the command and any arguments" {
        # Act
        Invoke-Dotnet command --option arg 

        # Assert
        Should -Invoke Invoke-NativeCommand -ParameterFilter {
            $LiteralPath | Should -BeExactly "dotnet"
            $Arguments | Should -Be @("command", "--option", "arg")
            $true
        }
    }
}