Describe "[ValidateScript()]" {
    It "causes a ParameterArgumentValidationError when validation script returns `$false" {
        # Arrange
        function Get-Parameter {
            param (
                [ValidateScript({ $_ -ge 0 -and $_ -le 1000 })]
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