. (Join-Path $PSScriptRoot "Write-Error.ps1")

function Analyze-Scripts {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$ScriptsPath
    )

    $result = @{}

    $scriptFiles = Get-ChildItem $ScriptsPath -Exclude "*.Tests.ps1" -Recurse | Where-Object Extension -in ".ps1",".psd1",".psm1"
    foreach ($scriptFile in $scriptFiles) {

        $parameters = @{
            # Invoke default rules along with Custom rules.
            IncludeDefaultRules = $true
            Path = $scriptFile.FullName
            # Selects rule violations with the specified severity
            Severity = "Information","Warning","Error"
        }
        $diagnosticRecords = Invoke-ScriptAnalyzer @parameters

        if ($diagnosticRecords)
        {
            foreach ($record in $diagnosticRecords) {
                $message = "$($record.ScriptPath):$($record.Extent.StartLineNumber):$($record.Extent.StartColumnNumber): "
                $message += "$($record.RuleName): "
                $message += $record.Message
            }

            $result.Failed = $true
        }
    }

    return $result
}