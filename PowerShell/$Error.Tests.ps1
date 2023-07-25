Describe "`$Error automatic variable" {
    It "automatically collects a single error in a [System.Collections.ArrayList]" {
        # Arrange
        $Error.Clear()

        function Test {
            [CmdletBinding()]
            param ()

            Write-Error "test"
        }

        # Act
        Test

        # Assert
        $Error -is [System.Collections.ArrayList] | Should -BeTrue
        $Error[0] -is [System.Management.Automation.ErrorRecord] | Should -BeTrue
        $Error[0].Exception.Message | Should -BeExact "test"
    }

    It "automatically collects multiple errors in a [System.Collections.ArrayList] in reverse order" {
        # Arrange
        $Error.Clear()

        function Test {
            [CmdletBinding()]
            param ()

            Write-Error "first"
            Write-Error "second"
        }

        # Act
        Test

        # Assert
        $Error.Count | Should -Be 2
        $Error[0].Exception.Message | Should -BeExact "second"
        $Error[1].Exception.Message | Should -BeExact "first"
    }

    It "automatically prepends errors" {
        # Arrange
        $Error.Clear()
        $Error.Add("test");

        function Test {
            [CmdletBinding()]
            param ()

            Write-Error "error"
        }

        # Act
        Test

        # Assert
        $Error.Count | Should -Be 2
        $Error[0] -is [System.Management.Automation.ErrorRecord] | Should -BeTrue
        $Error[0].Exception.Message | Should -BeExact "error"
        $Error[1] -is [string] | Should -BeTrue
        $Error[1]  | Should -BeExact "test"
    }

    It "automatically collects errors from native commands" {
        # Arrange
        $Error.Clear()

        # Act
        & find test

        # Assert
        $Error.Count | Should -Be 1
        $Error[0].Exception.Message | Should -Match "find:"
    }
}