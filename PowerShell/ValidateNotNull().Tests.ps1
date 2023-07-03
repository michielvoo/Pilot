Describe "[ValidateNotNull()]" {
    It "causes a ParameterArgumentValidationError when the optional argument is `$null" {
        # Arrange
        function Get-Parameter {
            param (
                [ValidateNotNull()]
                [string[]] $Parameter
            )

            $Parameter
        }

        # Act + Assert
        $expectation = @{
            Throw = $true
            ErrorId = "ParameterArgumentValidationError,Get-Parameter"
        }
        { Get-Parameter -Parameter $null } | Should @expectation
    }

    It "does not causes an error when parameter type supports implicit conversion" {
        # Arrange
        function Get-Parameter {
            param (
                [ValidateNotNull()]
                [string] $Parameter
            )

            $Parameter
        }

        # Act + Assert
        { Get-Parameter -Parameter $null } | Should -Not -Throw
    }
}