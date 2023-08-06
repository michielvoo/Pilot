Describe "[AllowNull()]" {        
    It "allows `$null for an array parameter" {
        # Arrange
        function Get-Parameter {
            param (
                [AllowNull()]
                [Parameter(Mandatory)]
                [string[]] $Parameter
            )

            $Parameter
        }

        # Act + Assert
        { Get-Parameter -Parameter $null } | Should -Not -Throw
    }
    
    It "allows `$null for a [hashtable] parameter" {
        # Arrange
        function Get-Parameter {
            param (
                [AllowNull()]
                [Parameter(Mandatory)]
                [hashtable] $Parameter
            )

            $Parameter
        }

        # Act + Assert
        { Get-Parameter -Parameter $null } | Should -Not -Throw
    }
}