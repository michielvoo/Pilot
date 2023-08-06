Describe "Write-Warning" {
    Context "when -WarningAction is Continue" {
        It "writes a [System.Management.Automation.WarningRecord] to the warning stream (3)" {
            # Arrange
            function Write-StringToWarning
            {
                [CmdletBinding()]
                param ()

                Write-Warning "test"
            }

            # Act
            $warningRecord = Write-StringToWarning -WarningAction "Continue" 3>&1

            # Assert
            $warningRecord -is [System.Management.Automation.WarningRecord] | Should -BeTrue
            $warningRecord.Message | Should -BeExact "test"
            $warningRecord.FullyQualifiedWarningId | Should -BeExact ([string]::Empty)
        }
    }
}
