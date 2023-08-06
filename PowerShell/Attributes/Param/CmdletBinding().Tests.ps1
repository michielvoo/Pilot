Describe "[CmdletBinding()]" {
    It "causes a PositionalParameterNotFound error when giving arguments to undefined parameters" {
        # Arrange
        function Get-Arguments {
            [CmdletBinding()]
            param ()

            $args
        }

        # Act + Assert
        $expectation = @{
            Throw = $true
            ErrorId = "PositionalParameterNotFound,Get-Arguments"
        }
        { Get-Arguments "8a34d5ea" 12 $true } | Should @expectation
    }

    It "sets `$args automatic variable for the function" {
        # Arrange
        function Get-Arguments {
            [CmdletBinding()]
            param (
                $Parameter1, 
                $Parameter2, 
                $Parameter3
            )

            $args
        }

        # Act
        $arguments = Get-Arguments "8a34d5ea" 12 $true
        
        #Assert
        $arguments[0] | Should -Not -Be "8a34d5ea"
    }

    It "sets `$PSCmdlet automatic variable for the function" {
        # Arrange
        function Get-CommandName {
            [CmdletBinding()]
            param ()

            $PSCmdlet.MyInvocation.MyCommand.Name
        }

        # Act
        $commandName = Get-CommandName

        # Assert
        $commandName | Should -BeExact "Get-CommandName"
    }

    It "allows use of the `$PSCmdlet.ThrowTerminatingError() method" {
        # Arrange
        function Test-CmdletWriteError {
            [CmdletBinding()]
            param (
                [string[]] $Values
            )

            foreach ($value in $Values) {
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    [Exception]::new(),
                    "TerminatingError",
                    [System.Management.Automation.ErrorCategory]::NotSpecified,
                    $value
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }

        # Act
        try {
            Test-CmdletWriteError -Values @("one", "two", "three")
        }
        catch {
            $e = $_
        }

        # Assert
        $e.FullyQualifiedErrorId | Should -BeExact "TerminatingError,Test-CmdletWriteError"
        $e.TargetObject | Should -BeExact "one"
    }

    It "allows use of the `$PSCmdlet.WriteError() method" {
        # Arrange
        function Test-CmdletWriteError {
            [CmdletBinding()]
            param (
                [string[]] $Values
            )

            foreach ($value in $Values) {
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    [Exception]::new(),
                    "NonTerminatingError",
                    [System.Management.Automation.ErrorCategory]::NotSpecified,
                    $value
                )
                $PSCmdlet.WriteError($errorRecord)
            }
        }

        # Act
        try {
            Test-CmdletWriteError -Values @("one", "two", "three") -ErrorAction Stop
        }
        catch {
            $e = $_
        }

        # Assert
        $e.FullyQualifiedErrorId | Should -BeExact "NonTerminatingError,Test-CmdletWriteError"
        $e.TargetObject | Should -BeExact "one"
    }

    It "allows use of the `$PSCmdlet.WriteObject() method" {
        # Arrange
        function Test-CmdletWriteError {
            [CmdletBinding()]
            param (
                [string[]] $Values
            )

            foreach ($value in $Values) {
                $PSCmdlet.WriteObject($value)
            }
        }

        # Act
        $objects = Test-CmdletWriteError -Values @("one", "two", "three")

        # Assert
        $objects | Should -Be @("one", "two", "three")
    }
}