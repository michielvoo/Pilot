BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-NativeCommand
}

Describe Invoke-Git {
    It "invokes git with the command and any arguments" {
        # Act
        Invoke-Git command --option arg 

        # Assert
        Should -Invoke Invoke-NativeCommand -ParameterFilter {
            $LiteralPath | Should -BeExactly "git"
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