BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
    . ([string]::Join([IO.Path]::DirectorySeparatorChar, @($PSScriptRoot, "Invoke", "Invoke-Git", "Invoke-GitDescribe.ps1")))

    Mock Invoke-GitDescribe {}
}

Describe Get-MatchingTagForGitHeadCommit {
    It "returns null when git exit code is not 0" {
        # Arrange
        Mock Invoke-GitDescribe {
            @{ ExitCode = 128 }
        }

        # Act
        $tag = Get-MatchingTagForGitHeadCommit("v\d+\.\d+\.\d+")

        # Assert
        $tag | Should -BeNull
    }

    It "returns null when git stdout does not match regex" {
        # Arrange
        Mock Invoke-GitDescribe {
            @{
                ExitCode = 0
                Stdout = @("test")
            }
        }

        # Act
        $tag = Get-MatchingTagForGitHeadCommit("v\d+\.\d+\.\d+")

        # Assert
        $tag | Should -BeNull
    }

    It "returns git stdout when it matches regex" {
        # Arrange
        Mock Invoke-GitDescribe {
            @{
                ExitCode = 0
                Stdout = @("v1.23.456")
            }
        }

        # Act
        $tag = Get-MatchingTagForGitHeadCommit("v\d+\.\d+\.\d+")

        # Assert
        $tag | Should -BeExact "v1.23.456"
    }
}