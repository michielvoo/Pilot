BeforeAll {
    Set-Variable -Name "pathIntrinsics" -Value $ExecutionContext.SessionState.Path
}

Describe "PathIntrinsics.GetUnresolvedProviderPathFromPSPath" {
    It "returns a provider-internal path" {
        # Arrange
        $tempPath = [System.IO.Path]::GetTempPath()
        $path = Join-Path "TestDrive:" "test"

        # Act
        $providerPath = $pathIntrinsics.GetUnresolvedProviderPathFromPSPath($path)

        # Assert
        $providerPath | Should -BeLikeExactly "$tempPath*"
    }

    It "sets the provider" {
        # Arrange
        $provider = $null
        $path = Join-Path "TestDrive:" "test"

        # Act
        $pathIntrinsics.GetUnresolvedProviderPathFromPSPath($path, [ref] $provider, [ref] $null)

        # Assert
        $provider | Should -Be (Get-PSProvider -PSProvider "FileSystem")
    }

    It "sets the drive" {
        # Arrange
        $drive = $null
        $path = Join-Path "TestDrive:" "test"

        # Act
        $pathIntrinsics.GetUnresolvedProviderPathFromPSPath($path, [ref] $null, [ref] $drive)

        # Assert
        $drive | Should -Be (Get-PSDrive -Name "TestDrive" -PSProvider "FileSystem")
    }
}