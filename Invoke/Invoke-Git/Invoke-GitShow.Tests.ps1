BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Git
}

Describe Invoke-GitShow {
    It "invokes git with the show command and any arguments" {
        # Act
        $parameters = @{
            Pretty = "1"
            AbbrevCommit = $true
            # ...
        }
        Invoke-GitShow @parameters obj1 obj2 obj3

        # Assert
        Should -Invoke Invoke-Git -ParameterFilter {
            $Command | Should -BeExactly "show"
            $i = 0
            @(
                "--pretty=1"
                "--abbrev-commit"
                # ...
                "obj1", "obj2", "obj3"
            ) | ForEach-Object {
                $Arguments[$i++] | Should -BeExactly $_
            }

            $true
        }
    }
}
