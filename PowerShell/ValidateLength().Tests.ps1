Describe "[ValidateLength()]" {
    It "causes a ParameterArgumentValidationError when the length of a string argument does not match" {
        # Arrange
        function Get-Parameter {
            param (
                [ValidateLength(1, 3)]
                [string] $Parameter
            )

            $Parameter
        }

        # Act + Assert
        $expectation = @{
            Throw = $true
            ErrorId = "ParameterArgumentValidationError,Get-Parameter"
        }
        { Get-Parameter -Parameter "four" } | Should @expectation
    }
}