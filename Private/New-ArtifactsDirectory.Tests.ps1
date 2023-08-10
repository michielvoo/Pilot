BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")
}

Describe New-ArtifactsDirectory {
    It "Creates the directory if it does not exist" {
        # Arrange
        $artifactsPath = Join-Path "TestDrive:" "artifacts"

        # Act
        New-ArtifactsDirectory($artifactsPath)

        # Assert
        Test-Path $artifactsPath | Should -BeTrue
    }

    It "Removes all files from the artifacts directory" {
        # Arrange
        $artifactsPath = Join-Path "TestDrive:" "artifacts"
        $filePath = Join-Path $artifactsPath "test.txt"
        New-Item $filePath -ItemType File

        # Act
        New-ArtifactsDirectory($artifactsPath)

        # Assert
        Test-Path $filePath | Should -BeFalse
    }

    It "Removes all files from the artifact directory's sub-directories" {
        # Arrange
        $artifactsPath = Join-Path "TestDrive:" "artifacts"
        $subDirectoryPath = Join-Path $artifactsPath "sub-directory"
        New-Item $subDirectoryPath -ItemType Directory
        $filePath = Join-Path $subDirectoryPath "test.txt"
        New-Item $filePath -ItemType File

        # Act
        New-ArtifactsDirectory($artifactsPath)

        # Assert
        Test-Path $filePath | Should -BeFalse
    }

    It "Removes all sub-directories from the artifact directory" {
        # Arrange
        $artifactsPath = Join-Path "TestDrive:" "artifacts"
        $subDirectoryPath = Join-Path $artifactsPath "sub-directory"
        New-Item $subDirectoryPath -ItemType Directory

        # Act
        New-ArtifactsDirectory($artifactsPath)

        # Assert
        Test-Path $subDirectoryPath | Should -BeFalse
    }
}