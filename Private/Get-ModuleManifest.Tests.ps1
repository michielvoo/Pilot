BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Write-Error
}

Describe Get-ModuleManifest {
    Context "for a valid module manifest" {
        It "returns a hash table indicating success and with module info and the manifest path" {
            # Arrange
            $parameters = @{
                LiteralPath = "TestDrive:"
                ModuleName = "Module"
            }
            $manifestPath = Join-Path $parameters.LiteralPath "$($parameters.ModuleName).psd1"
            New-ModuleManifest $manifestPath -ModuleVersion "1.23.456"

            # Act
            $manifest = Get-ModuleManifest @parameters

            # Assert
            $manifest | Should -Not -BeNullOrEmpty
            $manifest | Should -BeOfType [hashtable]
            $manifest.Failed | Should -BeNullOrEmpty
            $manifest.ModuleInfo | Should -BeofType [psmoduleinfo]
            $manifest.ModuleInfo.Version | Should -Be "1.23.456"
            $manifest.Path | Should -Be $manifestPath
        }
    }

    Context "for an invalid manifest" {
        It "returns a hash table indicating failure and with the manifest path" {
            # Arrange
            Mock Test-ModuleManifest {
                Microsoft.PowerShell.Utility\Write-Error "error"
            }

            $parameters = @{
                LiteralPath = "TestDrive:"
                ModuleName = "Module"
            }

            # Act
            $manifest = Get-ModuleManifest @parameters

            # Assert
            $manifest.Failed | Should -BeTrue
            $manifest.Path | Should -Be (Join-Path $parameters.LiteralPath "$($parameters.ModuleName).psd1")
        }

        It "writes a written error" {
            # Arrange
            Mock Test-ModuleManifest {
                Microsoft.PowerShell.Utility\Write-Error "error"
            }

            $parameters = @{
                LiteralPath = "TestDrive:"
                ModuleName = "Module"
            }

            # Act
            Get-ModuleManifest @parameters

            # Assert
            Should -Invoke Write-Error -ParameterFilter {
                $Prefix | Should -Be "Manifest"
                $ErrorRecord.CategoryInfo.Category | Should -Be "NotSpecified"

                $true
            }
        }

        It "writes a thrown error" {
            # Arrange
            Mock Test-ModuleManifest {
                throw "error"
            }

            $parameters = @{
                LiteralPath = "TestDrive:"
                ModuleName = "Module"
            }

            # Act
            Get-ModuleManifest @parameters

            # Assert
            Should -Invoke Write-Error -ParameterFilter {
                $Prefix | Should -Be "Manifest"
                $ErrorRecord.CategoryInfo.Category | Should -Be "OperationStopped"

                $true
            }
        }
    }
}