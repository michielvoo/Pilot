# The error action is set to silently continue in these tests just to ensure the errors are not 
# visible in the host when running these tests.

Describe "`$Error" {
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
            Test -ErrorAction Stop
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

    Context "for native commands, when redirecting stderr" {
        # The redirection of the error stream in these tests is part of the preconditions for the 
        # first test to pass in Windows PowerShell's ConsoleHost. Without that redirection stderr 
        # output is not visible to (Windows) PowerShell itself.

        if ($PSEdition -eq "Desktop") {
            It "automatically collects errors in Windows PowerShell" {
                # Arrange
                $global:Error.Clear()

                # Act
                & find test 2>$null

                # Assert
                $global:Error.Count | Should -Be 1
                $global:Error[0].Exception.Message | Should -Match "find:"
            }
        }
        elseif ($PSVersionTable.PSVersion -ge [System.Version]::new(7, 2)) {
            # Since PowerShell 7.2 the experimental feature PSNotApplyErrorActionToStderr has 
            # become a mainstream feature. This also affects collection of native command stderr 
            # in $Error.
            # See https://github.com/PowerShell/PowerShell/issues/3996#issuecomment-308242927
            It "does not automatically collect errors in PowerShell 7.2 and later" {
                # Arrange
                $global:Error.Clear()

                # Act
                & find test 2>$null

                # Assert
                $global:Error.Count | Should -Be 0
            }
        }
    }
}