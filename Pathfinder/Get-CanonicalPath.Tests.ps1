BeforeAll {
    . $PSCommandPath.Replace(".Tests.", ".")
    . (Join-Path $PSScriptRoot "Join-Paths.ps1")
}

Describe Get-CanonicalPath {
    Context "for paths rooted in the file system's temp path" {
        It "removes . segment from the path" {
            # Arrange
            $tempPath = [System.IO.Path]::GetTempPath()
            $randomFileName = [System.IO.Path]::GetRandomFileName()
            $nonCanonicalPath = Join-Paths $tempPath "." $randomFileName
            
            # Act
            $canonicalPath = Get-CanonicalPath $nonCanonicalPath

            # Assert
            $canonicalPath | Should -BeExactly (Join-Path $tempPath $randomFileName)
        }

        It "removes .. segment from the path" {
            # Arrange
            $tempPath = [System.IO.Path]::GetTempPath()
            $randomFileName = [System.IO.Path]::GetRandomFileName()
            $nonCanonicalPath = Join-Paths $tempPath $randomFileName ".." $randomFileName
            
            # Act
            $canonicalPath = Get-CanonicalPath $nonCanonicalPath

            # Assert
            $canonicalPath | Should -BeExactly (Join-Path $tempPath $randomFileName)
        }

        It "removes trailing directory separator" {
            # Arrange
            $tempPath = [System.IO.Path]::GetTempPath().TrimEnd([System.IO.Path]::DirectorySeparatorChar)
            $nonCanonicalPath = "$tempPath$([System.IO.Path]::DirectorySeparatorChar)"
            
            # Act
            $canonicalPath = Get-CanonicalPath $nonCanonicalPath

            # Assert
            $canonicalPath | Should -BeExactly $tempPath
        }

        It "removes duplicate directory separators" {
            # Arrange
            $tempPath = [System.IO.Path]::GetTempPath()
            $randomFileName = [System.IO.Path]::GetRandomFileName()
            $nonCanonicalPath = $tempPath + 
                [System.IO.Path]::DirectorySeparatorChar +
                [System.IO.Path]::DirectorySeparatorChar +
                $randomFileName
            
            # Act
            $canonicalPath = Get-CanonicalPath $nonCanonicalPath

            # Assert
            $canonicalPath | Should -BeExactly (Join-Path $tempPath $randomFileName)
        }

        It "replaces alternative directory separators" {
            # Arrange
            $tempPath = [System.IO.Path]::GetTempPath()
            $randomFileName = [System.IO.Path]::GetRandomFileName()
            $nonCanonicalPath = $tempPath + 
                [System.IO.Path]::AltDirectorySeparatorChar +
                [System.IO.Path]::AltDirectorySeparatorChar +
                $randomFileName
            
            # Act
            $canonicalPath = Get-CanonicalPath $nonCanonicalPath

            # Assert
            $canonicalPath | Should -BeExactly (Join-Path $tempPath $randomFileName)
        }

        It "returns path that is canonical up to but excluding the non-existent file or directory" {
            # Arrange
            $tempPath = [System.IO.Path]::GetTempPath()
            $randomFileName = [System.IO.Path]::GetRandomFileName()
            $nonCanonicalPath = (Join-Path $tempPath $randomFileName).ToUpper()

            # Act
            $canonicalPath = Get-CanonicalPath $nonCanonicalPath

            # Assert
            $canonicalPath | Should -BeExactly (Join-Path $tempPath $randomFileName.ToUpper())
        }

        It "returns an absolute path" {
            # Arrange
            $randomFileName = [System.IO.Path]::GetRandomFileName()
            $nonCanonicalPath = Join-Path "." $randomFileName

            # Act
            $canonicalPath = Get-CanonicalPath $nonCanonicalPath

            # Assert
            $absolutePath = Join-Path (Get-Location).Path $randomFileName
            $canonicalPath | Should -BeExactly $absolutePath
        }
    }

    Context "for file system paths in the TestDrive" {
        It "returns the provider path" {
            # Arrange
            $testPath = Join-Path "TestDrive:" ([System.IO.Path]::GetRandomFileName())
            $randomFileName = [System.IO.Path]::GetRandomFileName()
            $nonCanonicalPath = Join-Paths $testPath $randomFileName
            
            # Act
            $canonicalPath = Get-CanonicalPath $nonCanonicalPath

            # Assert
            $providerPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($nonCanonicalPath)
            $canonicalPath | Should -BeExactly $providerPath
        }
    }
}