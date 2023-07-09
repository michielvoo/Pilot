Describe "[OutputType()]" {
    It "sets OutputType for Get-Command" {
        # Arrange
        function Get-Parameter {
            [OutputType([int])]
            param (
                [int] $Parameter
            )

            $Parameter
        }

        # Act
        $command = Get-Command Get-Parameter

        # Assert
        $command.OutputType[0].Type.GetType() | Should -Be ([int].GetType())
    }
}