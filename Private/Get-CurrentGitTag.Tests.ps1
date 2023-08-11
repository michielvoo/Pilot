BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
}

Describe Get-CurrentGitTag {
    It "returns null when git exit code is not 0" {
        # Arrange
        Mock Invoke-GitDescribe {
            @{ ExitCode = 128 }
        }

        # Act
        $tag = Get-CurrentGitTag

        # Assert
        $tag | Should -BeNull
    }

    It "returns git stdout" {
        # Arrange
        Mock Invoke-GitDescribe {
            @{
                ExitCode = 0
                Stdout = @("tag")
            }
        }

        # Act
        $tag = Get-CurrentGitTag

        # Assert
        $tag | Should -BeExact "tag"
    }
}