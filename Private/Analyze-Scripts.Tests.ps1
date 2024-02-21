BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-ScriptAnalyzer
    Mock Write-Error
}

Describe Analyze-Scripts {
    It "analyzes every PowerShell script except tests files" -ForEach @(
        @{ File = "Script.ps1"; ShouldAnalyze = $true },
        @{ File = "Script.Tests.ps1"; ShouldAnalyze = $false },
        @{ File = "Script.psd1"; ShouldAnalyze = $true },
        @{ File = "Script.psm1"; ShouldAnalyze = $true },
        @{ File = "Script.txt"; ShouldAnalyze = $false }
    ) {
        # Arrange
        $scriptsPath = Join-Path "TestDrive:" "Scripts"
        if (Test-Path $scriptsPath) {
            Remove-Item $scriptsPath -Force -Recurse
        }
        New-Item $scriptsPath -Force -ItemType File -Name $File

        # Act
        Analyze-Scripts "TestDrive:"

        # Assert
        if ($ShouldAnalyze) {
            Should -Invoke Invoke-ScriptAnalyzer -Times 1 -ParameterFilter {
                Split-Path $Path -Leaf | Should -Be $File

                $true
            }
        }
        else {
            Should -Not -Invoke Invoke-ScriptAnalyzer
        }
    }

    It "use default rules and information+ severity" {
        # Arrange
        $scriptsPath = Join-Path "TestDrive:" "Scripts"
        New-Item $scriptsPath -Force -ItemType File -Name "Script.ps1"

        # Act
        Analyze-Scripts "TestDrive:"

        # Assert
        Should -Invoke Invoke-ScriptAnalyzer -ParameterFilter {
            $IncludeDefaultRules | Should -BeTrue
            $Severity | Should -Be @("Information","Warning","Error")

            $true
        }
    }

    It "writes an error for each diagnostic record" {
        # Arrange
        $scriptsPath = Join-Path "TestDrive:" "Scripts"
        New-Item $scriptsPath -Force -ItemType File -Name "Script.ps1"

        Mock Invoke-ScriptAnalyzer {
            @(
                @{
                    Extent = @{
                        StartLineNumber = 1
                        StartColumnNumber = 2
                    }
                    Message = "message"
                    RuleName = "rule"
                    ScriptPath = "script path"
                }
            )
        }

        # Act
        Analyze-Scripts "TestDrive:"

        # Assert
        Should -Invoke Write-Error -ParameterFilter {
            $Prefix | Should -BeExactly "Code"
            $ErrorMessage | Should -BeExactly "script path:1:2: rule: message"

            $true
        }
    }

    It "indicates failure" {
        # Arrange
        $scriptsPath = Join-Path "TestDrive:" "Scripts"
        New-Item $scriptsPath -Force -ItemType File -Name "Script.ps1"

        Mock Invoke-ScriptAnalyzer { @( @{ Message = "message" } ) }

        # Act
        $result = Analyze-Scripts "TestDrive:"

        # Assert
        $result.Failed | Should -BeTrue
    }
}