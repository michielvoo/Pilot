Describe "[AllowEmptyCollection()]" {
    It "allows @() for an array parameter" {
        # Arrange
        function Get-Parameter {
            param (
                [AllowEmptyCollection()]
                [Parameter(Mandatory)]
                [string[]] $Parameter
            )

            $Parameter
        }

        # Act + Assert
        { Get-Parameter -Parameter @() } | Should -Not -Throw
    }
}