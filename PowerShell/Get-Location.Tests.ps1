Describe "Get-Location" {
    Context "for the current location" {
        It "returns a FileSystem provider location" {
            # Arrange
            $location = Get-Location

            # Act
            $provider = $location.Provider

            # Assert
            $provider | Should -Be (Get-PSProvider "FileSystem")
        }
    }

    Context "for current location in Pester's test drive" {
        It "returns a FileSystem provider location" {
            # Arrange
            $location = Get-Location -PSDrive "TestDrive"

            # Act
            $provider = $location.Provider

            # Assert
            $provider | Should -Be (Get-PSProvider "FileSystem")
        }

        It "returns a location whose path is the test drive's root" {
            # Arrange
            $location = Get-Location -PSDrive "TestDrive"

            # Act
            $path = $location.Path

            # Assert
            $path | Should -Be "TestDrive:$([System.IO.Path]::DirectorySeparatorChar)"
        }

        It "returns a location whose provider path is in the temp directory" {
            # Arrange
            $tempPath = [System.IO.Path]::GetTempPath()
            $location = Get-Location -PSDrive "TestDrive"

            # Act
            $providerPath = $location.ProviderPath

            # Assert
            $providerPath | Should -BeLikeExactly "$tempPath*"
        }
    }
}
