Describe "Write-Debug" {
    It "writes a [System.Management.Automation.DebugRecord] to the debug stream (5)" {
        # Arrange
        function Write-StringToDebug
        {
            [CmdletBinding()]
            param ()

            Write-Debug -Message "test"
        }

        $previousDebugPreference = $DebugPreference
        $DebugPreference = "Continue"

        # Act
        try {
            $debugRecord = Write-StringToDebug 5>&1
        }
        finally {
            $DebugPreference = $previousDebugPreference
        }

        # Assert
        $debugRecord -is [System.Management.Automation.DebugRecord] | Should -BeTrue
        $debugRecord.Message | Should -BeExact "test"
    }
}
