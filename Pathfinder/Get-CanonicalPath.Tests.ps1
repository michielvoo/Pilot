BeforeAll {
    . $PSCommandPath.Replace(".Tests.", ".")
    . (Join-Path $PSScriptRoot "Join-Paths.ps1")
}

Describe Get-CanonicalPath {
    # It "only supports file system providers" {
    #     # Arrange
    #     $envPath = "Env:test"

    #     # Act + Assert
    #     $expectation = @{
    #         Throw = $true
    #         ErrorId = "PSProviderNotSupported,Get-CanonicalPath"
    #         ExceptionType = [System.NotSupportedException]
    #     }
    #     { Get-CanonicalPath $envPath -ErrorAction "Stop" } | Should @expectation
    # }

    Context "for paths rooted in the file system's temp path" {
        # It "removes . segment from the path" {
        #     # Arrange
        #     $tempPath = [System.IO.Path]::GetTempPath()
        #     $randomFileName = [System.IO.Path]::GetRandomFileName()
        #     $nonCanonicalPath = Join-Paths $tempPath "." $randomFileName
            
        #     # Act
        #     $canonicalPath = Get-CanonicalPath $nonCanonicalPath

        #     # Assert
        #     $canonicalPath | Should -BeExactly (Join-Path $tempPath $randomFileName)
        # }

        # It "removes .. segment from the path" {
        #     # Arrange
        #     $tempPath = [System.IO.Path]::GetTempPath()
        #     $randomFileName = [System.IO.Path]::GetRandomFileName()
        #     $nonCanonicalPath = Join-Paths $tempPath $randomFileName ".." $randomFileName
            
        #     # Act
        #     $canonicalPath = Get-CanonicalPath $nonCanonicalPath

        #     # Assert
        #     $canonicalPath | Should -BeExactly (Join-Path $tempPath $randomFileName)
        # }

        # It "removes trailing directory separator" {
        #     # Arrange
        #     $tempPath = [System.IO.Path]::GetTempPath().TrimEnd([System.IO.Path]::DirectorySeparatorChar)
        #     $nonCanonicalPath = "$tempPath$([System.IO.Path]::DirectorySeparatorChar)"
            
        #     # Act
        #     $canonicalPath = Get-CanonicalPath $nonCanonicalPath

        #     # Assert
        #     $canonicalPath | Should -BeExactly $tempPath
        # }

        # It "removes duplicate directory separators" {
        #     # Arrange
        #     $tempPath = [System.IO.Path]::GetTempPath()
        #     $randomFileName = [System.IO.Path]::GetRandomFileName()
        #     $nonCanonicalPath = $tempPath + 
        #         [System.IO.Path]::DirectorySeparatorChar +
        #         [System.IO.Path]::DirectorySeparatorChar +
        #         $randomFileName
            
        #     # Act
        #     $canonicalPath = Get-CanonicalPath $nonCanonicalPath

        #     # Assert
        #     $canonicalPath | Should -BeExactly (Join-Path $tempPath $randomFileName)
        # }

        # It "replaces alternative directory separators" {
        #     # Arrange
        #     $tempPath = [System.IO.Path]::GetTempPath()
        #     $randomFileName = [System.IO.Path]::GetRandomFileName()
        #     $nonCanonicalPath = $tempPath + 
        #         [System.IO.Path]::AltDirectorySeparatorChar +
        #         [System.IO.Path]::AltDirectorySeparatorChar +
        #         $randomFileName
            
        #     # Act
        #     $canonicalPath = Get-CanonicalPath $nonCanonicalPath

        #     # Assert
        #     $canonicalPath | Should -BeExactly (Join-Path $tempPath $randomFileName)
        # }

        It "returns path whith fixed segments" {
            # Arrange
            $upperCase = "TEST.txt"
            $lowerCase = "test.txt"
            $mixedCase = "TEST.txt"

            $tempPath = [System.IO.Path]::GetTempPath()
            $randomDirectoryPath = Join-Path $tempPath ([System.IO.Path]::GetRandomFileName())
            New-Item $randomDirectoryPath -ItemType Directory | Out-Null
            New-Item (Join-Path $randomDirectoryPath $uppercase) -ItemType File | Out-Null
            if (Test-Path (Join-Path $randomDirectoryPath $lowerCase)) {
                # File system is case-insensitive, segments can be fixed
                $expectedFileName = $upperCase
            }
            else {
                New-Item (Join-Path $randomDirectoryPath $lowerCase) -ItemType File | Out-Null
                # File system is case-sensitive, segments cannot be fixed
                $expectedFileName = $mixedCase
            }
            $nonCanonicalPath = Join-Path $randomDirectoryPath $mixedCase

            # Act
            $canonicalPath = Get-CanonicalPath $nonCanonicalPath

            # Assert
            $canonicalPath | Should -BeExactly (Join-Path $randomDirectoryPath $expectedFileName)
        }

        # It "returns an absolute path" {
        #     # Arrange
        #     $randomFileName = [System.IO.Path]::GetRandomFileName()
        #     $nonCanonicalPath = Join-Path "." $randomFileName

        #     # Act
        #     $canonicalPath = Get-CanonicalPath $nonCanonicalPath

        #     # Assert
        #     $absolutePath = Join-Path (Get-Location).Path $randomFileName
        #     $canonicalPath | Should -BeExactly $absolutePath
        # }
    }

    # Context "for file system paths in the TestDrive" {
    #     It "returns the provider path" {
    #         # Arrange
    #         $testPath = Join-Path "TestDrive:" ([System.IO.Path]::GetRandomFileName())
    #         $randomFileName = [System.IO.Path]::GetRandomFileName()
    #         $nonCanonicalPath = Join-Paths $testPath $randomFileName
            
    #         # Act
    #         $canonicalPath = Get-CanonicalPath $nonCanonicalPath

    #         # Assert
    #         $providerPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($nonCanonicalPath)
    #         $canonicalPath | Should -BeExactly $providerPath
    #     }
    # }

    # Context "on Windows PowerShell" {
    #     if ($PSEdition -eq "Desktop") {
    #         It "returns the root of the file system drive" {
    #             # Arrange
    #             $drive = Get-PSDrive -PSProvider "FileSystem" | Where-Object { $_.Name -ne "TestDrive" } | Select-Object -First 1

    #             # Act
    #             $canonicalPath = Get-CanonicalPath $drive.Root

    #             # Assert
    #             $canonicalPath | Should -BeExactly $drive.Root
    #         }
    #     }
    # }
}