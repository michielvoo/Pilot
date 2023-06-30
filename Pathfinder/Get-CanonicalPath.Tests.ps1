BeforeAll {
    . $PSCommandPath.Replace(".Tests.", ".")
    . (Join-Path $PSScriptRoot "Join-Paths.ps1")
}

Describe Get-CanonicalPath {
    It "Resolves the path" {
        # Arrange
        $tempPath = [System.IO.Path]::GetTempPath()
        $randomFileName = [System.IO.Path]::GetRandomFileName()
        $nonCanonicalPath = Join-Paths $tempPath $randomFileName ".." $randomFileName
        
        # Act
        $canonicalPath = Get-CanonicalPath $nonCanonicalPath

        # Assert
        $canonicalPath | Should -BeExactly (Join-Path $tempPath $randomFileName)
    }

    It "Returns path that is canonical up to the non-existent file or directory" {
        # Arrange
        $tempPath = [System.IO.Path]::GetTempPath()
        $randomFileName = [System.IO.Path]::GetRandomFileName()
        $nonCanonicalPath = (Join-Path $tempPath $randomFileName).ToUpper()

        # Act
        $canonicalPath = Get-CanonicalPath $nonCanonicalPath

        # Assert
        $canonicalPath | Should -BeExactly (Join-Path $tempPath $randomFileName.ToUpper())
    }

    It "Removes the trailing directory separator" {
        # Arrange
        $tempPath = [System.IO.Path]::GetTempPath().TrimEnd([System.IO.Path]::DirectorySeparatorChar)
        $nonCanonicalPath = "$tempPath$([System.IO.Path]::DirectorySeparatorChar)"
        
        # Act
        $canonicalPath = Get-CanonicalPath $nonCanonicalPath

        # Assert
        $canonicalPath | Should -BeExactly $tempPath
    }

    It "Removes the repeating directory separators" {
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
}