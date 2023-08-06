Describe "[ValidateNotNullOrEmpty()]" {
    It "causes a ParameterArgumentValidationError when the optional argument is `$null" {
        # Arrange
        function Get-Parameter {
            param (
                [ValidateNotNullOrEmpty()]
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

    It "causes a ParameterArgumentValidationError when the optional argument is [string]::Empty" {
        # Arrange
        function Get-Parameter {
            param (
                [ValidateNotNullOrEmpty()]
                [string] $Parameter
            )

            $Parameter
        }

        # Act + Assert
        $expectation = @{
            Throw = $true
            ErrorId = "ParameterArgumentValidationError,Get-Parameter"
        }
        { Get-Parameter -Parameter ([string]::Empty) } | Should @expectation
    }
}