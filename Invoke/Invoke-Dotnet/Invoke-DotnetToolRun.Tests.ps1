BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-DotnetTool
}

Describe Invoke-DotnetToolRun {
    It "invokes Invoke-DotnetTool with command run and arguments" {
        # Act
        Invoke-DotnetToolRun cmd --option arg

        # Assert
        Should -Invoke Invoke-DotnetTool -ParameterFilter {
            $Command | Should -BeExactly "run"
            $i = 0
            @(
                "cmd"
                "--option"
                "arg"
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }

            $true
        }
    }
}