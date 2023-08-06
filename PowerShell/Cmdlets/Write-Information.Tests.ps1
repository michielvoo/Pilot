Describe "Write-Information" {
    Context "when -InformationAction is Continue" {
        It "writes a [System.Management.Automation.InformationRecord] to the information stream (6)" {
            # Arrange
            function Write-StringToInformation
            {
                [CmdletBinding()]
                param ()

                Write-Information -MessageData "test" -Tags @("one", "two")
            }

            # Act
            $informationRecord = Write-StringToInformation -InformationAction "Continue" 6>&1

            # Assert
            $informationRecord -is [System.Management.Automation.InformationRecord] | Should -BeTrue
            $informationRecord.MessageData | Should -BeExact "test"
            $informationRecord.Tags | Should -Be @("one", "two")
        }
    }
}
