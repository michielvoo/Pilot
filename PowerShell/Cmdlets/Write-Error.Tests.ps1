Describe "Write-Error" {
    Context "when -ErrorAction is Continue" {
        It "writes a [System.Management.Automation.ErrorRecord] to the error stream (stderr)" {
            # Arrange
            function Write-StringToError
            {
                [CmdletBinding()]
                param ()

                Write-Error "test"
            }

            # Act
            $errorRecord = Write-StringToError -ErrorAction "Continue" 2>&1

            # Assert
            $errorRecord -is [System.Management.Automation.ErrorRecord] | Should -BeTrue
            $errorRecord.CategoryInfo.Category | Should -Be NotSpecified
            $errorRecord.CategoryInfo.Reason | Should -BeExact "WriteErrorException"
            $errorRecord.Exception | Should -BeOfType [Microsoft.PowerShell.Commands.WriteErrorException]
            $errorRecord.Exception.Message | Should -BeExact "test"
            $errorRecord.FullyQualifiedErrorId | Should -Be "Microsoft.PowerShell.Commands.WriteErrorException,Write-StringToError"
        }
    }

    Context "when -ErrorAction is Stop" {
        It "throws an error" {
            # Arrange
            function Write-StringToError
            {
                [CmdletBinding()]
                param ()

                Write-Error "test"
            }

            # Act + Assert
            $expectation = @{
                Throw = $true
                ErrorId = "Microsoft.PowerShell.Commands.WriteErrorException,Write-StringToError"
                ExpectedMessage = "test"
            }
            { Write-StringToError -ErrorAction "Stop" } | Should @expectation
        }
    }
}
