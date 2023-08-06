Describe "[ValidateCount()]" {
    It "causes a ParameterArgumentValidationError when the number of elements of an array argument does not match" {
        # Arrange
        function Get-Parameter {
            param (
                [ValidateCount(1, 3)]
                [string[]] $Parameter
            )

            $Parameter
        }

        # Act + Assert
        $expectation = @{
            Throw = $true
            ErrorId = "ParameterArgumentValidationError,Get-Parameter"
        }
        { Get-Parameter -Parameter "one", "two", "three", "four" } | Should @expectation
    }
}