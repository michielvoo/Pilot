Describe "-Debug" {
   if ($PSEdition -eq "Desktop") {
        It "sets `$DebugPreference to Inquire" {
            # Arrange
            function Get-DebugPreference
            {
                [CmdletBinding()]
                param ()

                $DebugPreference
            }
            $overriddenDebugPreference | Should -Not -Be "Inquire"

            # Act
            $overriddenDebugPreference = Get-DebugPreference -Debug

            # Assert
            $overriddenDebugPreference | Should -BeExact "Inquire"
        }
    }
}
