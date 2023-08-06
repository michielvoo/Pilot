Describe "[AllowEmptyString()]" {
    It "allows [string]::Empty for a string parameter" {
        # Arrange
        function Get-Parameter {
            param (
                [AllowEmptyString()]
                [Parameter(Mandatory)]
                [string] $Parameter
            )

            $Parameter
        }

        # Act + Assert
        { Get-Parameter -Parameter ([string]::Empty) } | Should -Not -Throw
    }

    It "allows @([string]::Empty) for a [string[]] parameter" {
        # Arrange
        function Get-Parameter {
            param (
                [AllowEmptyString()]
                [Parameter(Mandatory)]
                [string[]] $Parameter
            )

            $Parameter
        }

        # Act + Assert
        { Get-Parameter -Parameter @([string]::Empty) } | Should -Not -Throw
    }
}