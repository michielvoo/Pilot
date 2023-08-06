Describe "Write-Output" {
    It "writes an object to success stream (stdout) which is used by the assignment operator" {
        # Arrange
        function Write-StringToOutput
        {
            [CmdletBinding()]
            param ()

            Write-Output "test"
        }

        # Act
        $out = Write-StringToOutput

        # Assert
        $out | Should -BeExact "test"
    }
}