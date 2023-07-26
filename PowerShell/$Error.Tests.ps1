# The error stream is redirected in these tests just to ensure the errors are not visible in the 
# host when running these tests.

Describe "`$Error automatic variable" {
    It "automatically collects a single error in a [System.Collections.ArrayList]" {
        # Arrange
        $global:Error.Clear()

        function Test {
            [CmdletBinding()]
            param ()

            Write-Error "test"
        }

        # Act
        Test -ErrorAction SilentlyContinue
        
        # Assert
        $global:Error -is [System.Collections.ArrayList] | Should -BeTrue -Because "`$Error is an ArrayList"
        $global:Error[0] | Should -BeOfType [System.Management.Automation.ErrorRecord]
        $global:Error[0].Exception.Message | Should -BeExact "test"
    }

    It "automatically collects multiple errors in a [System.Collections.ArrayList] in reverse order" {
        # Arrange
        $global:Error.Clear()

        function Test {
            [CmdletBinding()]
            param ()

            Write-Error "first"
            Write-Error "second"
        }

        # Act
        Test -ErrorAction SilentlyContinue

        # Assert
        $global:Error.Count | Should -Be 2
        $global:Error[0].Exception.Message | Should -BeExact "second"
        $global:Error[1].Exception.Message | Should -BeExact "first"
    }

    It "automatically only collects the first error in a [System.Collections.ArrayList] with -ErrorAction Stop" {
        # Arrange
        $global:Error.Clear()

        function Test {
            [CmdletBinding()]
            param ()

            Write-Error "first"
            Write-Error "second"
        }

        # Act
        try {
            Test -ErrorAction Stop 2>$null
        }
        catch {
        }

        # Assert
        $global:Error.Count | Should -Be 1
        $global:Error[0].Exception.Message | Should -BeExact "first"
    }

    It "automatically prepends errors" {
        # Arrange
        $global:Error.Clear()
        $global:Error.Add("test");

        function Test {
            [CmdletBinding()]
            param ()

            Write-Error "error"
        }

        # Act
        Test -ErrorAction SilentlyContinue

        # Assert
        $global:Error.Count | Should -Be 2
        $global:Error[0] | Should -BeOfType [System.Management.Automation.ErrorRecord]
        $global:Error[0].Exception.Message | Should -BeExact "error"
        $global:Error[1] -is [string] | Should -BeTrue
        $global:Error[1] | Should -BeExact "test"
    }

    It "automatically collects errors from native commands if stderr is redirected" {
        # The redirection of the error stream in this test is part of the preconditions for this 
        # test to pass in PowerShell's ConsoleHost. Without that redirection, in PowerShell's 
        # ConsoleHost, stderr output is not visible to PowerShell itself.

        # Arrange
        $global:Error.Clear()

        # Act
        & find test 2>$null

        # Assert
        $global:Error.Count | Should -Be 1
        $global:Error[0].Exception.Message | Should -Match "find:"
    }
}