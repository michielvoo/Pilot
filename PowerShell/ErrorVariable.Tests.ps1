# The error stream is redirected in these tests just to ensure the errors are not visible in the 
# host when running these tests.

Describe "-ErrorVariable" {
    It "collects a single error in a [System.Collections.ArrayList]" {
        # Arrange
        function Test {
            [CmdletBinding()]
            param ()

            Write-Error "test"
        }

        # Act
        Test -ErrorVariable "capturedErrors" 2>$null

        # Assert
        $capturedErrors -is [System.Collections.ArrayList] | Should -BeTrue
        $capturedErrors[0] -is [System.Management.Automation.ErrorRecord] | Should -BeTrue
        $capturedErrors[0].Exception.Message | Should -BeExact "test"
    }

    It "collects multiple errors in a [System.Collections.ArrayList] in order" {
        # Arrange
        function Test {
            [CmdletBinding()]
            param ()

            Write-Error "first"
            Write-Error "second"
        }

        # Act
        Test -ErrorVariable "capturedErrors" 2>$null

        # Assert
        $capturedErrors.Count | Should -Be 2
        $capturedErrors[0].Exception.Message | Should -BeExact "first"
        $capturedErrors[1].Exception.Message | Should -BeExact "second"
    }

    It "replaces the variable's value" {
        # Arrange
        $capturedErrors = [System.Collections.ArrayList]::new()
        $capturedErrors.Add("test");

        function Test {
            [CmdletBinding()]
            param ()

            Write-Error "error" 2>$null
        }

        # Act
        Test -ErrorVariable "capturedErrors"

        # Assert
        $capturedErrors.Count | Should -Be 1
        $capturedErrors[0] -is [System.Management.Automation.ErrorRecord] | Should -BeTrue
        $capturedErrors[0].Exception.Message | Should -BeExact "error"
    }

    It "appends to the variable's value when using the + prefix" {
        # Arrange
        $capturedErrors = [System.Collections.ArrayList]::new()
        $capturedErrors.Add("test");

        function Test {
            [CmdletBinding()]
            param ()

            Write-Error "error"
        }

        # Act
        Test -ErrorVariable "+capturedErrors" 2>$null

        # Assert
        $capturedErrors.Count | Should -Be 2
        $capturedErrors[0] -is [string] | Should -BeTrue
        $capturedErrors[0]  | Should -BeExact "test"
        $capturedErrors[1] -is [System.Management.Automation.ErrorRecord] | Should -BeTrue
        $capturedErrors[1].Exception.Message | Should -BeExact "error"
    }
}
