BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
}

Describe Get-CurrentGitBranch {
    It "returns null when git exit code is not 0" {
        # Arrange
        Mock Invoke-GitBranchList {
            @{ ExitCode = 128 }
        }

        # Act
        $tag = Get-CurrentGitBranch

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
        $tag = Get-CurrentGitBranch

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
        $tag = Get-CurrentGitBranch

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
        $tag = Get-CurrentGitBranch

        # Assert
        $tag | Should -BeExact "main"
    }
}