Describe "[ValidateRange()]" {
    It "causes a ParameterArgumentValidationError when the argument is out of range" {
        # Arrange
        function Get-Parameter {
            param (
                [ValidateRange(0, 1000)]
                [int] $Parameter
            )

            $Parameter
        }

        # Act + Assert
        $expectation = @{
            Throw = $true
            ErrorId = "ParameterArgumentValidationError,Get-Parameter"
        }
        { Get-Parameter -Parameter 1234 } | Should @expectation
    }
}