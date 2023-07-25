Describe "Invoke-Command" {
    It "-ErrorAction does not apply to the argument provided to the -ScriptBlock parameter" {
        # Arrange
        function Test {
            [CmdletBinding()]
            param()
            Write-Error "test"
        }
        $scriptBlock = { Write-Error "test" }

        # Assert
        try {
            $previousErrorActionPreference = $ErrorActionPreference
            $ErrorActionPreference = "Stop"
            { Test } | Should -Throw
            { Test -ErrorAction SilentlyContinue } | Should -Not -Throw
            { Invoke-Command -ScriptBlock $scriptBlock -ErrorAction SilentlyContinue } | Should -Throw
        }
        finally {
            $ErrorActionPreference = $previousErrorActionPreference
        }
    }
}
