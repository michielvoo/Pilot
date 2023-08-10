BeforeAll {
    . $PSCommandPath.Replace(".Tests.ps1", ".ps1")

    Mock Invoke-Pester
    Mock Write-Error
}

Describe Invoke-Tests {
    Context "when there are no test files" {
        It "does not invoke Pester" {
            # Arrange
            $parameters = @{
                TestsPath = Join-Path TestDrive: Tests
                ArtifactsPath = Join-Path TestDrive: Artifacts
                ModuleName = "Example"
            }

            # Act
            Invoke-Tests @parameters

            # Assert
            Should -Not -Invoke Invoke-Pester
        }
    }

    Context "when there are *.Tests.ps1 files" {
        BeforeAll {
            $testsPath = Join-Path TestDrive: Tests
            $artifactsPath = Join-Path TestDrive: Artifacts
            $moduleName = "Example"

            Set-Variable parameters @{
                TestsPath = $testsPath
                ArtifactsPath = $artifactsPath
                ModuleName = $moduleName
            }

            New-Item $testsPath -Force -ItemType File -Name Example.Tests.ps1
        }

        It "invokes Pester with configuration to create code coverage report in the artifacts directory" {
            # Act
            Invoke-Tests @parameters

            # Assert
            Should -Invoke Invoke-Pester -ParameterFilter {
                $Configuration.CodeCoverage | Should -Not -BeNullOrEmpty
                $Configuration.CodeCoverage.Enabled.Value | Should -BeTrue
                $Configuration.CodeCoverage.OutputFormat.Value | Should -BeExactly "JaCoCo"
                $Configuration.CodeCoverage.OutputPath.Value | Should -BeExactly (Join-Path $artifactsPath "coverage.xml")

                $true
            }
        }

        It "invokes Pester with configuration for none verbosity" {
            # Act
            Invoke-Tests @parameters

            # Assert
            Should -Invoke Invoke-Pester -ParameterFilter {
                $Configuration.Output | Should -Not -BeNullOrEmpty
                $Configuration.Output.Verbosity.Value | Should -BeExactly "None"

                $true
            }
        }

        It "invokes Pester with configuration to find tests, not exit, and pass through test results" {
            # Act
            Invoke-Tests @parameters

            # Assert
            Should -Invoke Invoke-Pester -ParameterFilter {
                $Configuration.Run | Should -Not -BeNullOrEmpty
                $Configuration.Run.Exit.Value | Should -BeFalse
                $Configuration.Run.PassThru.Value | Should -BeTrue
                $Configuration.Run.Path.Value | Should -Be @($testsPath)

                $true
            }
        }

        It "invokes Pester with configuration to create test report in the artifacts directory" {
            # Act
            Invoke-Tests @parameters

            # Assert
            Should -Invoke Invoke-Pester -ParameterFilter {
                $Configuration.TestResult | Should -Not -BeNullOrEmpty
                $Configuration.TestResult.Enabled.Value | Should -BeTrue
                $Configuration.TestResult.OutputFormat.Value | Should -BeExactly "NUnitXml"
                $Configuration.TestResult.OutputPath.Value | Should -BeExactly (Join-Path $artifactsPath "tests.xml")
                $Configuration.TestResult.TestSuiteName.Value | Should -BeExactly $moduleName

                $true
            }
        }
    }

    Context "when tests succeed" {
        BeforeAll {
            $testsPath = Join-Path TestDrive: Tests

            Set-Variable parameters @{
                TestsPath = $testsPath
                ArtifactsPath = Join-Path TestDrive: Artifacts
                ModuleName = "Example"
            }

            New-Item $testsPath -Force -ItemType File -Name Example.Tests.ps1
        }

        It "does not write any errors" {
            # Arrange
            Mock Invoke-Pester {
                @{
                    FailedCount = 0
                }
            }

            # Act
            Invoke-Tests @parameters

            # Assert
            Should -Not -Invoke Write-Error
        }
    }

    Context "when tests fail" {
        BeforeAll {
            $testsPath = Join-Path TestDrive: Tests

            Set-Variable parameters @{
                TestsPath = $testsPath
                ArtifactsPath = Join-Path TestDrive: Artifacts
                ModuleName = "Example"
            }

            New-Item $testsPath -Force -ItemType File -Name Example.Tests.ps1
        }

        It "writes one error for each error record of each failed test" {
            # Arrange
            $errorRecord = @{
                CategoryInfo = @{
                    Category = "InvalidResult"
                }
                Exception = @{
                    Message = "message"
                }
            }

            Mock Invoke-Pester {
                @{
                    FailedCount = 1
                    Tests = @(
                        @{
                            ErrorRecord = @($errorRecord, $errorRecord)
                            ExpandedPath = "test 1"
                            Result = "Failed"
                        }
                        @{
                            ErrorRecord = @($errorRecord)
                            ExpandedPath = "test 2"
                            Result = "Failed"
                        }
                    )
                }
            }

            # Act
            Invoke-Tests @parameters

            # Assert
            Should -Invoke Write-Error -Times 3
        }

        It "writes an error for failed assertions" {
            # Arrange
            $errorRecord = @{
                CategoryInfo = @{
                    Category = "InvalidResult"
                }
                Exception = @{
                    Message = "line 1$([System.Environment]::NewLine)line   2$([System.Environment]::NewLine)  line 3"
                }
            }

            Mock Invoke-Pester {
                @{
                    FailedCount = 1
                    Tests = @(
                        @{
                            ErrorRecord = @($errorRecord)
                            ExpandedPath = "example test"
                            Result = "Failed"
                        }
                    )
                }
            }

            # Act
            Invoke-Tests @parameters

            # Assert
            Should -Invoke Write-Error -ParameterFilter {
                $Prefix | Should -BeExactly "Test"
                $ErrorMessage | Should -BeExactly "example test failed: line 1. line 2."

                $true
            }
        }

        It "writes an error for unexpected exceptions" {
            # Arrange
            $errorRecord = @{
                CategoryInfo = @{
                    Category = "InvalidArgument"
                }
                Exception = @{
                    Message = "exception message"
                }
            }

            Mock Invoke-Pester {
                @{
                    FailedCount = 1
                    Tests = @(
                        @{
                            ErrorRecord = @($errorRecord)
                            ExpandedPath = "example test"
                            Result = "Failed"
                        }
                    )
                }
            }

            # Act
            Invoke-Tests @parameters

            # Assert
            Should -Invoke Write-Error -ParameterFilter {
                $Prefix | Should -BeExactly "Test"
                $ErrorMessage | Should -BeExactly "example test: Unexpected error (InvalidArgument): exception message."

                $true
            }
        }

        It "indicates failure" {
            # Arrange
            Mock Invoke-Pester {
                @{
                    FailedCount = 1
                }
            }

            # Act
            $tests = Invoke-Tests @parameters

            # Assert
            $tests.Failed | Should -BeTrue
        }
    }
}
