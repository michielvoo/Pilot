Describe "[ValidatePattern()]" {
    It "causes a ParameterArgumentValidationError when the argument does not match" {
        # Arrange
        function Get-Parameter {
            param (
                [ValidatePattern("^[0-9]{1,3}$")]
                [string] $Parameter
            )

            $Parameter
        }

        # Act + Assert
        $expectation = @{
            Throw = $true
            ErrorId = "ParameterArgumentValidationError,Get-Parameter"
        }
        { Get-Parameter -Parameter "1234" } | Should @expectation
    }
}