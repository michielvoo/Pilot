. (Join-Path $PSScriptRoot "Write-Error.ps1")

function Invoke-Tests {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$TestsPath,

        [Parameter(Mandatory, Position = 1)]
        [string]$ArtifactsPath,

        [Parameter(Mandatory, Position = 2)]
        [string]$ModuleName
    )

    $testFiles = Get-ChildItem -Path $TestsPath -Filter "*.Tests.ps1" -Recurse
    if ($testFiles.Count -eq 0) {
        return
    }

    $configuration = @{
        CodeCoverage = @{
            # Enable CodeCoverage
            Enabled = $true
            # Format to use for code coverage report.
            OutputFormat = "JaCoCo"
            # Path relative to the current directory where code coverage report is saved.
            OutputPath = Join-Path $ArtifactsPath "coverage.xml"
        }
        Output = @{
            # The verbosity of output
            Verbosity = "None"
        }
        Run = @{
            # Do not exit with non-zero exit code when the test run fails.
            Exit = $false
            # Return result object to the pipeline after finishing the test run.
            PassThru = $true
            # Directories to be searched for tests
            Path = @($TestsPath)
        }
        TestResult = @{
            # Enable TestResult.
            Enabled = $true
            # Format to use for test result report.
            OutputFormat = "NUnitXml"
            # Path relative to the current directory where test result report is saved.
            OutputPath = Join-Path $ArtifactsPath "tests.xml"
            # Set the name assigned to the root 'test-suite' element.
            TestSuiteName = $ModuleName
        }
    }

    $testResult = Invoke-Pester -Configuration $configuration

    if ($testResult.FailedCount)
    {
        $failedTests = $testResult.Tests | Where-Object Result -eq "Failed"
        # Objects are of type Test
        # See https://github.com/pester/Pester/blob/main/src/csharp/Pester/Test.cs

        foreach($failedTest in $failedTests) {

            # A single test can fail multiple times
            foreach ($errorRecord in $failedTest.ErrorRecord) {

                # The path segments of the test, joined by "."
                $message = "$($failedTest.ExpandedPath)"

                $category = $errorRecord.CategoryInfo.Category
                if ($category -eq "InvalidResult") {
                    # Error ID is "PesterAssertionFailed"
                    # Exception is [Exception]
                    # TargetObject is @{ Message; File; Line; LineText; Terminating }
                    $message += " failed: "
                }
                else {
                    $message += ": Unexpected error ($category): "
                }

                $lines = $errorRecord.Exception.Message.Split([System.Environment]::NewLine)
                foreach ($line in $lines) {
                    if ($line.StartsWith(" ")) {
                        # For example, the line that renders a cater where strings differ
                        # or lines from unexpected errors formatted by PowerShell
                        continue
                    }

                    # Collapse runs of spaces into a single space
                    $line = $line.Trim() -replace "\s+"," "
                    if ($line.Length -eq 0) {
                        continue
                    }

                    if (-not ($line.EndsWith("."))) {
                        $line = "$line."
                    }

                    $message += "$line "
                }

                $message = $message.TrimEnd(" ");

                Write-Error "Test" $message
            }
        }

        return @{ Failed = $true }
    }
}
