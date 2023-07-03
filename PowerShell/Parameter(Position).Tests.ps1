Describe "[Parameter(Position)]" {
    It "sets Position?" {
        # Arrange
        function Get-Parameter {
            param (
                [Parameter(Position = 0)]
                [string] $Parameter
            )

            $Parameter
        }

        # Act
        $help = Get-Help Get-Parameter -Parameter Parameter

        # Assert
        $help.position | Should -BeExact "0"
    }
}