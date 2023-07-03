Describe "[ValidateSet()]" {
    It "causes a ParameterArgumentValidationError when the argument is not in the set" {
        # Arrange
        function Get-Parameter {
            param (
                [ValidateSet("one", "two", "three")]
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