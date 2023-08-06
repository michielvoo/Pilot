Describe "[SupportsWildCards()]" {
    It "sets Accept wildcard characters? in help to true" {
        # Arrange
        function Get-Files {
            <#
                .Description
                    Test function
            #>
            param (
                [SupportsWildcards()]
                [string] $Path
            )
        }

        # Act
        $help = Get-Help Get-Files -Parameter Path

        # Assert
        $help.globbing | Should -BeExact "true"
    }
}