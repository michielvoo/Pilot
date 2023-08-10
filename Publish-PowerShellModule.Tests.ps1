BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
    . ([string]::Join([IO.Path]::DirectorySeparatorChar, @($PSScriptRoot, "Invoke", "Invoke-Git", "Invoke-GitBranchList.ps1")))
    . ([string]::Join([IO.Path]::DirectorySeparatorChar, @($PSScriptRoot, "Invoke", "Invoke-Git", "Invoke-GitDescribe.ps1")))
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

Describe GetCurrentGitBranch {
    It "returns null when git exit code is not 0" {
        # Arrange
        Mock Invoke-GitBranchList {
            @{ ExitCode = 128 }
        }

        # Act
        $tag = GetCurrentGitBranch

        # Assert
        $tag | Should -BeNull
    }

    It "returns null when git stdout has no lines" {
        # Arrange
        Mock Invoke-GitBranchList {
            @{
                ExitCode = 0
                Stdout = @()
            }
        }

        # Act
        $tag = GetCurrentGitBranch

        # Assert
        $tag | Should -BeNull
    }

    It "returns null when git stdout has more than 1 line" {
        # Arrange
        Mock Invoke-GitBranchList {
            @{
                ExitCode = 0
                Stdout = @("a", "b")
            }
        }

        # Act
        $tag = GetCurrentGitBranch

        # Assert
        $tag | Should -BeNull
    }

    It "returns git stdout when it is a single line" {
        # Arrange
        Mock Invoke-GitBranchList {
            @{
                ExitCode = 0
                Stdout = @("main")
            }
        }

        # Act
        $tag = GetCurrentGitBranch

        # Assert
        $tag | Should -BeExact "main"
    }
}