BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Git
}

Describe Invoke-GitBranchList {
    It "invokes git with the branch command and --list argument and any arguments" {
        # Act
        $parameters = @{
            ShowCurrent = $true
        }
        Invoke-GitBranchList @parameters pat1 pat2 pat3

        # Assert
        Should -Invoke Invoke-Git -ParameterFilter {
            $Command | Should -BeExactly "branch"
            $i = 0
            @(
                "--list"
                "--show-current"
                "pat1", "pat2", "pat3"
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }

            $true
        }
    }
}
