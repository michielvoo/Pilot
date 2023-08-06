Describe "Write-Verbose" {
    Context "when -Verbose is specified" {
        It "writes a [System.Management.Automation.VerboseRecord] to the verbose stream (4)" {
            # Arrange
            function Write-StringToVerbose
            {
                [CmdletBinding()]
                param ()

                Write-Verbose -Message "test"
            }

            # Act
            $verboseRecord = Write-StringToVerbose -Verbose 4>&1

            # Assert
            $verboseRecord -is [System.Management.Automation.VerboseRecord] | Should -BeTrue
            $verboseRecord.Message | Should -BeExact "test"
        }
    }
}
