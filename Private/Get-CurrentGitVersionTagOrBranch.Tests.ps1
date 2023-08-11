BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Get-CurrentGitTag
    Mock Get-CurrentGitBranch
}

Describe Get-CurrentGitVersionTagOrBranch {
    It "returns current tag when it is a version tage" {
        # Arrange
        Mock Get-CurrentGitTag { "v1.23.456" }

        # Act
        $result = Get-CurrentGitVersionTagOrBranch

        # Assert
        $result | Should -BeExactly "v1.23.456"
    }

    It "returns branch when the current tag is not a version tag" {
        # Arrange
        Mock Get-CurrentGitTag { "tag" }

        Mock Get-CurrentGitBranch { "main" }

        # Act
        $result = Get-CurrentGitVersionTagOrBranch

        # Assert
        $result | Should -BeExactly "main"
    }

    It "returns branch when there is no current tag" {
        # Arrange
        Mock Get-CurrentGitBranch { "main" }

        # Act
        $result = Get-CurrentGitVersionTagOrBranch

        # Assert
        $result | Should -BeExactly "main"
    }

    It "returns null when there is no (version) tag and no branch" {
        # Act
        $result = Get-CurrentGitVersionTagOrBranch

        # Assert
        $result | Should -BeNull
    }
}